// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Flutter Riverpod Arquitectura Limpia';

  @override
  String get welcomeMessage =>
      'Bienvenido a Flutter Riverpod Arquitectura Limpia';

  @override
  String get home => 'Inicio';

  @override
  String get settings => 'Configuraciones';

  @override
  String get profile => 'Perfil';

  @override
  String get darkMode => 'Modo Oscuro';

  @override
  String get lightMode => 'Modo Claro';

  @override
  String get systemMode => 'Modo Sistema';

  @override
  String get language => 'Idioma';

  @override
  String get change_language => 'Cambiar idioma de la aplicación';

  @override
  String get theme => 'Tema';

  @override
  String get change_theme => 'Cambiar tema de la aplicación';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get notification_settings => 'Configurar preferencias de notificación';

  @override
  String get edit_profile => 'Editar perfil';

  @override
  String get edit_profile_description => 'Administra tu información de perfil';

  @override
  String get localization_demo => 'Demostración de localización';

  @override
  String get localization_demo_description =>
      'Muestra las funciones de localización de idioma y formato en acción';

  @override
  String get language_settings => 'Configuración de idioma';

  @override
  String get select_your_language => 'Selecciona tu idioma';

  @override
  String get language_explanation =>
      'El idioma seleccionado se aplicará a toda la aplicación';

  @override
  String get localization_assets_demo => 'Demostración de recursos localizados';

  @override
  String get current_language => 'Idioma actual';

  @override
  String get language_code => 'Código de idioma';

  @override
  String get language_name => 'Nombre de idioma';

  @override
  String get formatting_examples => 'Ejemplos de formato';

  @override
  String get date_full => 'Fecha completa';

  @override
  String get date_short => 'Fecha corta';

  @override
  String get time => 'Hora';

  @override
  String get currency => 'Moneda';

  @override
  String get percent => 'Porcentaje';

  @override
  String get localized_assets => 'Recursos localizados';

  @override
  String get localized_assets_explanation =>
      'Esta sección muestra cómo cargar diferentes recursos según el idioma seleccionado. Imágenes, audio y otros recursos pueden variar.';

  @override
  String get image_example => 'Ejemplo de imagen localizada';

  @override
  String get welcome_image_caption =>
      'Una imagen de bienvenida localizada para tu idioma';

  @override
  String get common_image_example => 'Ejemplo de imagen común';

  @override
  String get common_image_caption =>
      'Esta imagen es la misma para todos los idiomas';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get register => 'Registrarse';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get errorOccurred => 'Ocurrió un error';

  @override
  String get tryAgain => 'Reintentar';

  @override
  String greeting(String name) {
    return '¡Hola, $name!';
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
      other: '$countString elementos',
      one: '1 elemento',
      zero: 'No hay elementos',
    );
    return '$_temp0';
  }

  @override
  String lastUpdated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Última actualización: $dateString';
  }
}
