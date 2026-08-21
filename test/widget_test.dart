import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:teethtech/src/app.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teethtech/src/services/storage_service.dart';
import 'package:teethtech/src/shared/wrappers/state_wrapper.dart';

void main() {
  testWidgets('App should build', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    await EasyLocalization.ensureInitialized();
    await dotenv.load(fileName: '.env');

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('es')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const StateWrapper(
          child: App(),
        ),
      ),
    );

    // Verify that our base app builds successfully.
    expect(find.byType(App), findsOneWidget);
  });
}
