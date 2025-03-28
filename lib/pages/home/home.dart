import 'package:flutter/material.dart';
import 'components/dashboard.home.dart';
import 'components/header.home.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
        child: Scaffold(
            backgroundColor: Colors.black,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Header(), Dashboard()],
            )));
  }
}
