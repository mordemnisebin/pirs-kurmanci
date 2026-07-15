import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ku.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ku'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ku, this message translates to:
  /// **'Pirs Kurmancî'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In ku, this message translates to:
  /// **'Pirsên Kurmancî'**
  String get loginTitle;

  /// No description provided for @emailHint.
  ///
  /// In ku, this message translates to:
  /// **'E-peyam'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In ku, this message translates to:
  /// **'Şîfre'**
  String get passwordHint;

  /// No description provided for @nicknameHint.
  ///
  /// In ku, this message translates to:
  /// **'Navnas (Nickname)'**
  String get nicknameHint;

  /// No description provided for @loginButton.
  ///
  /// In ku, this message translates to:
  /// **'Têkeve'**
  String get loginButton;

  /// No description provided for @registerButton.
  ///
  /// In ku, this message translates to:
  /// **'Qeyd Bibe'**
  String get registerButton;

  /// No description provided for @guestButton.
  ///
  /// In ku, this message translates to:
  /// **'Wek Mêvan Bidomîne'**
  String get guestButton;

  /// No description provided for @emptyFieldsError.
  ///
  /// In ku, this message translates to:
  /// **'Ji kerema xwe hemû qadan dagirin'**
  String get emptyFieldsError;

  /// No description provided for @loginError.
  ///
  /// In ku, this message translates to:
  /// **'Têketin bi ser neket. Dîsa biceribîne.'**
  String get loginError;

  /// No description provided for @playNow.
  ///
  /// In ku, this message translates to:
  /// **'Niha Bilîze!'**
  String get playNow;

  /// No description provided for @playNowSubtitle.
  ///
  /// In ku, this message translates to:
  /// **'Lîstika bilez dest pê bike'**
  String get playNowSubtitle;

  /// No description provided for @multiplayer.
  ///
  /// In ku, this message translates to:
  /// **'Oda / Heval'**
  String get multiplayer;

  /// No description provided for @multiplayerSubtitle.
  ///
  /// In ku, this message translates to:
  /// **'Bi hevalan re bilîze'**
  String get multiplayerSubtitle;

  /// No description provided for @leaderboard.
  ///
  /// In ku, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @leaderboardSubtitle.
  ///
  /// In ku, this message translates to:
  /// **'Lîstikvanên herî baş bibîne'**
  String get leaderboardSubtitle;

  /// No description provided for @categories.
  ///
  /// In ku, this message translates to:
  /// **'Kategorî'**
  String get categories;

  /// No description provided for @all.
  ///
  /// In ku, this message translates to:
  /// **'Hemû'**
  String get all;

  /// No description provided for @comingSoon.
  ///
  /// In ku, this message translates to:
  /// **'Zû tê...'**
  String get comingSoon;

  /// No description provided for @comingSoonDesc.
  ///
  /// In ku, this message translates to:
  /// **'Multiplayer, pêşbaziyên hefteyî û gelek tişt!'**
  String get comingSoonDesc;

  /// No description provided for @home.
  ///
  /// In ku, this message translates to:
  /// **'Mal'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In ku, this message translates to:
  /// **'Profîl'**
  String get profile;

  /// No description provided for @errorTryAgain.
  ///
  /// In ku, this message translates to:
  /// **'Dîsa biceribîne'**
  String get errorTryAgain;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ku', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ku':
      return AppLocalizationsKu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
