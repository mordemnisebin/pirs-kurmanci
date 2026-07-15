# Pirs Kurmancî - Online Deploy Rehberi

## 🚀 Backend Deploy (Railway)

### Adım 1: Railway Hesabı
1. [Railway.app](https://railway.app) adresine git
2. GitHub ile giriş yap

### Adım 2: Yeni Proje Oluştur
1. "New Project" butonuna tıkla
2. "Deploy from GitHub repo" seç
3. `pirs_backend` klasörünü içeren repo'yu seç

### Adım 3: Environment Variables
Railway dashboard'da şu değişkenleri ekle:
```
DATABASE_URL=postgresql://neondb_owner:npg_0JQzfbI3rwZE@ep-odd-wave-agtq7b01-pooler.c-2.eu-central-1.aws.neon.tech/neondb?sslmode=require
JWT_SECRET=PirsKurmanci2025!SecretKeyForJWT@Production
NODE_ENV=production
```

### Adım 4: Deploy
Railway otomatik olarak deploy eder. URL'yi kopyala (örn: `https://pirs-backend-xxx.up.railway.app`)

---

## 🌐 Frontend Deploy (Vercel)

### Adım 1: Vercel Hesabı
1. [Vercel.com](https://vercel.com) adresine git
2. GitHub ile giriş yap

### Adım 2: Build Web
Önce Flutter web build'i yap:
```bash
cd pirs_flutter
flutter build web --release
```

### Adım 3: API URL Güncelle
`lib/core/services/api_config.dart` dosyasında `_productionUrl`'i Railway URL'in ile güncelle:
```dart
static const String _productionUrl = 'https://SENIN-RAILWAY-URL.up.railway.app';
```

### Adım 4: Deploy
1. Vercel'de "New Project" oluştur
2. `pirs_flutter` klasörünü yükle veya GitHub'dan bağla
3. Build settings:
   - Framework: Other
   - Build Command: `flutter build web --release`
   - Output Directory: `build/web`

---

## 📱 Alternatif: Firebase Hosting

### Flutter Web için:
```bash
# Firebase CLI kur
npm install -g firebase-tools

# Giriş yap
firebase login

# Proje oluştur
firebase init hosting

# Deploy
firebase deploy --only hosting
```

---

## ✅ Kontrol Listesi

- [ ] Backend Railway'de çalışıyor
- [ ] DATABASE_URL doğru ayarlandı
- [ ] Frontend Vercel'de çalışıyor
- [ ] API URL production URL'e güncellendi
- [ ] CORS ayarları doğru
- [ ] WebSocket bağlantısı çalışıyor

---

## 🔧 Sorun Giderme

### CORS Hatası
Backend'deki `app.ts` dosyasında CORS ayarlarını kontrol et:
```typescript
app.use(cors({
  origin: ['https://senin-vercel-url.vercel.app', 'http://localhost:3000'],
  credentials: true
}));
```

### WebSocket Bağlantı Hatası
`gameSocket.ts` dosyasında CORS ayarlarını kontrol et.

### Database Bağlantı Hatası
Neon PostgreSQL bağlantı string'inin doğru olduğundan emin ol.
