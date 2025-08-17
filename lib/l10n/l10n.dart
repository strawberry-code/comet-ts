import "package:flutter/widgets.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:intl/intl.dart";

import "app_localizations_delegate.dart";

/// Main class for handling localizations in the app
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale("en"), // English
    Locale("es"), // Spanish
    Locale("fr"), // French
    Locale("de"), // German
    Locale("ja"), // Japanese
    Locale("bn"), // Bengali
    Locale("it"), // Italian
  ];

  static bool isSupported(Locale locale) {
    return supportedLocales.contains(Locale(locale.languageCode));
  }

  /// Get a localized string by key
  String translate(String key) {
    final languageMap = localizedValues[locale.languageCode];
    if (languageMap == null) {
      return localizedValues["en"]?[key] ?? key;
    }
    return languageMap[key] ?? localizedValues["en"]?[key] ?? key;
  }

  /// Get a localized string with parameter substitution
  String translateWithParams(String key, Map<String, String> params) {
    String value = translate(key);
    params.forEach((paramKey, paramValue) {
      value = value.replaceAll("{$paramKey}", paramValue);
    });
    return value;
  }

  // Format methods for various data types

  /// Format currency with the current locale
  String formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: locale.toString(),
      symbol: getCurrencySymbol(),
    ).format(amount);
  }

  /// Format date with the current locale
  String formatDate(DateTime date) {
    return DateFormat.yMMMd(locale.toString()).format(date);
  }

  /// Format time with the current locale
  String formatTime(DateTime time) {
    return DateFormat.Hm(locale.toString()).format(time);
  }

  /// Get appropriate currency symbol based on locale
  String getCurrencySymbol() {
    switch (locale.languageCode) {
      case "es":
        return "€";
      case "ja":
        return "¥";
      case "bn":
        return "৳";
      default:
        return "\$";
    }
  }
}

