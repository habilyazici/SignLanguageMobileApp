# -*- coding: utf-8 -*-
"""feature_extraction_v2.ipynb
Colab'da çalıştırılmak üzere tasarlanmıştır.

DEĞİŞİKLİK (v1 → v2):
  v1: mediapipe.solutions.holistic.Holistic  ← Flutter ile koordinat dağılımı farklı
  v2: mediapipe.tasks HandLandmarker          ← Flutter'daki hand_detection ile aynı model
      mediapipe.tasks PoseLandmarker          ← Flutter'daki ML Kit ile aynı BlazePose altyapısı

Feature vector formatı (106 değer) DEĞİŞMEDİ:
  [0..41]   → sağ el   (21 nokta × x,y)
  [42..83]  → sol el   (21 nokta × x,y)
  [84..105] → pose üst vücut (11 seçili nokta × x,y)

Eğitim scripti (model_training.py) AYNEN KULLANILIR — sadece .npy dosyaları değişir.
"""

# ─── 1. Kurulum ──────────────────────────────────────────────────────────────
import os, sys, shutil, time, site
from importlib import reload

# MediaPipe Tasks API'yi destekleyen sürüm
get_ipython().system('pip uninstall -y mediapipe 2>/dev/null')
get_ipython().system('pip install mediapipe==0.10.14 --quiet')

reload(site)
sys.path.insert(0, '/usr/local/lib/python3.12/dist-packages')

# Model dosyalarını indir
get_ipython().system('wget -q -O /content/hand_landmarker.task https://storage.googleapis.com/mediapipe-models/hand_landmarker/hand_landmarker/float16/latest/hand_landmarker.task')
get_ipython().system('wget -q -O /content/pose_landmarker.task https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_full/float16/latest/pose_landmarker_full.task')

import cv2
import numpy as np
import pandas as pd
from google.colab import drive

# Doğrulama — başarısızsa Runtime → Restart Session gerekli
try:
    import mediapipe as mp
    from mediapipe.tasks import python as mp_python
    from mediapipe.tasks.python import vision as mp_vision
    # mp.Image ve mp.ImageFormat process_video_v2 içinde kullanılır
    print("✅ MediaPipe Tasks API hazır:", mp.__version__)
except Exception as e:
    print("❌ Import hatası:", e)
    raise SystemExit("Runtime → Restart Session yapıp tekrar çalıştır.")

# ─── 2. Drive bağlantısı ─────────────────────────────────────────────────────
drive.mount('/content/drive')

DRIVE_SOURCE  = "/content/drive/MyDrive/Projects/Mobil Uygulama/largeData"
COLAB_DST     = "/content/largeData"
SAVE_PATH     = os.path.join(DRIVE_SOURCE, "processed_data_v2")  # v1'i bozmaz
SUB_FOLDERS   = ['train', 'val', 'test']
CSV_FILES     = ['train_labels.csv', 'val_labels.csv', 'test_labels.csv', 'SignList_ClassId_TR_EN.csv']

def smart_copy_data():
    os.makedirs(COLAB_DST, exist_ok=True)
    print("🚀 Kopyalama başladı…")
    for folder in SUB_FOLDERS:
        src = os.path.join(DRIVE_SOURCE, folder)
        dst = os.path.join(COLAB_DST, folder)
        if os.path.exists(src) and not os.path.exists(dst):
            print(f"  📦 {folder} taşınıyor…")
            shutil.copytree(src, dst)
        else:
            print(f"  ⚠️  {folder}: {'yok' if not os.path.exists(src) else 'zaten var'}, atlandı.")
    for fname in CSV_FILES:
        src = os.path.join(DRIVE_SOURCE, fname)
        dst = os.path.join(COLAB_DST, fname)
        if os.path.exists(src):
            shutil.copy(src, dst)
            print(f"  📄 {fname} kopyalandı.")
    print("✅ Kopyalama bitti.")

smart_copy_data()
os.makedirs(SAVE_PATH, exist_ok=True)

# ─── 3. Detector başlatma ────────────────────────────────────────────────────
POSE_INDICES = [0, 2, 5, 7, 8, 11, 12, 13, 14, 15, 16]  # v1 ile aynı

