import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:aurora/storage/storage.dart';
import 'package:aurora/storage/userStorage.dart';
import 'package:aurora/pages/welcome/welcome.dart';
import 'package:aurora/pages/home.dart';
import 'package:aurora/pages/customers/customer_list.dart';
import 'package:aurora/pages/profile/profile.dart';
import 'package:aurora/pages/settings.dart';
import 'package:aurora/theme/theme_provider.dart';
import 'package:aurora/locale/locale_provider.dart';
import 'package:aurora/l10n/app_localizations.dart';
import 'package:aurora/users/account_type.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Storage.init();

  if (!kIsWeb) {
    await _requestLocationPermission();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => UserStorage()),
      ],
      child: const AuroraApp(),
    ),
  );
}

Future<void> _requestLocationPermission() async {
  try {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    await Permission.location.request();
    await Permission.locationAlways.request();
  } catch (e) {}
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

class _SplashScreenState extends State<SplashScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final userStorage = Provider.of<UserStorage>(context, listen: false);
    
    // Clear cached data when app is paused (app closed/minimized)
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.detached) {
      userStorage.clearCache();
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final userStorage = Provider.of<UserStorage>(context, listen: false);
    final currentUser = userStorage.currentUser;
    final isLoggedIn = userStorage.isLoggedIn;

    // Wait a bit for user data to load from vault
    await Future.delayed(const Duration(milliseconds: 300));

    if (!isLoggedIn || currentUser == null) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/welcome');
      }
      return;
    }

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.storefront,
              size: 100,
              color: Color(0xFF6366F1),
            ),
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