// Simple translations map - shared between classes
final Map<String, Map<String, String>> localizedValues = {
  "en": {
    "app_title": "Flutter Riverpod Clean Architecture",
    "welcome_message": "Welcome to Flutter Riverpod Clean Architecture",
    "home": "Home",
    "settings": "Settings",
    "profile": "Profile",
    "dark_mode": "Dark Mode",
    "light_mode": "Light Mode",
    "system_mode": "System Mode",
    "language": "Language",
    "logout": "Logout",
    "login": "Login",
    "email": "Email",
    "password": "Password",
    "sign_in": "Sign In",
    "register": "Register",
    "forgot_password": "Forgot Password?",
    "error_occurred": "An error occurred",
    "try_again": "Try Again",
    "cancel": "Cancel",
    "save": "Save",
    "delete": "Delete",
    "edit": "Edit",
    "no_data": "No data available",
    "loading": "Loading...",
    "cache_expired": "Cache has expired",
    "cache_updated": "Cache updated successfully",
    "change_language": "Change Language",
    "theme": "Theme",
    "change_theme": "Change Theme",
    "notifications": "Notifications",
    "notification_settings": "Notification Settings",
    "edit_profile": "Edit Profile",
    "edit_profile_description": "Manage your profile information",
    "localization_demo": "Localization Demo",
    "localization_demo_description":
        "Demonstrates language and formatting localization features",
    "language_settings": "Language Settings",
    "select_your_language": "Select Your Language",
    "language_explanation":
        "Choose the language in which you'd like to use the app",
    "localization_assets_demo": "Localization Assets Demo",
    "current_language": "Current Language",
    "language_code": "Language Code",
    "language_name": "Language Name",
    "formatting_examples": "Formatting Examples",
    "date_full": "Full Date",
    "date_short": "Short Date",
    "time": "Time",
    "currency": "Currency",
    "percent": "Percent",
    "localized_assets": "Localized Assets",
    "localized_assets_explanation":
        "Examples of images and other assets that change based on language",
    "image_example": "Image Example",
    "welcome_image_caption": "A welcome image localized for your language",
    "common_image_example": "Common Image Example",
    "common_image_caption": "This image is shared across all languages",
  },
  "es": {
    "change_language": "Cambiar idioma",
    "theme": "Tema",
    "change_theme": "Cambiar tema",
    "notifications": "Notificaciones",
    "notification_settings": "Configuración de notificaciones",
    "edit_profile": "Editar Perfil",
    "edit_profile_description": "Gestionar información de tu perfil",
    "localization_demo": "Demostración de localización",
    "localization_demo_description":
        "Demuestra las funciones de localización de idioma y formato",
    "language_settings": "Configuración de idioma",
    "select_your_language": "Selecciona tu idioma",
    "language_explanation":
        "Elige el idioma en el que deseas usar la aplicación",
    "localization_assets_demo": "Demostración de recursos localizados",
    "current_language": "Idioma actual",
    "language_code": "Código de idioma",
    "language_name": "Nombre del idioma",
    "formatting_examples": "Ejemplos de formato",
    "date_full": "Fecha completa",
    "date_short": "Fecha corta",
    "time": "Hora",
    "currency": "Moneda",
    "percent": "Porcentaje",
    "localized_assets": "Recursos localizados",
    "localized_assets_explanation":
        "Ejemplos de imágenes y otros recursos que cambian según el idioma",
    "image_example": "Ejemplo de imagen",
    "welcome_image_caption":
        "Una imagen de bienvenida localizada para tu idioma",
    "common_image_example": "Ejemplo de imagen común",
    "common_image_caption": "Esta imagen se comparte entre todos los idiomas",
    "app_title": "Flutter Riverpod Arquitectura Limpia",
    "welcome_message": "Bienvenido a Flutter Riverpod Arquitectura Limpia",
    "home": "Inicio",
    "settings": "Configuraciones",
    "profile": "Perfil",
    "dark_mode": "Modo Oscuro",
    "light_mode": "Modo Claro",
    "system_mode": "Modo Sistema",
    "language": "Idioma",
    "logout": "Cerrar Sesión",
    "login": "Iniciar Sesión",
    "email": "Correo Electrónico",
    "password": "Contraseña",
    "sign_in": "Iniciar Sesión",
    "register": "Registrarse",
    "forgot_password": "¿Olvidó su Contraseña?",
    "error_occurred": "Ocurrió un error",
    "try_again": "Intentar de nuevo",
    "cancel": "Cancelar",
    "save": "Guardar",
    "delete": "Eliminar",
    "edit": "Editar",
    "no_data": "No hay datos disponibles",
    "loading": "Cargando...",
    "cache_expired": "El caché ha expirado",
    "cache_updated": "Caché actualizado con éxito",
  },
  "fr": {
    "change_language": "Changer la langue",
    "theme": "Thème",
    "change_theme": "Changer de thème",
    "notifications": "Notifications",
    "notification_settings": "Paramètres de notification",
    "edit_profile": "Modifier le Profil",
    "edit_profile_description": "Gérer vos informations de profil",
    "localization_demo": "Démo de localisation",
    "localization_demo_description":
        "Démontre les fonctionnalités de localisation de la langue et du formatage",
    "language_settings": "Paramètres de langue",
    "select_your_language": "Sélectionnez votre langue",
    "language_explanation":
        "Choisissez la langue que vous souhaitez utiliser dans l'application",
    "localization_assets_demo": "Démo des ressources localisées",
    "current_language": "Langue actuelle",
    "language_code": "Code langue",
    "language_name": "Nom de la langue",
    "formatting_examples": "Exemples de formatage",
    "date_full": "Date complète",
    "date_short": "Date courte",
    "time": "Heure",
    "currency": "Devise",
    "percent": "Pourcentage",
    "localized_assets": "Ressources localisées",
    "localized_assets_explanation":
        "Exemples d’images et d’autres ressources qui changent en fonction de la langue",
    "image_example": "Exemple d’image",
    "welcome_image_caption":
        "Une image de bienvenue localisée pour votre langue",
    "common_image_example": "Image commune",
    "common_image_caption": "Cette image est partagée entre toutes les langues",
    "app_title": "Flutter Riverpod Architecture Propre",
    "welcome_message": "Bienvenue sur Flutter Riverpod Architecture Propre",
    "home": "Accueil",
    "settings": "Paramètres",
    "profile": "Profil",
    "dark_mode": "Mode Sombre",
    "light_mode": "Mode Clair",
    "system_mode": "Mode Système",
    "language": "Langue",
    "logout": "Se déconnecter",
    "login": "Connexion",
    "email": "E-mail",
    "password": "Mot de passe",
    "sign_in": "Se connecter",
    "register": "S'inscrire",
    "forgot_password": "Mot de passe oublié ?",
    "error_occurred": "Une erreur s'est produite",
    "try_again": "Réessayer",
    "cancel": "Annuler",
    "save": "Enregistrer",
    "delete": "Supprimer",
    "edit": "Modifier",
    "no_data": "Aucune donnée disponible",
    "loading": "Chargement...",
    "cache_expired": "Le cache a expiré",
    "cache_updated": "Cache mis à jour avec succès",
  },
  "ja": {
    "app_title": "Flutter Riverpod クリーンアーキテクチャ",
    "welcome_message": "Flutter Riverpod クリーンアーキテクチャへようこそ",
    "home": "ホーム",
    "settings": "設定",
    "profile": "プロフィール",
    "dark_mode": "ダークモード",
    "light_mode": "ライトモード",
    "system_mode": "システムモード",
    "language": "言語",
    "logout": "ログアウト",
    "login": "ログイン",
    "email": "メールアドレス",
    "password": "パスワード",
    "sign_in": "サインイン",
    "register": "登録",
    "forgot_password": "パスワードをお忘れですか？",
    "error_occurred": "エラーが発生しました",
    "try_again": "再試行",
    "cancel": "キャンセル",
    "save": "保存",
    "delete": "削除",
    "edit": "編集",
    "no_data": "データがありません",
    "loading": "読み込み中...",
    "cache_expired": "キャッシュの有効期限が切れました",
    "cache_updated": "キャッシュが正常に更新されました",
    "change_language": "言語を変更",
    "theme": "テーマ",
    "change_theme": "テーマを変更",
    "notifications": "通知",
    "notification_settings": "通知設定",
    "edit_profile": "プロフィール編集",
    "edit_profile_description": "プロフィール情報を管理",
  },
  "de": {
    "app_title": "Flutter Riverpod Saubere Architektur",
    "welcome_message": "Willkommen bei Flutter Riverpod Saubere Architektur",
    "home": "Startseite",
    "settings": "Einstellungen",
    "profile": "Profil",
    "dark_mode": "Dunkler Modus",
    "light_mode": "Heller Modus",
    "system_mode": "Systemmodus",
    "language": "Sprache",
    "logout": "Abmelden",
    "login": "Anmelden",
    "email": "E-Mail",
    "password": "Passwort",
    "sign_in": "Einloggen",
    "register": "Registrieren",
    "forgot_password": "Passwort vergessen?",
    "error_occurred": "Ein Fehler ist aufgetreten",
    "try_again": "Erneut versuchen",
    "cancel": "Abbrechen",
    "save": "Speichern",
    "delete": "Löschen",
    "edit": "Bearbeiten",
    "no_data": "Keine Daten verfügbar",
    "loading": "Lädt...",
    "cache_expired": "Cache ist abgelaufen",
    "cache_updated": "Cache erfolgreich aktualisiert",
    "change_language": "Sprache ändern",
    "theme": "Thema",
    "change_theme": "Thema ändern",
    "notifications": "Benachrichtigungen",
    "notification_settings": "Benachrichtigungseinstellungen",
    "edit_profile": "Profil Bearbeiten",
    "edit_profile_description": "Profil-Informationen verwalten",
    "localization_demo": "Lokalisierungsdemo",
    "localization_demo_description":
        "Zeigt Sprach- und Formatierungsfunktionen",
    "language_settings": "Spracheinstellungen",
    "select_your_language": "Wähle deine Sprache",
    "language_explanation":
        "Wähle die Sprache, in der du die App verwenden möchtest",
    "localization_assets_demo": "Demo lokalisierter Ressourcen",
    "current_language": "Aktuelle Sprache",
    "language_code": "Sprachcode",
    "language_name": "Sprachname",
    "formatting_examples": "Formatierungsbeispiele",
    "date_full": "Vollständiges Datum",
    "date_short": "Kurzes Datum",
    "time": "Uhrzeit",
    "currency": "Währung",
    "percent": "Prozent",
    "localized_assets": "Lokalisierte Ressourcen",
    "localized_assets_explanation":
        "Beispiele für Bilder und andere Ressourcen, die sich je nach Sprache ändern",
    "image_example": "Bildbeispiel",
    "welcome_image_caption": "Ein Willkommensbild in Ihrer Sprache lokalisiert",
    "common_image_example": "Gemeinsames Bildbeispiel",
    "common_image_caption": "Dieses Bild wird in allen Sprachen verwendet",
  },
  "bn": {
    "app_title": "Flutter Riverpod পরিচ্ছন্ন স্থাপত্য",
    "welcome_message": "Flutter Riverpod পরিচ্ছন্ন স্থাপত্যে স্বাগতম",
    "home": "হোম",
    "settings": "সেটিংস",
    "profile": "প্রোফাইল",
    "dark_mode": "ডার্ক মোড",
    "light_mode": "লাইট মোড",
    "system_mode": "সিস্টেম মোড",
    "language": "ভাষা",
    "logout": "লগ আউট",
    "login": "লগ ইন",
    "email": "ইমেইল",
    "password": "পাসওয়ার্ড",
    "sign_in": "সাইন ইন",
    "register": "নিবন্ধন করুন",
    "forgot_password": "পাসওয়ার্ড ভুলে গেছেন?",
    "error_occurred": "একটি ত্রুটি ঘটেছে",
    "try_again": "আবার চেষ্টা করুন",
    "cancel": "বাতিল করুন",
    "save": "সংরক্ষণ করুন",
    "delete": "মুছে ফেলুন",
    "edit": "সম্পাদনা করুন",
    "no_data": "কোনো ডেটা পাওয়া যায়নি",
    "loading": "লোড হচ্ছে...",
    "cache_expired": "ক্যাশের মেয়াদ শেষ",
    "cache_updated": "ক্যাশ সফলভাবে আপডেট হয়েছে",
    "change_language": "ভাষা পরিবর্তন করুন",
    "theme": "থিম",
    "change_theme": "থিম পরিবর্তন করুন",
    "notifications": "বিজ্ঞপ্তি",
    "notification_settings": "বিজ্ঞপ্তির সেটিংস",
    "edit_profile": "প্রোফাইল সম্পাদনা",
    "edit_profile_description": "আপনার প্রোফাইল তথ্য পরিচালনা করুন",
    "localization_demo": "স্থানীয়করণ ডেমো",
    "localization_demo_description":
        "ভাষা ও ফরম্যাটিং লোকালাইজেশনের বৈশিষ্ট্য প্রদর্শন করে",
    "language_settings": "ভাষার সেটিংস",
    "select_your_language": "আপনার ভাষা নির্বাচন করুন",
    "language_explanation":
        "আপনি কোন ভাষায় অ্যাপটি ব্যবহার করতে চান তা নির্বাচন করুন",
    "localization_assets_demo": "লোকালাইজড অ্যাসেট ডেমো",
    "current_language": "বর্তমান ভাষা",
    "language_code": "ভাষার কোড",
    "language_name": "ভাষার নাম",
    "formatting_examples": "ফরম্যাটিং উদাহরণ",
    "date_full": "সম্পূর্ণ তারিখ",
    "date_short": "সংক্ষিপ্ত তারিখ",
    "time": "সময়",
    "currency": "মুদ্রা",
    "percent": "শতাংশ",
    "localized_assets": "লোকালাইজড অ্যাসেট",
    "localized_assets_explanation":
        "ভাষার উপর ভিত্তি করে পরিবর্তনশীল চিত্র এবং অন্যান্য অ্যাসেটের উদাহরণ",
    "image_example": "চিত্র উদাহরণ",
    "welcome_image_caption": "আপনার ভাষায় স্থানীয়কৃত একটি স্বাগত চিত্র",
    "common_image_example": "সাধারণ চিত্র উদাহরণ",
    "common_image_caption": "এই চিত্রটি সব ভাষার জন্য একই",
  },
  "it": {
    "app_title": "Flutter Riverpod Architettura Pulita",
    "welcome_message": "Benvenuto in Flutter Riverpod Architettura Pulita",
    "home": "Home",
    "settings": "Impostazioni",
    "profile": "Profilo",
    "dark_mode": "Modalità Scura",
    "light_mode": "Modalità Chiara",
    "system_mode": "Modalità Sistema",
    "language": "Lingua",
    "logout": "Disconnetti",
    "login": "Accedi",
    "email": "Email",
    "password": "Password",
    "sign_in": "Entra",
    "register": "Registrati",
    "forgot_password": "Hai dimenticato la password?",
    "error_occurred": "Si è verificato un errore",
    "try_again": "Riprova",
    "cancel": "Annulla",
    "save": "Salva",
    "delete": "Elimina",
    "edit": "Modifica",
    "no_data": "Nessun dato disponibile",
    "loading": "Caricamento...",
    "cache_expired": "La cache è scaduta",
    "cache_updated": "Cache aggiornata con successo",
    "change_language": "Cambia lingua",
    "theme": "Tema",
    "change_theme": "Cambia tema",
    "notifications": "Notifiche",
    "notification_settings": "Impostazioni notifiche",
    "edit_profile": "Modifica Profilo",
    "edit_profile_description": "Gestisci le informazioni del tuo profilo",
    "localization_demo": "Demo localizzazione",
    "localization_demo_description":
        "Dimostra le funzionalità di localizzazione di lingua e formattazione",
    "language_settings": "Impostazioni lingua",
    "select_your_language": "Seleziona la tua lingua",
    "language_explanation": "Scegli la lingua con cui desideri usare l'app",
    "localization_assets_demo": "Demo delle risorse localizzate",
    "current_language": "Lingua attuale",
    "language_code": "Codice lingua",
    "language_name": "Nome lingua",
    "formatting_examples": "Esempi di formattazione",
    "date_full": "Data completa",
    "date_short": "Data breve",
    "time": "Ora",
    "currency": "Valuta",
    "percent": "Percentuale",
    "localized_assets": "Risorse localizzate",
    "localized_assets_explanation":
        "Esempi di immagini e risorse che cambiano in base alla lingua",
    "image_example": "Esempio di immagine",
    "welcome_image_caption":
        "Immagine di benvenuto localizzata per la tua lingua",
    "common_image_example": "Immagine comune",
    "common_image_caption": "Questa immagine è condivisa tra tutte le lingue",
  },
  // Add translations for other supported languages
};

/// Extension on BuildContext for easier access to localization methods
extension LocalizationExtension on BuildContext {
  /// Get the AppLocalizations instance
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Translate a key to the current language
  String tr(String key) => l10n.translate(key);

  /// Translate a key with parameter substitution
  String trParams(String key, Map<String, String> params) =>
      l10n.translateWithParams(key, params);

  /// Format currency according to the current locale
  String currency(double amount) => l10n.formatCurrency(amount);

  /// Format date according to the current locale
  String formatDate(DateTime date) => l10n.formatDate(date);

  /// Format time according to the current locale
  String formatTime(DateTime time) => l10n.formatTime(time);
}