def make_hand_detector():
    """Her video için yeni detector (VIDEO modu per-video çalışır)."""
    opts = mp_vision.HandLandmarkerOptions(
        base_options=mp_python.BaseOptions(model_asset_path='/content/hand_landmarker.task'),
        running_mode=mp_vision.RunningMode.VIDEO,
        num_hands=2,
        min_hand_detection_confidence=0.5,
        min_hand_presence_confidence=0.5,
        min_tracking_confidence=0.5,
    )
    return mp_vision.HandLandmarker.create_from_options(opts)

def make_pose_detector():
    opts = mp_vision.PoseLandmarkerOptions(
        base_options=mp_python.BaseOptions(model_asset_path='/content/pose_landmarker.task'),
        running_mode=mp_vision.RunningMode.VIDEO,
        min_pose_detection_confidence=0.5,
        min_pose_presence_confidence=0.5,
        min_tracking_confidence=0.5,
    )
    return mp_vision.PoseLandmarker.create_from_options(opts)

print("✅ Detector factory'leri hazır.")

# ─── 4. Tek kare koordinat çıkarımı ─────────────────────────────────────────
def extract_landmarks_v2(hand_result, pose_result):
    """
    Tasks API sonuçlarından 106-boyutlu feature vektörü üretir.

    Slot ataması (v1 ile AYNI convention):
      slot 0 (index 0-41)  → "Right" el  (Tasks API anatomik sağ)
      slot 1 (index 42-83) → "Left"  el  (Tasks API anatomik sol)
    Bu, Flutter'daki Handedness.right → offset 0 mantığıyla tutarlıdır.
    """
    frame = np.zeros(106, dtype=np.float64)

    # ── Eller ──────────────────────────────────────────────────────────────
    if hand_result.hand_landmarks:
        for i, landmarks in enumerate(hand_result.hand_landmarks):
            # handedness[i][0].category_name → "Right" veya "Left"
            try:
                side = hand_result.handedness[i][0].category_name  # "Right" | "Left"
            except (IndexError, AttributeError):
                continue

            offset = 0 if side == "Right" else 42

            for j, lm in enumerate(landmarks):
                if j >= 21:
                    break
                frame[offset + j * 2]     = lm.x  # normalize [0,1]
                frame[offset + j * 2 + 1] = lm.y

    # ── Pose ───────────────────────────────────────────────────────────────
    if pose_result.pose_landmarks:
        lms = pose_result.pose_landmarks[0]  # ilk (ve tek) kişi
        for out_idx, src_idx in enumerate(POSE_INDICES):
            if src_idx < len(lms):
                lm = lms[src_idx]
                frame[84 + out_idx * 2]     = lm.x
                frame[84 + out_idx * 2 + 1] = lm.y

    return frame

print("✅ extract_landmarks_v2 hazır.")

# ─── 5. Video işleme ─────────────────────────────────────────────────────────
def process_video_v2(video_path, sequence_length=60):
    """
    Videoyu kare kare işler; Tasks API VIDEO modunda timestamp zorunlu.
    Padding/sampling v1 ile AYNI (son kare tekrar / linspace downsample).
    """
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        return np.zeros((sequence_length, 106), dtype=np.float64)

    fps = cap.get(cv2.CAP_PROP_FPS)
    if fps <= 0:
        fps = 30.0
    window = []
    frame_idx = 0

    hand_det = make_hand_detector()
    pose_det = make_pose_detector()

    while True:
        ret, bgr = cap.read()
        if not ret:
            break

        # Tasks API için RGB + timestamp (ms cinsinden)
        rgb = cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB)
        mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb)
        ts_ms = int(frame_idx * (1000.0 / fps))

        hand_res = hand_det.detect_for_video(mp_image, ts_ms)
        pose_res = pose_det.detect_for_video(mp_image, ts_ms)

        window.append(extract_landmarks_v2(hand_res, pose_res))
        frame_idx += 1

    cap.release()
    hand_det.close()
    pose_det.close()

    if len(window) == 0:
        return np.zeros((sequence_length, 106), dtype=np.float64)

    # Padding (kısa video)
    if len(window) < sequence_length:
        last = window[-1]
        while len(window) < sequence_length:
            window.append(last)

    # Downsampling (uzun video) — v1 ile birebir aynı
    elif len(window) > sequence_length:
        indices = np.linspace(0, len(window) - 1, sequence_length, dtype=int)
        window = [window[i] for i in indices]

    return np.array(window, dtype=np.float64)  # (60, 106)

