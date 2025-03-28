import 'package:flutter/material.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _Search();
}

class _Search extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
                onLongPress: () => {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Long Pressed')))
                    },
                child: const Text('Expense',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ))),
          ],
        ));
  }
}
