import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:aurora/storage/storage.dart';
import 'package:aurora/storage/userStorage.dart';
import 'package:aurora/services/api_service.dart';
import 'package:aurora/pages/welcome/welcome.dart';
import 'package:aurora/pages/home.dart';
import 'package:aurora/pages/customers/customer_list.dart';
import 'package:aurora/pages/profile/profile.dart';
import 'package:aurora/pages/settings.dart';
import 'package:aurora/theme/theme_provider.dart';
import 'package:aurora/locale/locale_provider.dart';
import 'package:aurora/l10n/app_localizations.dart';
import 'package:aurora/supabase/supabase_auth.dart';
import 'package:aurora/supabase/supabase_config.dart';
import 'package:aurora/users/account_type.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Storage.init();

  if (!kIsWeb) {
    await _requestLocationPermission();
  }
  
  // Initialize Supabase
  SupabaseConfig.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SupabaseAuth()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => UserStorage()),
        ChangeNotifierProvider(create: (_) => ApiService()),
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

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;

    if (currentUser == null) {
      // No authenticated user, go to welcome/login page
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/welcome');
      }
      return;
    }

    // User is authenticated, check for stored account type and UUID
    final accountType = await Storage.getAccountType();
    final storedUserId = await Storage.getUserId();
    
    // If we have account type in storage, use it; otherwise determine from profile
    String? effectiveAccountType = accountType.isNotEmpty ? accountType : null;
    
    // Try to get account type from storage or determine it
    if (effectiveAccountType == null || effectiveAccountType.isEmpty) {
      // Check if user has seller profile
      final sellerProfile = await SupabaseConfig.getSellerByUserId(currentUser.id);
      if (sellerProfile != null) {
        effectiveAccountType = 'seller';
        await Storage.saveAccountType('seller');
      } else {
        // Check if user has factory profile
        final factoryProfile = await SupabaseConfig.getFactoryByUserId(currentUser.id);
        if (factoryProfile != null) {
          effectiveAccountType = 'factory';
          await Storage.saveAccountType('factory');
        }
      }
    }

    // Save user ID to storage
    await Storage.saveUserId(currentUser.id);

    if (effectiveAccountType == null || effectiveAccountType.isEmpty) {
      // No profile found, user needs to complete registration
      // Clear any stale data and redirect to welcome
      await Storage.clearUserData();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/welcome');
      }
      return;
    }

    final userStorage = Provider.of<UserStorage>(context, listen: false);

    try {
      // Load user profile based on account type
      await userStorage.loadUser(
        effectiveAccountType == 'factory' ? AccountType.factory : AccountType.seller,
      );

      // Fetch all sellers/factories and cache them in storage
      if (effectiveAccountType == 'seller') {
        await SupabaseConfig.fetchAndCacheAllSellers();
      } else if (effectiveAccountType == 'factory') {
        await SupabaseConfig.fetchAndCacheAllFactories();
        // Also fetch sellers for factories to interact with
        await SupabaseConfig.fetchAndCacheAllSellers();
      }
    } catch (e) {
      debugPrint('Error loading user or fetching data: $e');
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