print("✅ process_video_v2 hazır.")

# ─── 6. CSV yükleme ──────────────────────────────────────────────────────────
DATA_PATH = COLAB_DST

def create_file_list(data_path):
    train_df = pd.read_csv(os.path.join(data_path, "train_labels.csv"), names=['video_id', 'label'])
    val_df   = pd.read_csv(os.path.join(data_path, "val_labels.csv"),   names=['video_id', 'label'])
    test_df  = pd.read_csv(os.path.join(data_path, "test_labels.csv"),  names=['video_id', 'label'])
    print(f"  Train: {len(train_df)}, Val: {len(val_df)}, Test: {len(test_df)}")
    return train_df, val_df, test_df

train_df, val_df, test_df = create_file_list(DATA_PATH)
print("✅ CSV'ler yüklendi.")

# ─── 7. Toplu çıkarım (resume destekli) ──────────────────────────────────────
def safe_collect_data_v2(df, folder_name, save_name):
    """
    v1 ile aynı checkpoint mantığı: her 100 videoda yedekle, kaldığı yerden devam et.
    Çıktılar processed_data_v2/ altına kaydedilir — v1 dosyalarını EZMEz.
    """
    X_final, y_final = [], []

    temp_X = os.path.join(SAVE_PATH, f"temp_X_{save_name}.npy")
    temp_y = os.path.join(SAVE_PATH, f"temp_y_{save_name}.npy")

    if os.path.exists(temp_X):
        X_final = list(np.load(temp_X, allow_pickle=True))
        y_final = list(np.load(temp_y, allow_pickle=True))
        print(f"  🔄 {save_name}: {len(X_final)} videodan devam ediliyor…")

    start = len(X_final)
    total = len(df)

    for idx in range(start, total):
        row = df.iloc[idx]
        video_path = os.path.join(DATA_PATH, folder_name, row['video_id'] + "_color.mp4")

        if os.path.exists(video_path):
            try:
                landmarks = process_video_v2(video_path)
            except Exception as e:
                print(f"  ⚠️  {row['video_id']}: hata → {e}")
                landmarks = np.zeros((60, 106), dtype=np.float64)
        else:
            print(f"  ⚠️  Eksik video: {row['video_id']}")
            landmarks = np.zeros((60, 106), dtype=np.float64)

        X_final.append(landmarks)
        y_final.append(row['label'])

        if (idx + 1) % 100 == 0 or (idx + 1) == total:
            np.save(temp_X, np.array(X_final))
            np.save(temp_y, np.array(y_final))
            pct = (idx + 1) / total * 100
            print(f"  💾 {folder_name}: {idx + 1}/{total} ({pct:.1f}%)")

    # Geçici → nihai
    np.save(os.path.join(SAVE_PATH, f"X_{save_name}.npy"), np.array(X_final))
    np.save(os.path.join(SAVE_PATH, f"y_{save_name}.npy"), np.array(y_final))
    print(f"  ✅ {save_name} tamamlandı → processed_data_v2/X_{save_name}.npy")
    return np.array(X_final), np.array(y_final)

# ─── 8. Çıkarımı başlat ─────────────────────────────────────────────────────
# Sıra önemli: Val ve Test kısa, önce bitir; sonra Train (uzun).
# Kesintide kaldığı yerden devam eder.

def run_extraction_v2():
    print("\n" + "="*50)
    print("📊 1/3 — VAL seti")
    print("="*50)
    safe_collect_data_v2(val_df, "val", "val")

    print("\n" + "="*50)
    print("📊 2/3 — TEST seti")
    print("="*50)
    safe_collect_data_v2(test_df, "test", "test")

    print("\n" + "="*50)
    print("📊 3/3 — TRAIN seti (uzun, ~28k video)")
    print("="*50)
    safe_collect_data_v2(train_df, "train", "train")

    print("\n🎉 TÜM VERİ ÇIKARIMI TAMAMLANDI!")
    print(f"📁 Dosyalar: {SAVE_PATH}")

run_extraction_v2()
