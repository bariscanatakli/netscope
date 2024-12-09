import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Add this line for localization
import 'firebase_options.dart';
import 'package:logging/logging.dart';
import 'package:netscope/screens/login_screen.dart';
import 'package:netscope/screens/route_details_screen.dart'; // Add this line

void main() async {
  // Initialize logging configuration here
  Logger.root.level = Level.ALL; // Set the logging level
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(NetScopeApp());
}

class NetScopeApp extends StatelessWidget {
  const NetScopeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NetScope',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(),
      routes: {
        '/routeDetails': (context) =>
            const RouteDetailsScreen(), // Add this line
      },
      localizationsDelegates: [
        // Add this block for localization
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        // Add this block for localization
        const Locale('en', ''), // English
        // Add other supported locales here
      ],
    );
  }
}
