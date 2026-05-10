# Kurulum

## Gereksinimler

- Flutter SDK (3.10.8+)
- Node.js 18+
- PostgreSQL

---

## Backend

```bash
cd backend
cp .env.example .env        # DB bağlantısı, JWT secret, Gmail SMTP ayarla
npm install
npx prisma migrate deploy
npm run dev
```

---

## Android

```bash
cd frontend
cp .env.example .env        # BASE_IP ve PORT gir (backend'in IP'si)
flutter pub get
flutter run
```

Gereksinimler: Android SDK 24+, USB debug açık veya emülatör.

---

## iOS (Mac gerekli)

```bash
cd frontend
cp .env.example .env        # BASE_IP ve PORT gir
flutter pub get
cd ios && pod install && cd ..
flutter run
```

Gereksinimler: Xcode 15+, iOS 15.5+ cihaz veya simülatör, CocoaPods.
