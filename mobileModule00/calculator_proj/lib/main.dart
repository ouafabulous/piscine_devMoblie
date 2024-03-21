import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const Calculator());
}

class Calculator extends StatefulWidget {
  const Calculator({super.key});
  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  @override
  void initState() {
    super.initState();
  }

  String _result = '0';
  String _expression = "0";

  void calculate() {
    setState(() {
      Parser p = Parser();
      try {
        Expression exp = p.parse(_expression);
        ContextModel cm = ContextModel();
        double eval = exp.evaluate(EvaluationType.REAL, cm);
        _result = eval.toString();
        return;
      } catch (e) {
        print(e);
        _result = "ERROR";
      }
    });
  }

  void updateExpression(String input) {
    setState(() {
      if (input == "C") {
        if (_expression.length == 1) {
          _expression = "0";
          return;
        }
        _expression = _expression.substring(0, _expression.length - 1);
        return;
      }
      if (input == "AC") {
        _expression = "0";
        _result = '0';
        return;
      }
      if (input == "00") {
        if (_expression == "0") {
          return;
        }
        _expression += "00";
        return;
      }
      if (input == "=") {
        calculate();
        return;
      }
      if (_expression == "0" && input != "0") {
        _expression = input;
        return;
      }
      if (_expression == "0" && input == "0") {
        return;
      }

      if (_expression == "0") {
        _expression = input;
        return;
      }

      _expression += input;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.blue,
                title: const Center(child: Text('Calculator'))),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CalcScreen(result: _result, expression: _expression),
                ),
                CalcKeyboard(
                    calculate: calculate, updateExpression: updateExpression),
              ],
            )));
  }
}

class CalcScreen extends StatelessWidget {
  final String result;
  final String expression;

  const CalcScreen({super.key, required this.result, required this.expression});

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
                result.toString(),
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
                expression.toString(),
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
  final Function calculate;
  final Function updateExpression;

  const CalcKeyboard(
      {super.key, required this.calculate, required this.updateExpression});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double buttonPadding = screenWidth > 600 ? 12.0 : 8.0;
    final double ratio = screenWidth > 600 ? 7 : 1.0;

    // No need to pass buttonPadding to createButton method anymore.
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 5, // Keep the number of columns to 5
      childAspectRatio: ratio, // Maintain the button aspect ratio
      mainAxisSpacing: buttonPadding, // Dynamically adjust the spacing
      crossAxisSpacing: buttonPadding, // Dynamically adjust the spacing
      padding: EdgeInsets.all(buttonPadding), // Adjust the grid padding
      children:
          List.generate(20, (index) => createButton(getButtonLabel(index))),
    );
  }

  Widget createButton(String buttonText) {
    // Consistent padding for all buttons.
    return Column(children: [
      Flexible(
        child: ElevatedButton(
          onPressed: () {
            if (buttonText == '=') {
              calculate();
            } else {
              updateExpression(buttonText);
            }
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            // Let the button expand to fill the space instead of setting a minimum size
          ),
          child: FittedBox(
            // To adjust text size automatically
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 1, horizontal: 1), // Adjust inner padding if needed
              child: Text(buttonText),
            ),
          ),
        ),
      )
    ]);
  }

  String getButtonLabel(int index) {
    const labels = [
      '7',
      '8',
      '9',
      'C',
      'AC',
      '4',
      '5',
      '6',
      '/',
      '*',
      '1',
      '2',
      '3',
      '-',
      '+',
      '0',
      '.',
      '00',
      '=',
      '',
    ];
    // Your logic to return the button label based on index
    // Just as an example, returning index as string
    return labels[index];
  }
}
