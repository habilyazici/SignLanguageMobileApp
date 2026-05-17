import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

/// Kamera donanımına erişim datasource'u.
/// Başlatma, duraklatma, kamera geçişi ve controller stream'ini yönetir.
class CameraDataSource {
  CameraController? _camera;
  List<CameraDescription> _allCameras = [];
  CameraLensDirection _currentLens = CameraLensDirection.back;

  final _controllerCtrl = StreamController<CameraController?>.broadcast();

  /// Kamera controller değiştiğinde (ilk açılış / geçiş) yeni değer yayar.
  Stream<CameraController?> get controllerStream => _controllerCtrl.stream;

  CameraController? get currentCamera => _camera;
  int get sensorOrientation => _camera?.description.sensorOrientation ?? 90;
  bool get isFlipped => _currentLens == CameraLensDirection.front;

  Future<void> initialize() => _startCamera();

  Future<void> _startCamera({CameraLensDirection? lens}) async {
    _allCameras = await availableCameras();
    if (_allCameras.isEmpty) throw Exception('Hiç kamera bulunamadı');

    final direction = lens ?? _currentLens;
    final selected = _allCameras.firstWhere(
      (c) => c.lensDirection == direction,
      orElse: () => _allCameras.first,
    );
    _currentLens = selected.lensDirection;

    final format = Platform.isIOS
        ? ImageFormatGroup.bgra8888
        : ImageFormatGroup.yuv420;

    // Eski controller'ı kapat — hata olsa da devam et.
    try {
      await _camera?.stopImageStream();
    } catch (_) {}
    try {
      await _camera?.dispose();
    } catch (_) {}

    // iOS: low → AVCaptureSessionPreset352x288 ≈ 352×288.
    //   medium (480×360) BGRA frameler 691K olur — heap baskısı ve donma.
    //   low (352×288) BGRA frameler 405K — %41 daha küçük, ML pipeline rahatlar.
    // Android: low → ML pipeline 320×240 için optimize; daha az bellek.
    final preset = ResolutionPreset.low;

    _camera = CameraController(
      selected,
      preset,
      enableAudio: false,
      imageFormatGroup: format,
    );
    await _camera!.initialize();
    if (kDebugMode) {
      debugPrint(
        '📷 Kamera hazır: ${selected.name} (sensör: ${_camera!.description.sensorOrientation}°)',
      );
    }
    _controllerCtrl.add(_camera);
  }

  void startStream(void Function(CameraImage) onFrame) {
    try {
      _camera?.startImageStream(onFrame);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ startImageStream hatası: $e');
    }
  }

  Future<void> switchCamera() async {
    final next = _currentLens == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    await _startCamera(lens: next);
  }

  /// Sadece image stream'i durdurur.
  Future<void> stopStream() async {
    try {
      await _camera?.stopImageStream();
    } catch (_) {}
  }

  /// Kamera donanımını serbest bırakır (yeşil nokta söner)
  Future<void> release() async {
    await stopStream();
    try {
      await _camera?.dispose();
    } catch (_) {}
    _camera = null;
    if (!_controllerCtrl.isClosed) _controllerCtrl.add(null);
  }

  /// Kalıcı temizlik — stream de kapatılır, artık kullanılamaz.
  Future<void> dispose() async {
    await release();
    if (!_controllerCtrl.isClosed) _controllerCtrl.close();
  }
}
