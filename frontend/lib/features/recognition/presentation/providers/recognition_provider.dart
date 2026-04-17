import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart'
    as mlkit;
import 'package:hand_detection/hand_detection.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:tflite_flutter/tflite_flutter.dart' as tflite;

import '../../../../../core/providers/camera_lifecycle_provider.dart';
import '../../../../../core/providers/tts_provider.dart';
import '../../../../../core/utils/landmark_normalizer.dart';
import '../../../../../core/utils/label_mapper.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Developer modu için landmark verisi (ValueNotifier ile taşınır)
// ─────────────────────────────────────────────────────────────────────────────

class LandmarkDevData {
  final List<Offset> posePoints;  // 11 nokta [0,1] normalize
  final List<Offset> rightHand;   // ≤21 nokta
  final List<Offset> leftHand;    // ≤21 nokta
  final int bufferFill;
  final int poseCount;
  final int handCount;

  const LandmarkDevData({
    this.posePoints = const [],
    this.rightHand  = const [],
    this.leftHand   = const [],
    this.bufferFill = 0,
    this.poseCount  = 0,
    this.handCount  = 0,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Durum sınıfı
// ─────────────────────────────────────────────────────────────────────────────

class RecognitionState {
  final bool isReady;
  final bool isError;
  final CameraController? cameraController;
  // Anlık tahmin (smoothing sonrası)
  final String predictedWord;
  final double confidenceScore;
  // Altyazı biriktirme listesi
  final List<String> sentence;

  const RecognitionState({
    this.isReady = false,
    this.isError = false,
    this.cameraController,
    this.predictedWord = '',
    this.confidenceScore = 0.0,
    this.sentence = const [],
  });

  RecognitionState copyWith({
    bool? isReady,
    bool? isError,
    CameraController? cameraController,
    String? predictedWord,
    double? confidenceScore,
    List<String>? sentence,
  }) {
    return RecognitionState(
      isReady: isReady ?? this.isReady,
      isError: isError ?? this.isError,
      cameraController: cameraController ?? this.cameraController,
      predictedWord: predictedWord ?? this.predictedWord,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      sentence: sentence ?? this.sentence,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider  (Riverpod 3.x — NotifierProvider)
// ─────────────────────────────────────────────────────────────────────────────

final recognitionProvider =
    NotifierProvider<RecognitionNotifier, RecognitionState>(
  RecognitionNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class RecognitionNotifier extends Notifier<RecognitionState> {
  // ── Algılayıcılar ──────────────────────────────────────────────────────────
  mlkit.PoseDetector? _poseDetector;
  HandDetector? _handDetector;
  tflite.Interpreter? _interpreter;
  CameraController? _camera;
  List<CameraDescription> _allCameras = [];
  CameraLensDirection _currentLens = CameraLensDirection.back;

  // ── Sliding-window tamponu ─────────────────────────────────────────────────
  // [0..41] Sağ el · [42..83] Sol el · [84..105] Pose (11 nokta)
  static const int _windowSize  = 60;
  static const int _featureSize = 106;
  static const int _numClasses  = 226;
  static const List<int> _poseIndices = [0, 2, 5, 7, 8, 11, 12, 13, 14, 15, 16];

  final List<List<double>> _buffer = [];
  int  _frameCounter = 0;
  bool _isProcessing = false;

  // ── Temporal smoothing ────────────────────────────────────────────────────
  // Spec: stride 5 kare; aynı sınıf 8 ardışık inference → göster
  static const int _stableFrames = 8;
  int _lastIdx = -1;
  int _streak  = 0;

  // ── Altyazı / cümle biriktirme ────────────────────────────────────────────
  String _lastShownWord = '';
  Timer? _clearTimer;

  // ── Developer modu — per-frame Riverpod rebuild tetiklememek için ─────────
  final devNotifier = ValueNotifier<LandmarkDevData>(const LandmarkDevData());

  // ── Riverpod 3.x: build() başlangıç durumunu döndürür ────────────────────

  @override
  RecognitionState build() {
    ref.keepAlive();
    ref.onDispose(_cleanup);

    // Kamera aktif provider'ını dinle — navigasyon katmanından gelen sinyal
    ref.listen<bool>(cameraActiveProvider, (_, isActive) {
      if (isActive) {
        resumeCamera();
      } else {
        pauseCamera();
      }
    });

    _init();
    return const RecognitionState();
  }

  // ── Başlatma ───────────────────────────────────────────────────────────────

  Future<void> _init() async {
    try {
      _poseDetector = mlkit.PoseDetector(
        options: mlkit.PoseDetectorOptions(
          mode: mlkit.PoseDetectionMode.stream,
          model: mlkit.PoseDetectionModel.base,
        ),
      );

      _handDetector = HandDetector();
      await _handDetector!.initialize();

      final opts = tflite.InterpreterOptions()..threads = 4;
      _interpreter = await tflite.Interpreter.fromAsset(
        'assets/models/sign_language_model.tflite',
        options: opts,
      );

      await _startCamera();
    } catch (e) {
      debugPrint('❌ Başlatma hatası: $e');
      state = state.copyWith(isError: true);
    }
  }

  Future<void> _startCamera({CameraLensDirection? lens}) async {
    _allCameras = await availableCameras();
    if (_allCameras.isEmpty) {
      state = state.copyWith(isError: true);
      return;
    }

    final direction = lens ?? _currentLens;
    final selected = _allCameras.firstWhere(
      (c) => c.lensDirection == direction,
      orElse: () => _allCameras.first,
    );
    _currentLens = selected.lensDirection;

    final format = Platform.isIOS
        ? ImageFormatGroup.bgra8888
        : ImageFormatGroup.nv21;

    await _camera?.stopImageStream();
    await _camera?.dispose();

    _camera = CameraController(
      selected,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: format,
    );
    await _camera!.initialize();
    _buffer.clear();

    state = state.copyWith(
      isReady: true,
      cameraController: _camera,
      predictedWord: '',
      confidenceScore: 0.0,
    );

    // Stream'i yalnızca kamera ekranı aktifse başlat
    if (ref.read(cameraActiveProvider)) {
      _camera!.startImageStream(_onFrame);
    }
  }

  // ── Kare işleme ────────────────────────────────────────────────────────────

  void _onFrame(CameraImage image) async {
    _frameCounter++;
    // Spec: stride = 5 kare
    if (_frameCounter % 5 != 0) return;
    if (_isProcessing) return;
    if (_poseDetector == null || _handDetector == null) return;
    _isProcessing = true;

    final bool doLog = (_frameCounter % 150 == 0); // ~15 sn'de bir log
    if (doLog) {
      debugPrint('📷 Kare: $_frameCounter | '
          'boyut: ${image.width}×${image.height} | '
          'düzlem: ${image.planes.length} | '
          'stride: ${image.planes[0].bytesPerRow} | '
          'buffer: ${_buffer.length}/$_windowSize');
    }

    try {
      final frame = List<double>.filled(_featureSize, 0.0);
      bool anyDetected = false;

      final inputImage = _buildInputImage(image);

      // 1. Pose (ML Kit) — indeksler 84..105
      var poseRaw = const <Offset>[];
      int poseCount = 0;
      if (inputImage != null) {
        final poses = await _poseDetector!.processImage(inputImage);
        poseCount = poses.length;
        if (poses.isNotEmpty) {
          anyDetected = true;
          poseRaw = _fillPose(poses.first, image, frame);
        }
        if (doLog) debugPrint('🧍 Pose: $poseCount tespit');
      }

      // 2. Eller (hand_detection) — indeksler 0..83
      var rightRaw = const <Offset>[];
      var leftRaw  = const <Offset>[];
      int handCount = 0;
      final mat = _toMat(image);
      if (mat != null) {
        final hands = await _handDetector!.detectOnMat(mat);
        handCount = hands.length;
        if (hands.isNotEmpty) {
          anyDetected = true;
          final filled = _fillHands(hands, image, frame);
          rightRaw = filled.right;
          leftRaw  = filled.left;
        }
        if (doLog) debugPrint('🖐 El: $handCount tespit');
        mat.dispose();
      }

      // Dev notifier güncelle (Riverpod rebuild olmaz)
      if (ref.read(settingsProvider).devMode) {
        devNotifier.value = LandmarkDevData(
          posePoints: poseRaw,
          rightHand:  rightRaw,
          leftHand:   leftRaw,
          bufferFill: _buffer.length,
          poseCount:  poseCount,
          handCount:  handCount,
        );
      }

      if (anyDetected) {
        _buffer.add(frame);
        if (_buffer.length > _windowSize) _buffer.removeAt(0);
        if (_buffer.length == _windowSize) _runInference();
      } else {
        if (_buffer.isNotEmpty) _buffer.clear();
        state = state.copyWith(predictedWord: '', confidenceScore: 0.0);
      }
    } catch (e, st) {
      debugPrint('❌ Frame hatası: $e\n$st');
    } finally {
      _isProcessing = false;
    }
  }

  // ── Landmark doldurma ──────────────────────────────────────────────────────

  List<Offset> _fillPose(
      mlkit.Pose pose, CameraImage image, List<double> frame) {
    final raw = <Offset>[];
    for (int i = 0; i < _poseIndices.length; i++) {
      final lm = pose.landmarks[mlkit.PoseLandmarkType.values[_poseIndices[i]]];
      if (lm == null) continue;
      final nx = lm.x / image.width;
      final ny = lm.y / image.height;
      frame[84 + i * 2]     = nx;
      frame[84 + i * 2 + 1] = ny;
      raw.add(Offset(nx, ny));
    }
    return raw;
  }

  ({List<Offset> right, List<Offset> left}) _fillHands(
      List<dynamic> hands, CameraImage image, List<double> frame) {
    final right = <Offset>[];
    final left  = <Offset>[];
    for (final hand in hands) {
      final isRight  = hand.handedness == Handedness.right;
      final offset   = isRight ? 0 : 42;
      final target   = isRight ? right : left;
      final landmarks = hand.landmarks as List;
      for (int i = 0; i < landmarks.length && i < 21; i++) {
        final lm = landmarks[i];
        final nx = (lm.x as num).toDouble() / image.width;
        final ny = (lm.y as num).toDouble() / image.height;
        frame[offset + i * 2]     = nx;
        frame[offset + i * 2 + 1] = ny;
        target.add(Offset(nx, ny));
      }
    }
    return (right: right, left: left);
  }

  // ── TFLite çıkarımı ────────────────────────────────────────────────────────

  void _runInference() {
    if (_interpreter == null) return;

    try {
      final normalized = LandmarkNormalizer.normalizeWindow(_buffer);

      final input = [
        List.generate(_windowSize, (j) => List<double>.from(normalized[j])),
      ];
      final output =
          List<double>.filled(_numClasses, 0.0).reshape([1, _numClasses]);

      _interpreter!.run(input, output);

      final scores = List<double>.from(output[0] as List);
      var maxScore = 0.0;
      var maxIdx   = -1;

      for (int i = 0; i < scores.length; i++) {
        if (scores[i] > maxScore) {
          maxScore = scores[i];
          maxIdx   = i;
        }
      }

      final topWord = maxIdx >= 0 ? LabelMapper.getTrWord(maxIdx) : '?';
      debugPrint('🧠 Inference → idx:$maxIdx  skor:${(maxScore * 100).toStringAsFixed(1)}%  kelime:$topWord');

      // ── Spec: < %70 = garbage → gösterme ─────────────────────────────────
      final smoothingOn =
          ref.read(settingsProvider).temporalSmoothingEnabled;

      if (maxIdx >= 0 && maxScore >= 0.70) {
        if (maxIdx == _lastIdx) {
          _streak++;
        } else {
          _lastIdx = maxIdx;
          _streak  = 1;
        }

        // Smoothing kapalıysa ilk inference'da anında göster (streak=1 yeterli)
        final threshold = smoothingOn ? _stableFrames : 1;
        if (_streak >= threshold) {
          final word = LabelMapper.getTrWord(maxIdx);

          if (word != _lastShownWord) {
            _lastShownWord = word;
            final updated = [...state.sentence, word];
            final trimmed = updated.length > 6
                ? updated.sublist(updated.length - 6)
                : updated;

            state = state.copyWith(
              predictedWord:   word,
              confidenceScore: maxScore,
              sentence:        trimmed,
            );

            // TTS: ttsEnabled ise yeni kelimeyi seslendir
            if (ref.read(settingsProvider).ttsEnabled) {
              ref.read(ttsProvider.notifier).speak(word);
            }

            // Haptic: ≥90% güven → orta titreşim (spec)
            if (maxScore >= 0.90) {
              HapticFeedback.mediumImpact();
            }

            _clearTimer?.cancel();
            _clearTimer = Timer(const Duration(seconds: 4), () {
              state = state.copyWith(
                predictedWord:   '',
                confidenceScore: 0.0,
                sentence:        [],
              );
              _lastShownWord = '';
            });
          } else {
            state = state.copyWith(confidenceScore: maxScore);
          }
        }
      } else {
        // Skor düşük — streak'i sıfırla ama mevcut cümleye dokunma
        _streak = 0;
      }
    } catch (e, st) {
      debugPrint('❌ Çıkarım hatası: $e\n$st');
    }
  }

  // ── Yardımcılar ────────────────────────────────────────────────────────────

  mlkit.InputImage? _buildInputImage(CameraImage image) {
    try {
      final rotation =
          mlkit.InputImageRotationValue.fromRawValue(
            _camera!.description.sensorOrientation,
          ) ??
          mlkit.InputImageRotation.rotation90deg;

      if (Platform.isIOS) {
        return mlkit.InputImage.fromBytes(
          bytes: image.planes[0].bytes,
          metadata: mlkit.InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation,
            format: mlkit.InputImageFormat.bgra8888,
            bytesPerRow: image.planes[0].bytesPerRow,
          ),
        );
      } else {
        final bytes = _buildNV21(image);
        return mlkit.InputImage.fromBytes(
          bytes: bytes,
          metadata: mlkit.InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation,
            format: mlkit.InputImageFormat.nv21,
            bytesPerRow: image.width,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ _buildInputImage hatası: $e');
      return null;
    }
  }

  Uint8List _buildNV21(CameraImage image) {
    final int w = image.width;
    final int h = image.height;

    if (image.planes.length == 1) {
      final int stride = image.planes[0].bytesPerRow;
      if (stride == w) return image.planes[0].bytes;
      final out = Uint8List(w * h * 3 ~/ 2);
      final src = image.planes[0].bytes;
      for (int r = 0; r < h; r++) {
        out.setRange(r * w, (r + 1) * w, src, r * stride);
      }
      for (int r = 0; r < h ~/ 2; r++) {
        out.setRange(
          h * w + r * w, h * w + (r + 1) * w,
          src, h * stride + r * stride,
        );
      }
      return out;
    }

    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final out = Uint8List(w * h * 3 ~/ 2);
    for (int r = 0; r < h; r++) {
      out.setRange(r * w, (r + 1) * w, yPlane.bytes, r * yPlane.bytesPerRow);
    }
    int uvOffset = w * h;
    final int uvRows = h ~/ 2;
    final int uvCols = w ~/ 2;
    for (int r = 0; r < uvRows; r++) {
      for (int c = 0; c < uvCols; c++) {
        final srcU = r * uPlane.bytesPerRow + c * uPlane.bytesPerPixel!;
        final srcV = r * vPlane.bytesPerRow + c * vPlane.bytesPerPixel!;
        out[uvOffset++] = vPlane.bytes[srcV];
        out[uvOffset++] = uPlane.bytes[srcU];
      }
    }
    return out;
  }

  cv.Mat? _toMat(CameraImage image) {
    try {
      if (Platform.isIOS) {
        final bgra = cv.Mat.fromList(
          image.height, image.width,
          cv.MatType.CV_8UC4,
          image.planes[0].bytes,
        );
        final bgr = cv.cvtColor(bgra, cv.COLOR_BGRA2BGR);
        bgra.dispose();
        return bgr;
      } else {
        final nv21 = _buildNV21(image);
        final yuv  = cv.Mat.fromList(
          image.height + image.height ~/ 2, image.width,
          cv.MatType.CV_8UC1,
          nv21,
        );
        final bgr = cv.cvtColor(yuv, cv.COLOR_YUV2BGR_NV21);
        yuv.dispose();
        return bgr;
      }
    } catch (_) {
      return null;
    }
  }

  // ── Temizlik ───────────────────────────────────────────────────────────────

  void _cleanup() {
    _clearTimer?.cancel();
    _poseDetector?.close();
    _handDetector?.dispose();
    _interpreter?.close();
    _camera?.stopImageStream();
    _camera?.dispose();
    devNotifier.dispose();
  }

  // ── Kamera kontrolü ───────────────────────────────────────────────────────

  void pauseCamera() {
    try { _camera?.stopImageStream(); } catch (_) {}
  }

  void resumeCamera() {
    try {
      if (_camera != null && _camera!.value.isInitialized) {
        _camera!.startImageStream(_onFrame);
      }
    } catch (_) {}
  }

  /// Çift tıkla ön/arka kamera geçişi
  Future<void> switchCamera() async {
    final next = _currentLens == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    await _startCamera(lens: next);
  }
}
