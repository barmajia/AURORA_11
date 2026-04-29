import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:aurora/core/storage.dart';
import 'package:aurora/core/config/supabase_config.dart';
import 'package:aurora/core/supabase/supabase_config.dart';
import 'package:aurora/core/userStorage.dart';
import 'package:aurora/core/theme/theme_provider.dart';
import 'package:aurora/core/locale/locale_provider.dart';
import 'package:aurora/core/l10n/app_localizations.dart';
import 'package:aurora/core/account_type.dart';
import 'package:aurora/presentation/welcome/pages/welcome.dart';
import 'package:aurora/presentation/home/home.dart';
import 'package:aurora/presentation/customers/pages/customer_list.dart';
import 'package:aurora/presentation/products/pages/product_list.dart';
import 'package:aurora/presentation/profile/pages/profile.dart';
import 'package:aurora/presentation/settings/pages/settings.dart';
import 'package:aurora/presentation/auth/sellers/login.dart';
import 'package:aurora/presentation/auth/sellers/signup.dart';
import 'package:aurora/presentation/auth/factories/login.dart' as factory_auth;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Storage.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..init()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()..init()),
        ChangeNotifierProvider(create: (_) => UserStorage()),
        ChangeNotifierProvider(create: (_) => SupabaseProvider()),
      ],
      child: const AuroraApp(),
    ),
  );
}

class AuroraApp extends StatelessWidget {
  const AuroraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aurora',
      theme: themeProvider.theme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: localeProvider.locale,
      routes: {
        '/settings': (context) => const SettingsPage(),
        '/profile': (context) => const ProfilePage(),
        '/welcome': (context) => const WelcomePage(),
        '/home': (context) => const Homepapge(),
        '/customers': (context) => const CustomerListPage(),
        '/products': (context) => const ProductListPage(),
        '/seller-login': (context) => const SellerLoginPage(),
        '/seller-signup': (context) => const SellerSignupPage(),
        '/factory-login': (context) => const factory_auth.FactoryLoginPage(),
      },
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  bool _supabaseReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _deferredInit();
    _checkAuthAndNavigate();
  }

  Future<void> _deferredInit() async {
    final supabaseProvider = Provider.of<SupabaseProvider>(context, listen: false);
    await supabaseProvider.init(url: SupabaseConfig.url, anonKey: SupabaseConfig.anonKey);
    if (mounted) setState(() => _supabaseReady = true);
    if (!kIsWeb) {
      _requestLocationPermission();
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied)
        permission = await Geolocator.requestPermission();
      await Permission.location.request();
      await Permission.locationAlways.request();
    } catch (e) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final userStorage = Provider.of<UserStorage>(context, listen: false);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      userStorage.clearCache();
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    while (!_supabaseReady) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    final userStorage = Provider.of<UserStorage>(context, listen: false);
    final currentUser = userStorage.currentUser;
    final isLoggedIn = userStorage.isLoggedIn;
    if (!isLoggedIn || currentUser == null) {
      if (mounted) Navigator.of(context).pushReplacementNamed('/welcome');
      return;
    }
    if (mounted) Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.storefront, size: 100, color: Color(0xFF6366F1)),
            const SizedBox(height: 24),
            const Text(
              'Aurora',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
