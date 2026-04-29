import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:aurora/storage/storage.dart';
import 'package:aurora/storage/userStorage.dart';
import 'package:aurora/pages/welcome/welcome.dart';
import 'package:aurora/pages/home.dart';
import 'package:aurora/pages/profile/profile.dart';
import 'package:aurora/pages/settings.dart';
import 'package:aurora/theme/theme_provider.dart';
import 'package:aurora/locale/locale_provider.dart';
import 'package:aurora/l10n/app_localizations.dart';
import 'package:aurora/supabase/supabase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Storage.init();

  if (!kIsWeb) {
    await _requestLocationPermission();
  }
  
  Supabase.initialize(
    url: 'https://ofovfxsfazlwvcakpuer.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9mb3ZmeHNmYXpsd3ZjYWtwdWVyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIxMjY0MDcsImV4cCI6MjA4NzcwMjQwN30.QYx8-c9IiSMpuHeikKz25MKO5o6g112AKj4Tnr4aWzI',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SupabaseAuth()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => UserStorage()),
      ],
      child: const Aurora(),
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

class Aurora extends StatelessWidget {
  const Aurora({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final supabaseAuth = Provider.of<SupabaseAuth>(context);

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
      },
      home: supabaseAuth.isLoggedIn ? const Homepapge() : const WelcomePage(),
    );
  }
}