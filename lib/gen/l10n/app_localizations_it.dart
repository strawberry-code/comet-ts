// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Flutter Riverpod Architettura Pulita';

  @override
  String get welcomeMessage =>
      'Benvenuto in Flutter Riverpod Architettura Pulita';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Impostazioni';

  @override
  String get profile => 'Profilo';

  @override
  String get darkMode => 'Modalità Scura';

  @override
  String get lightMode => 'Modalità Chiara';

  @override
  String get systemMode => 'Modalità Sistema';

  @override
  String get language => 'Lingua';

  @override
  String get change_language => 'Cambia lingua applicazione';

  @override
  String get theme => 'Tema';

  @override
  String get change_theme => 'Cambia tema applicazione';

  @override
  String get notifications => 'Notifiche';

  @override
  String get notification_settings => 'Configura preferenze di notifica';

  @override
  String get localization_demo => 'Demo localizzazione';

  @override
  String get localization_demo_description =>
      'Visualizza le funzionalità di localizzazione in azione';

  @override
  String get language_settings => 'Impostazioni lingua';

  @override
  String get select_your_language => 'Seleziona la lingua desiderata';

  @override
  String get language_explanation =>
      'La lingua selezionata sarà applicata all\'intera applicazione';

  @override
  String get localization_assets_demo => 'Demo risorse localizzate';

  @override
  String get current_language => 'Lingua corrente';

  @override
  String get language_code => 'Codice lingua';

  @override
  String get language_name => 'Nome lingua';

  @override
  String get formatting_examples => 'Esempi di formattazione';

  @override
  String get date_full => 'Data (completa)';

  @override
  String get date_short => 'Data (breve)';

  @override
  String get time => 'Ora';

  @override
  String get currency => 'Valuta';

  @override
  String get percent => 'Percentuale';

  @override
  String get localized_assets => 'Risorse localizzate';

  @override
  String get localized_assets_explanation =>
      'Questa sezione dimostra come caricare risorse diverse in base alla lingua selezionata. Immagini, audio e altre risorse possono variare per lingua.';

  @override
  String get image_example => 'Esempio di immagine localizzata';

  @override
  String get welcome_image_caption =>
      'Questa immagine viene caricata in base alla lingua selezionata';

  @override
  String get common_image_example => 'Esempio di immagine comune';

  @override
  String get common_image_caption =>
      'Questa immagine è la stessa per tutte le lingue';

  @override
  String get logout => 'Disconnetti';

  @override
  String get login => 'Accedi';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Entra';

  @override
  String get register => 'Registrati';

  @override
  String get forgotPassword => 'Hai dimenticato la password?';

  @override
  String get errorOccurred => 'Si è verificato un errore';

  @override
  String get tryAgain => 'Riprova';

  @override
  String greeting(String name) {
    return 'Ciao, $name!';
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
      other: '$countString elementi',
      one: '1 elemento',
      zero: 'Nessun elemento',
    );
    return '$_temp0';
  }

  @override
  String lastUpdated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Ultimo aggiornamento: $dateString';
  }
}
