// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Flutter Riverpod クリーンアーキテクチャ';

  @override
  String get welcomeMessage => 'Flutter Riverpod クリーンアーキテクチャへようこそ';

  @override
  String get home => 'ホーム';

  @override
  String get settings => '設定';

  @override
  String get profile => 'プロフィール';

  @override
  String get darkMode => 'ダークモード';

  @override
  String get lightMode => 'ライトモード';

  @override
  String get systemMode => 'システムモード';

  @override
  String get language => '言語';

  @override
  String get change_language => 'アプリの言語を変更';

  @override
  String get theme => 'テーマ';

  @override
  String get change_theme => 'アプリのテーマを変更';

  @override
  String get notifications => '通知';

  @override
  String get notification_settings => '通知設定';

  @override
  String get localization_demo => 'ローカライズ デモ';

  @override
  String get localization_demo_description => '言語とフォーマットのローカリゼーション機能をデモ';

  @override
  String get language_settings => '言語設定';

  @override
  String get select_your_language => '言語を選択';

  @override
  String get language_explanation => '選択した言語はアプリ全体に適用されます';

  @override
  String get localization_assets_demo => 'ローカライズされたアセット デモ';

  @override
  String get current_language => '現在の言語';

  @override
  String get language_code => '言語コード';

  @override
  String get language_name => '言語名';

  @override
  String get formatting_examples => 'フォーマット例';

  @override
  String get date_full => '日付（完全）';

  @override
  String get date_short => '日付（短）';

  @override
  String get time => '時刻';

  @override
  String get currency => '通貨';

  @override
  String get percent => 'パーセント';

  @override
  String get localized_assets => 'ローカライズされたアセット';

  @override
  String get localized_assets_explanation =>
      '選択した言語に応じて異なる画像やリソースを読み込む方法を示します。';

  @override
  String get image_example => '画像の例';

  @override
  String get welcome_image_caption => '選択した言語に合わせてウェルカム画像が表示されます';

  @override
  String get common_image_example => '共通画像の例';

  @override
  String get common_image_caption => 'この画像はすべての言語で共有されます';

  @override
  String get logout => 'ログアウト';

  @override
  String get login => 'ログイン';

  @override
  String get email => 'メールアドレス';

  @override
  String get password => 'パスワード';

  @override
  String get signIn => 'サインイン';

  @override
  String get register => '登録';

  @override
  String get forgotPassword => 'パスワードをお忘れですか？';

  @override
  String get errorOccurred => 'エラーが発生しました';

  @override
  String get tryAgain => '再試行';

  @override
  String greeting(String name) {
    return 'こんにちは、$nameさん！';
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
      other: '$countString 件のアイテム',
      one: '1 件のアイテム',
      zero: 'アイテムがありません',
    );
    return '$_temp0';
  }

  @override
  String lastUpdated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '最終更新: $dateString';
  }
}
