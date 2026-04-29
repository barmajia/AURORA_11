import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aurora/core/l10n/app_localizations.dart';
import 'package:aurora/core/theme/theme_provider.dart';
import 'package:aurora/core/locale/locale_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(appBar: AppBar(title: Text(localizations.settings)),
      body: ListView(children: [
        ListTile(title: Text(localizations.theme),
          trailing: DropdownButton<int>(
            value: context.watch<ThemeProvider>().themeIndex,
            items: [DropdownMenuItem(value: 0, child: Text(localizations.lightTheme1)),
              DropdownMenuItem(value: 1, child: Text(localizations.lightTheme2)),
              DropdownMenuItem(value: 2, child: Text(localizations.darkTheme1)),
              DropdownMenuItem(value: 3, child: Text(localizations.darkTheme2))],
            onChanged: (value) { if (value != null) context.read<ThemeProvider>().setTheme(value); },
          ),
        ),
        ListTile(title: Text(localizations.language),
          trailing: DropdownButton<Locale>(
            value: context.watch<LocaleProvider>().locale,
            items: [DropdownMenuItem(value: const Locale('en'), child: Text(localizations.english)),
              DropdownMenuItem(value: const Locale('ar'), child: Text(localizations.arabic))],
            onChanged: (value) { if (value != null) context.read<LocaleProvider>().setLocale(value); },
          ),
        ),
      ]),
    );
  }
}
