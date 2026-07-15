// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Pirs Kurmancî';

  @override
  String get loginTitle => 'Pirs Kurmancî';

  @override
  String get emailHint => 'E-posta';

  @override
  String get passwordHint => 'Şifre';

  @override
  String get nicknameHint => 'Kullanıcı Adı';

  @override
  String get loginButton => 'Giriş Yap';

  @override
  String get registerButton => 'Kayıt Ol';

  @override
  String get guestButton => 'Misafir Olarak Devam Et';

  @override
  String get emptyFieldsError => 'Lütfen tüm alanları doldurun';

  @override
  String get loginError => 'Giriş başarısız. Tekrar deneyin.';

  @override
  String get playNow => 'Şimdi Oyna!';

  @override
  String get playNowSubtitle => 'Hızlı oyuna başla';

  @override
  String get multiplayer => 'Oda / Arkadaş';

  @override
  String get multiplayerSubtitle => 'Arkadaşlarınla oyna';

  @override
  String get leaderboard => 'Liderlik Tablosu';

  @override
  String get leaderboardSubtitle => 'En iyi oyuncuları gör';

  @override
  String get categories => 'Kategoriler';

  @override
  String get all => 'Tümü';

  @override
  String get comingSoon => 'Yakında...';

  @override
  String get comingSoonDesc =>
      'Çok oyunculu, haftalık yarışmalar ve daha fazlası!';

  @override
  String get home => 'Ana Sayfa';

  @override
  String get profile => 'Profil';

  @override
  String get errorTryAgain => 'Tekrar dene';
}
