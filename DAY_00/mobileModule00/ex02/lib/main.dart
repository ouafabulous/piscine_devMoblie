import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
      home: Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.blue,
              title: const Center(child: Text('Calculator'))),
          body: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: CalcScreen(),
              ),
              SizedBox(height: 8.0), // Add this SizedBox for spacing
              CalcKeyboard(), // Remove the Expanded widget around CalcKeyboard
            ],
          ))));
}

class CalcScreen extends StatefulWidget {
  const CalcScreen({super.key});

  @override
  State<CalcScreen> createState() => _CalcScreenState();
}

class _CalcScreenState extends State<CalcScreen> {
  String text = "0";

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 1,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.grey,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 40,
                ),
              ),
            ),
            const Divider(
              color: Colors.black,
              height: 1,
              thickness: 1,
              indent: 0,
              endIndent: 0,
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CalcKeyboard extends StatelessWidget {
  const CalcKeyboard({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 5, // Number of columns in the grid
      childAspectRatio: 1.0, // Aspect ratio of each button
      mainAxisSpacing: 8.0, // Space between rows
      crossAxisSpacing: 8.0, // Space between columns
      padding: const EdgeInsets.all(8.0), // Add padding around the grid
      children: [
        ...createButton('7'),
        ...createButton('8'),
        ...createButton('9'),
        ...createButton('C'),
        ...createButton('AC'),
        ...createButton('4'),
        ...createButton('5'),
        ...createButton('6'),
        ...createButton('/'),
        ...createButton('*'),
        ...createButton('1'),
        ...createButton('2'),
        ...createButton('3'),
        ...createButton('-'),
        ...createButton('+'),
        ...createButton('0'),
        ...createButton('.'),
        ...createButton('00'),
        ...createButton('='),
        ...createButton('')
      ],
    );
  }

  List<Widget> createButton(String buttonText) {
    return [
      GridTile(
        child: ElevatedButton(
          onPressed: () {
            print('Button pressed: $buttonText');
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(
                double.infinity,
                double
                    .infinity), // This will expand the button to fill the available space
          ),
          child: Text(buttonText),
        ),
      ),
    ];
  }
}
