import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../localization/language_constants.dart';
import '../screen/settings_screen.dart';
import '../state_management/general_provider.dart';
import 'item_drawer.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GeneralProvider>(context);

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Container(
            //   padding:
            //       const EdgeInsets.only(top: 20), // Reduce space above image
            //   child: Center(
            //     child: Image.asset(
            //       "assets/images/logo.png",
            //       width: 200, // Increase width to make the image larger
            //       height: 200, // Maintain aspect ratio with width
            //       fit: BoxFit.cover, // Make the image cover the area
            //     ),
            //   ),
            // ),
            DrawerItem(
              text: getTranslated(context, "Settings"),
              icon: Icon(
                Icons.settings,
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SettingsScreen()));
              },
              hint: '',
            ),

            // DrawerItem(
            //   text: getTranslated(context, "Theme Settings"),
            //   icon: Icon(Icons.settings, color: kDeepPurpleColor),
            //   onTap: () {
            //     Navigator.of(context).push(MaterialPageRoute(
            //         builder: (context) => ThemeSettingsScreen()));
            //   },
            //   hint: '',
            // ),
            // DrawerItem(
            //   text: getTranslated(context, "Language Settings"),
            //   icon: Icon(Icons.language, color: kDeepPurpleColor),
            //   onTap: () {
            //     Navigator.of(context).push(MaterialPageRoute(
            //         builder: (context) => LanguageSettings()));
            //   },
            //   hint: '',
            // ),
            // DrawerItem(
            //   text: getTranslated(context, "Arabic"),
            //   icon: Icon(Icons.language, color: kDeepPurpleColor),
            //   onTap: () async {
            //     SharedPreferences sharedPreferences =
            //         await SharedPreferences.getInstance();
            //     sharedPreferences.setString("Language", "ar");
            //     Locale newLocale = const Locale("ar", "SA");
            //     MyApp.setLocale(context, newLocale);
            //     Provider.of<GeneralProvider>(context, listen: false)
            //         .updateLanguage(false);
            //   },
            //   hint: "",
            // ),
            // DrawerItem(
            //   text: getTranslated(context, "English"),
            //   icon: Icon(Icons.language, color: kDeepPurpleColor),
            //   onTap: () async {
            //     SharedPreferences sharedPreferences =
            //         await SharedPreferences.getInstance();
            //     sharedPreferences.setString("Language", "en");
            //     Locale newLocale = const Locale("en", "SA");
            //     MyApp.setLocale(context, newLocale);
            //     Provider.of<GeneralProvider>(context, listen: false)
            //         .updateLanguage(true);
            //   },
            //   hint: '',
            // ),
            // DrawerItem(
            //     text: Provider.of<GeneralProvider>(context).isDarkMode
            //         ? getTranslated(context, "Light Mode")
            //         : getTranslated(context, "Dark Mode"), // Text for dark mode
            //     icon: Icon(
            //       Provider.of<GeneralProvider>(context).isDarkMode
            //           ? Icons.light_mode
            //           : Icons.dark_mode,
            //       color: kDeepPurpleColor,
            //     ),
            //     onTap: () {
            //       Provider.of<GeneralProvider>(context, listen: false)
            //           .toggleTheme();
            //     },
            //     hint: ''),
            // DrawerItem(
            //   text: getTranslated(context, "Logout"),
            //   icon: Icon(Icons.logout, color: kDeepPurpleColor),
            //   onTap: () {
            //     showLogoutConfirmationDialog(context, () async {
            //       await LogOutMethod().logOut(context);
            //     });
            //   },
            //   hint: '',
            // ),
          ],
        ),
      ),
    );
  }
}
