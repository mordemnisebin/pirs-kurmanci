# 🌐 Pirs Kurmancî - Hızlı Online Deploy Rehberi

## En Kolay Yol: Render + Surge

### 📦 1. Backend Deploy (Render.com - Ücretsiz)

#### Adım 1: Render Hesabı
1. [render.com](https://render.com) adresine git
2. "Get Started for Free" tıkla
3. GitHub veya Email ile kayıt ol

#### Adım 2: Web Service Oluştur
1. Dashboard'da "New +" > "Web Service" tıkla
2. "Build and deploy from a Git repository" seç
3. GitHub'ı bağla veya "Public Git repository" seç

#### Adım 3: Ayarlar
```
Name: pirs-backend
Region: Frankfurt (EU Central)
Branch: main
Root Directory: pirs_backend
Runtime: Node
Build Command: npm install && npm run build
Start Command: npm run start
```

#### Adım 4: Environment Variables
"Environment" sekmesinde ekle:
```
DATABASE_URL = postgresql://neondb_owner:npg_0JQzfbI3rwZE@ep-odd-wave-agtq7b01-pooler.c-2.eu-central-1.aws.neon.tech/neondb?sslmode=require
JWT_SECRET = PirsKurmanci2025!SecretKeyForJWT@Production
NODE_ENV = production
PORT = 10000
```

#### Adım 5: Deploy
"Create Web Service" tıkla. URL alacaksın: `https://pirs-backend.onrender.com`

---

### 🌐 2. Frontend Deploy (Surge.sh - Ücretsiz)

#### Adım 1: API URL Güncelle
`pirs_flutter/lib/core/services/api_config.dart` dosyasını aç:
```dart
static const String _productionUrl = 'https://pirs-backend.onrender.com';
```

#### Adım 2: Yeniden Build Et
```powershell
cd pirs_flutter
flutter build web --release
```

#### Adım 3: Deploy
```powershell
cd build/web
surge . pirs-kurmanci.surge.sh
```

İlk seferde email ve şifre isteyecek (ücretsiz kayıt).

---

## 🎉 Sonuç

- **Backend**: `https://pirs-backend.onrender.com`
- **Frontend**: `https://pirs-kurmanci.surge.sh`

---

## ⚠️ Notlar

### Render Ücretsiz Plan:
- İlk istek 30-60 saniye sürebilir (cold start)
- Ayda 750 saat ücretsiz
- HTTPS otomatik

### Surge Ücretsiz Plan:
- Sınırsız deploy
- HTTPS otomatik
- Custom domain desteği

---

## 🔧 Alternatif: Vercel + Railway

Daha hızlı performans istersen:

### Railway (Backend):
1. [railway.app](https://railway.app)
2. "Deploy from GitHub"
3. Environment variables ekle
4. Otomatik HTTPS

### Vercel (Frontend):
1. [vercel.com](https://vercel.com)
2. `build/web` klasörünü sürükle-bırak
3. Deploy tamamlandı!
