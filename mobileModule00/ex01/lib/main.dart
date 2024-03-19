import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: Scaffold(body: MainBody()),
  ));
}

class MainBody extends StatefulWidget {
  const MainBody({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MainBodyState();
  }
}

class _MainBodyState extends State<MainBody> {
  String text = "A simple text";

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(
        text,
        style: const TextStyle(backgroundColor: Colors.purple),
      ),
      TextButton(
        onPressed: () {
          print('Button pressed!');
          setState(() {
            text = text == "A simple text" ? "Hello World" : "A simple text";
          });
        },
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.purple)),
        child: const Text('Click me'),
      )
    ]));
  }
}
