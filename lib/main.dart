import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Calculator",
      theme: ThemeData.dark(),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String input = '';
  String result = '0';

  void buttonPressed(String value) {
    setState(() {
      if (value == "C") {
        input = '';
        result = '0';
      } else if (value == "=") {
        try {
          result = _evaluate(input).toString();
        } catch (e) {
          result = "Error";
        }
      } else {
        input += value;
      }
    });
  }

  double _evaluate(String expression) {
    Parser p = Parser();
    Expression exp = p.parse(expression);
    ContextModel cm = ContextModel();
    return exp.evaluate(EvaluationType.REAL, cm);
  }

  Widget buildButton(String text) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () => buttonPressed(text),
        child: Text(text, style: const TextStyle(fontSize: 32)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Simple Calculator"),),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(28),
              child: Text(
                "$input\n$result",
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          Row(children: [buildButton("7"), buildButton("8"), buildButton("9"), buildButton("/")]),
          Row(children: [buildButton("4"), buildButton("5"), buildButton("6"), buildButton("*")]),
          Row(children: [buildButton("1"), buildButton("2"), buildButton("3"), buildButton("-")]),
          Row(children: [buildButton("C"), buildButton("0"), buildButton("="), buildButton("+")]),
        ],
      ),
    );
  }
}
