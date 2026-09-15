import 'package:flutter/material.dart';
import 'login_page.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StreetLightApp());
}

class StreetLightApp extends StatelessWidget {
  const StreetLightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StreetLight Complaint System',

      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.amber,
        brightness: Brightness.light,
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.amber,
        brightness: Brightness.dark,
      ),

      themeMode: ThemeMode.system,

      // Login is now the first screen
      home: const LoginPage(),
    );
  }
}