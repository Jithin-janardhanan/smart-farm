import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_links/app_links.dart';
import 'package:smartfarm/theme.dart';
import 'package:smartfarm/view/reset_password_view.dart';
import 'package:smartfarm/view/splash.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();
    log(
      '✅ AppLinks initialized successfully',
    ); // 🔹 Log to confirm initialization

    // 🔹 Handle cold start (app opened from terminated state)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        log('📩 Initial deep link received: $initialUri');
        _handleDeepLink(initialUri, isColdStart: true);
      } else {
        log('ℹ️ No initial deep link detected.');
      }
    } catch (e) {
      log('❌ Error getting initial link: $e');
    }

    // 🔹 Handle links while app is running or in background
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        log('🔗 Deep link received via stream: $uri');
        _handleDeepLink(uri);
            },
      onError: (err) {
        log('⚠️ URI stream error: $err');
      },
    );
  }

  void _handleDeepLink(Uri uri, {bool isColdStart = false}) {
    // Example: https://iot.kkms.co.in/api/reset-password/Mjc/cysthz-xxxx/
    if (uri.pathSegments.contains('reset-password')) {
      final userId = uri.pathSegments.length > 2 ? uri.pathSegments[2] : '';
      final token = uri.pathSegments.length > 3 ? uri.pathSegments[3] : '';

      log('Navigating to ResetPasswordView: userId=$userId, token=$token');

      // Use WidgetsBinding to ensure navigation after build on cold start
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.to(() => ResetPasswordView(apiPath: uri.path));
      });
    } else {
      log('Unhandled deep link: $uri');
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Smart Farm',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: SplashScreen(),
    );
  }
}
