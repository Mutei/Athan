import 'package:athan/widgets/reused_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../state_management/general_provider.dart';
import '../localization/language_constants.dart';
import '../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GeneralProvider>(context);

    return Scaffold(
      appBar: ReusedAppBar(
        title: getTranslated(context, "Settings"),
      ),
      body: Column(
        children: [
          // Language Settings Section
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            child: Text(
              getTranslated(context, "Language Settings"),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: Text(
              getTranslated(context, "English"),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            trailing: Radio<bool>(
              value: true,
              groupValue: provider.CheckLangValue,
              onChanged: (value) async {
                if (value != null) {
                  SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  sharedPreferences.setString("Language", "en");
                  Locale newLocale = const Locale("en", "SA");
                  MyApp.setLocale(context, newLocale);
                  provider.updateLanguage(value);
                }
              },
              activeColor: Colors.green,
            ),
          ),
          ListTile(
            title: Text(
              getTranslated(context, "Arabic"),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            trailing: Radio<bool>(
              value: false,
              groupValue: provider.CheckLangValue,
              onChanged: (value) async {
                if (value != null) {
                  SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  sharedPreferences.setString("Language", "ar");
                  Locale newLocale = const Locale("ar", "SA");
                  MyApp.setLocale(context, newLocale);
                  provider.updateLanguage(value);
                }
              },
              activeColor: Colors.green,
            ),
          ),
          Divider(),

          // Theme Settings Section
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            child: Text(
              getTranslated(context, "Theme Settings"),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: Text(getTranslated(context, "System Mode")),
            trailing: Radio<ThemeModeType>(
              value: ThemeModeType.system,
              groupValue: provider.themeMode,
              onChanged: (value) {
                provider.toggleTheme(ThemeModeType.system);
              },
              activeColor: Colors.green,
            ),
          ),
          ListTile(
            title: Text(getTranslated(context, "Light Mode")),
            trailing: Radio<ThemeModeType>(
              value: ThemeModeType.light,
              groupValue: provider.themeMode,
              onChanged: (value) {
                provider.toggleTheme(ThemeModeType.light);
              },
              activeColor: Colors.green,
            ),
          ),
          ListTile(
            title: Text(getTranslated(context, "Dark Mode")),
            trailing: Radio<ThemeModeType>(
              value: ThemeModeType.dark,
              groupValue: provider.themeMode,
              onChanged: (value) {
                provider.toggleTheme(ThemeModeType.dark);
              },
              activeColor: Colors.green,
            ),
          ),

          // Call Center Section
        ],
      ),
    );
  }
}