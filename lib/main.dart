import 'package:ept/database/database.dart';
import 'package:ept/utils/appTheme.dart';
import 'package:ept/utils/localize.dart';
import 'package:ept/utils/routeObserver.dart';
import 'package:flutter/material.dart';
import '../pages/home/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().database;
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: getLocalizedString('appTitle'),
        theme: appTheme(),
        home: const HomePage(),
        navigatorObservers: [routeObserver]);
  }
}
