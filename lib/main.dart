import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Beautiful Calculator",
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with TickerProviderStateMixin {
  String input = '';
  String result = '0';

  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void buttonPressed(String value) async {
    HapticFeedback.lightImpact();

    setState(() {
      if (value == "C") {
        input = '';
        result = '0';
      } else if (value == "=") {
        if (input.trim().isEmpty) return;

        try {
          String expression = input.replaceAll('×', '*').replaceAll('÷', '/').replaceAll('−', '-');
          double evalResult = _evaluate(expression);
          result = _formatResult(evalResult);

          // Animate result change
          _scaleController.forward().then((_) {
            _scaleController.reverse();
          });
        } catch (e) {
          result = "Error";
          // Shake animation for error
          _shakeController.forward().then((_) {
            _shakeController.reset();
          });
        }
      } else {
        // Replace operators with pretty symbols for display
        String displayValue = value;
        if (value == '*') displayValue = '×';
        if (value == '/') displayValue = '÷';
        if (value == '-') displayValue = '−';

        input += displayValue;
      }
    });
  }

  double _evaluate(String expression) {
    expression = expression.replaceAll(' ', '');

    if (!RegExp(r'^[0-9+\-*/.()]+$').hasMatch(expression)) {
      throw Exception('Invalid expression');
    }

    try {
      // Simple expression evaluator
      return _parseExpression(expression);
    } catch (e) {
      throw Exception('Calculation error');
    }
  }

  double _parseExpression(String expression) {
    // Simple recursive descent parser for basic arithmetic
    List<String> tokens = _tokenize(expression);
    return _parseAddSub(tokens);
  }

  List<String> _tokenize(String expression) {
    List<String> tokens = [];
    String current = '';

    for (int i = 0; i < expression.length; i++) {
      String char = expression[i];
      if ('+-*/()'.contains(char)) {
        if (current.isNotEmpty) {
          tokens.add(current);
          current = '';
        }
        tokens.add(char);
      } else {
        current += char;
      }
    }

    if (current.isNotEmpty) {
      tokens.add(current);
    }

    return tokens;
  }

  double _parseAddSub(List<String> tokens) {
    double result = _parseMulDiv(tokens);

    while (tokens.isNotEmpty && (tokens.first == '+' || tokens.first == '-')) {
      String operator = tokens.removeAt(0);
      double right = _parseMulDiv(tokens);

      if (operator == '+') {
        result += right;
      } else {
        result -= right;
      }
    }

    return result;
  }

  double _parseMulDiv(List<String> tokens) {
    double result = _parseNumber(tokens);

    while (tokens.isNotEmpty && (tokens.first == '*' || tokens.first == '/')) {
      String operator = tokens.removeAt(0);
      double right = _parseNumber(tokens);

      if (operator == '*') {
        result *= right;
      } else {
        if (right == 0) throw Exception('Division by zero');
        result /= right;
      }
    }

    return result;
  }

  double _parseNumber(List<String> tokens) {
    if (tokens.isEmpty) throw Exception('Unexpected end of expression');

    String token = tokens.removeAt(0);

    if (token == '(') {
      double result = _parseAddSub(tokens);
      if (tokens.isEmpty || tokens.removeAt(0) != ')') {
        throw Exception('Missing closing parenthesis');
      }
      return result;
    }

    return double.parse(token);
  }

  String _formatResult(double num) {
    if (num.isNaN || num.isInfinite) {
      return 'Error';
    }

    double rounded = (num * 100000000).round() / 100000000;

    if (rounded.abs() >= 1000000) {
      return rounded.toStringAsExponential(3);
    }

    if (rounded == rounded.toInt()) {
      return rounded.toInt().toString();
    }

    return rounded.toString();
  }

  Widget _buildButton(String text, {ButtonType type = ButtonType.number}) {
    Color backgroundColor = Colors.white.withOpacity(0.1);
    List<Color> gradientColors = [];

    switch (type) {
      case ButtonType.operator:
        gradientColors = [const Color(0xFFFF6B6B), const Color(0xFFEE5A24)];
        break;
      case ButtonType.clear:
        gradientColors = [const Color(0xFFA55EEA), const Color(0xFF8B5CF6)];
        break;
      case ButtonType.equals:
        gradientColors = [const Color(0xFF26DE81), const Color(0xFF20BF6B)];
        break;
      case ButtonType.number:
      // backgroundColor and gradientColors already initialized above
        break;
    }

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  gradient: gradientColors.isNotEmpty
                      ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  )
                      : null,
                  color: gradientColors.isEmpty ? backgroundColor : null,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      _pulseController.forward().then((_) {
                        _pulseController.reverse();
                      });
                      buttonPressed(text);
                    },
                    child: Center(
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Calculator',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Display
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value * math.sin(_shakeController.value * math.pi * 8), 0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              input.isEmpty ? '' : input,
                              style: TextStyle(
                                fontSize: 35,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 10),
                            AnimatedBuilder(
                              animation: _scaleAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: Text(
                                    result,
                                    style: const TextStyle(
                                      fontSize: 42,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w300,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          offset: Offset(0, 2),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 90),

                // Buttons
                Expanded(
                  child: Column(
                    children: [
                      Row(children: [

                        _buildButton("7"),
                        _buildButton("8"),
                        _buildButton("9"),
                        _buildButton("÷", type: ButtonType.operator),
                      ]),
                      Row(children: [

                        _buildButton("4"),
                        _buildButton("5"),
                        _buildButton("6"),
                        _buildButton("×", type: ButtonType.operator),
                      ]),
                      Row(children: [

                        _buildButton("1"),
                        _buildButton("2"),
                        _buildButton("3"),
                        _buildButton("−", type: ButtonType.operator),
                      ]),
                      Row(children: [
                        _buildButton("C", type: ButtonType.clear),
                        _buildButton("0"),
                        _buildButton("=", type: ButtonType.equals),
                        _buildButton("+", type: ButtonType.operator),

                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum ButtonType { number, operator, clear, equals }