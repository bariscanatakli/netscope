import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_notifier.dart'; // Add this line to import ThemeNotifier
import 'screens/map/traceroute_model.dart'; // Add this line to import the TracerouteModel

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TracerouteModel()),
        ChangeNotifierProvider(
            create: (_) =>
                ThemeNotifier()), // Add this line to provide ThemeNotifier
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            title: 'NetScope',
            theme: themeNotifier.currentTheme,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('en', ''), // English
              const Locale('tr', ''), // Turkish
            ],
            home: LoginScreen(),
            routes: {
              '/home': (context) => HomeScreen(),
              // Add other routes here
            },
          );
        },
      ),
    );
  }
}
