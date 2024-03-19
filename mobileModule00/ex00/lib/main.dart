import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: Scaffold(
      body: MainBody()
    ),
  ));
}

class MainBody extends StatelessWidget {
  const MainBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text(
          'Hello, World2!',
          style: TextStyle(backgroundColor: Colors.purple),
        ),
        TextButton(
          onPressed: () => print('Button clicked!'),
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.purple)),
          child: const Text('Click me!'),
        )
      ]));
  }


}