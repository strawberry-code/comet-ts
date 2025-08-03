// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Flutter Riverpod Saubere Architektur';

  @override
  String get welcomeMessage =>
      'Willkommen bei Flutter Riverpod Saubere Architektur';

  @override
  String get home => 'Startseite';

  @override
  String get settings => 'Einstellungen';

  @override
  String get profile => 'Profil';

  @override
  String get darkMode => 'Dunkler Modus';

  @override
  String get lightMode => 'Heller Modus';

  @override
  String get systemMode => 'Systemmodus';

  @override
  String get language => 'Sprache';

  @override
  String get change_language => 'Sprache ändern';

  @override
  String get theme => 'Thema';

  @override
  String get change_theme => 'Thema ändern';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get notification_settings => 'Benachrichtigungseinstellungen';

  @override
  String get localization_demo => 'Lokalisierungsdemo';

  @override
  String get localization_demo_description =>
      'Zeigt Sprach- und Formatierungsfunktionen';

  @override
  String get language_settings => 'Spracheinstellungen';

  @override
  String get select_your_language => 'Wähle deine Sprache';

  @override
  String get language_explanation =>
      'Wähle die Sprache, in der du die App verwenden möchtest';

  @override
  String get localization_assets_demo => 'Demo lokalisierter Ressourcen';

  @override
  String get current_language => 'Aktuelle Sprache';

  @override
  String get language_code => 'Sprachcode';

  @override
  String get language_name => 'Sprachname';

  @override
  String get formatting_examples => 'Formatierungsbeispiele';

  @override
  String get date_full => 'Vollständiges Datum';

  @override
  String get date_short => 'Kurzes Datum';

  @override
  String get time => 'Uhrzeit';

  @override
  String get currency => 'Währung';

  @override
  String get percent => 'Prozent';

  @override
  String get localized_assets => 'Lokalisierte Ressourcen';

  @override
  String get localized_assets_explanation =>
      'Beispiele für Bilder und andere Ressourcen, die sich je nach Sprache ändern';

  @override
  String get image_example => 'Bildbeispiel';

  @override
  String get welcome_image_caption =>
      'Ein Willkommensbild in Ihrer Sprache lokalisiert';

  @override
  String get common_image_example => 'Gemeinsames Bildbeispiel';

  @override
  String get common_image_caption =>
      'Dieses Bild wird in allen Sprachen verwendet';

  @override
  String get logout => 'Abmelden';

  @override
  String get login => 'Anmelden';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get signIn => 'Einloggen';

  @override
  String get register => 'Registrieren';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get errorOccurred => 'Ein Fehler ist aufgetreten';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String greeting(String name) {
    return 'Hallo, $name!';
  }

  @override
  String itemCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Elemente',
      one: '1 Element',
      zero: 'Keine Elemente',
    );
    return '$_temp0';
  }

  @override
  String lastUpdated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Zuletzt aktualisiert: $dateString';
  }
}
