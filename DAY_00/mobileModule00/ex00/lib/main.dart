import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text(
          'Hello, World2!',
          style: TextStyle(backgroundColor: Colors.purple),
        ),
        TextButton(
          onPressed: () => print('Button clicked!'),
          child: const Text('Click me!'),
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.purple)),
        )
      ])),
    ),
  ));
}
