// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Flutter Riverpod Architecture Propre';

  @override
  String get welcomeMessage =>
      'Bienvenue sur Flutter Riverpod Architecture Propre';

  @override
  String get home => 'Accueil';

  @override
  String get settings => 'Paramètres';

  @override
  String get profile => 'Profil';

  @override
  String get darkMode => 'Mode Sombre';

  @override
  String get lightMode => 'Mode Clair';

  @override
  String get systemMode => 'Mode Système';

  @override
  String get language => 'Langue';

  @override
  String get change_language => 'Changer la langue de l\'application';

  @override
  String get theme => 'Thème';

  @override
  String get change_theme => 'Changer le thème de l\'application';

  @override
  String get notifications => 'Notifications';

  @override
  String get notification_settings =>
      'Configurer les préférences de notification';

  @override
  String get localization_demo => 'Démo de localisation';

  @override
  String get localization_demo_description =>
      'Affiche les fonctionnalités de localisation en action';

  @override
  String get language_settings => 'Paramètres de langue';

  @override
  String get select_your_language => 'Sélectionnez la langue souhaitée';

  @override
  String get language_explanation =>
      'La langue sélectionnée sera appliquée à toute l\'application';

  @override
  String get localization_assets_demo => 'Démo des ressources localisées';

  @override
  String get current_language => 'Langue actuelle';

  @override
  String get language_code => 'Code langue';

  @override
  String get language_name => 'Nom de la langue';

  @override
  String get formatting_examples => 'Exemples de formatage';

  @override
  String get date_full => 'Date complète';

  @override
  String get date_short => 'Date courte';

  @override
  String get time => 'Heure';

  @override
  String get currency => 'Devise';

  @override
  String get percent => 'Pourcentage';

  @override
  String get localized_assets => 'Ressources localisées';

  @override
  String get localized_assets_explanation =>
      'Cette section montre comment charger différentes ressources en fonction de la langue sélectionnée. Images, audio et autres ressources peuvent varier selon la langue.';

  @override
  String get image_example => 'Exemple d’image localisée';

  @override
  String get welcome_image_caption =>
      'Cette image est chargée en fonction de la langue sélectionnée';

  @override
  String get common_image_example => 'Exemple d’image commune';

  @override
  String get common_image_caption =>
      'Cette image est identique pour toutes les langues';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get login => 'Connexion';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get signIn => 'Se connecter';

  @override
  String get register => 'S’inscrire';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get errorOccurred => 'Une erreur s’est produite';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String greeting(String name) {
    return 'Bonjour, $name !';
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
      other: '$countString éléments',
      one: '1 élément',
      zero: 'Aucun élément',
    );
    return '$_temp0';
  }

  @override
  String lastUpdated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Dernière mise à jour : $dateString';
  }
}
