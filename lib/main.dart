import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/root_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_notifier.dart';
import 'providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'widgets/auth_state_wrapper.dart';

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
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'NetScope',
            theme: themeNotifier.currentTheme,
            initialRoute: '/',
            routes: {
              '/': (context) => AuthStateWrapper(),
              '/login': (context) => LoginScreen(),
              '/root': (context) => RootScreen(),
            },
          );
        },
      ),
    );
  }
}
