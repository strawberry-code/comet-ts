// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'Flutter Riverpod পরিচ্ছন্ন স্থাপত্য';

  @override
  String get welcomeMessage => 'Flutter Riverpod পরিচ্ছন্ন স্থাপত্যে স্বাগতম';

  @override
  String get home => 'হোম';

  @override
  String get settings => 'সেটিংস';

  @override
  String get profile => 'প্রোফাইল';

  @override
  String get darkMode => 'ডার্ক মোড';

  @override
  String get lightMode => 'লাইট মোড';

  @override
  String get systemMode => 'সিস্টেম মোড';

  @override
  String get language => 'ভাষা';

  @override
  String get change_language => 'অ্যাপের ভাষা পরিবর্তন করুন';

  @override
  String get theme => 'থিম';

  @override
  String get change_theme => 'অ্যাপের থিম পরিবর্তন করুন';

  @override
  String get notifications => 'বিজ্ঞপ্তি';

  @override
  String get notification_settings => 'বিজ্ঞপ্তির সেটিংস';

  @override
  String get edit_profile => 'প্রোফাইল সম্পাদনা করুন';

  @override
  String get edit_profile_description => 'আপনার প্রোফাইল তথ্য পরিচালনা করুন';

  @override
  String get localization_demo => 'স্থানীয়করণ ডেমো';

  @override
  String get localization_demo_description =>
      'ভাষা ও ফরম্যাটিং লোকালাইজেশনের বৈশিষ্ট্য প্রদর্শন করে';

  @override
  String get language_settings => 'ভাষার সেটিংস';

  @override
  String get select_your_language => 'আপনার পছন্দের ভাষা নির্বাচন করুন';

  @override
  String get language_explanation => 'নির্বাচিত ভাষা পুরো অ্যাপে প্রযোজ্য হবে';

  @override
  String get localization_assets_demo => 'লোকালাইজড রিসোর্স ডেমো';

  @override
  String get current_language => 'বর্তমান ভাষা';

  @override
  String get language_code => 'ভাষা কোড';

  @override
  String get language_name => 'ভাষার নাম';

  @override
  String get formatting_examples => 'ফরম্যাটিং উদাহরণ';

  @override
  String get date_full => 'সম্পূর্ণ তারিখ';

  @override
  String get date_short => 'সংক্ষিপ্ত তারিখ';

  @override
  String get time => 'সময়';

  @override
  String get currency => 'মুদ্রা';

  @override
  String get percent => 'শতাংশ';

  @override
  String get localized_assets => 'লোকালাইজড রিসোর্স';

  @override
  String get localized_assets_explanation =>
      'নির্বাচিত ভাষা অনুযায়ী বিভিন্ন সম্পদ লোড করার উদাহরণ দেখায়।';

  @override
  String get image_example => 'চিত্র উদাহরণ';

  @override
  String get welcome_image_caption =>
      'নির্বাচিত ভাষা অনুযায়ী স্বাগতম চিত্র দেখানো হয়';

  @override
  String get common_image_example => 'সাধারণ চিত্র উদাহরণ';

  @override
  String get common_image_caption => 'এই চিত্রটি সব ভাষার জন্য একই';

  @override
  String get logout => 'লগ আউট';

  @override
  String get login => 'লগ ইন';

  @override
  String get email => 'ইমেইল';

  @override
  String get password => 'পাসওয়ার্ড';

  @override
  String get signIn => 'সাইন ইন';

  @override
  String get register => 'নিবন্ধন করুন';

  @override
  String get forgotPassword => 'পাসওয়ার্ড ভুলে গেছেন?';

  @override
  String get errorOccurred => 'একটি ত্রুটি ঘটেছে';

  @override
  String get tryAgain => 'আবার চেষ্টা করুন';

  @override
  String greeting(String name) {
    return 'হ্যালো, $name!';
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
      other: '$countString আইটেম',
      one: '1 আইটেম',
      zero: 'কোনও আইটেম নেই',
    );
    return '$_temp0';
  }

  @override
  String lastUpdated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'শেষ আপডেট: $dateString';
  }
}
