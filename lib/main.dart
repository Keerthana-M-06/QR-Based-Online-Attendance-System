import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'web_qr_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    // 🔥 COMPLETE URL
    final fullUrl = Uri.base.toString();

    print("FULL URL = $fullUrl");

    // 🔥 CHECK IF QR LINK
    if (fullUrl.contains("/qr?sessionId=")) {

      final uri = Uri.base;
      final sessionId = uri.queryParameters['sessionId'];

      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: WebQRScreen(
          sessionId: sessionId!,
        ),
      );
    }

    // 🔥 NORMAL APP
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}