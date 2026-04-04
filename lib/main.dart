import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'models/listas_provider.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/auth_service.dart';
import 'services/drive_backup_service.dart';
import 'services/hive_service.dart';
import 'services/home_widget_service.dart';
import 'models/iap_provider.dart';

/// Chave global do Navigator para acessar context no WidgetsBindingObserver.
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // ── Firebase / Crashlytics ────────────────────────────────────────────────
  await Firebase.initializeApp();

  // Em modo release: envia crashes Flutter para o Crashlytics
  // Em debug: apenas imprime no console, sem poluir o painel
  if (!kDebugMode) {
    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
  // ─────────────────────────────────────────────────────────────────────────

  await HiveService.init();
  await HomeWidgetService.init();
  Intl.defaultLocale = 'pt_BR';

  FlutterNativeSplash.remove();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ListasProvider()),
        ChangeNotifierProvider(create: (_) => IapProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool get _onboardingCompleto =>
      HiveService.obterConfiguracao<bool>('onboarding_completo') ?? false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AuthService.signInSilently();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        final provider = Provider.of<ListasProvider>(ctx, listen: false);
        DriveBackupService.uploadBackupSilently(provider.listas);
        HomeWidgetService.atualizar(provider.listas);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Não Esquece!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          dividerColor: Colors.transparent,
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      home: _onboardingCompleto
          ? const HomeScreen()
          : OnboardingScreen(
              onComplete: () {
                navigatorKey.currentState?.pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
            ),
    );
  }
}
