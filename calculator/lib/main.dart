comsaaat

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Calculator',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _input = '';
  String _result = '';

  void _buttonPressed(String value) {
    setState(() {
      if (value == 'AC') {
        if (_input.isNotEmpty) {
          _input = _input.substring(0, _input.length - 1);
        } else {
          _input = '';
          _result = '';
        }
      } else if (value == '+/-') {
        if (_input.isNotEmpty) {
          RegExp reg = RegExp(r'([\-]?\d+\.?\d*)$');
          var match = reg.firstMatch(_input);
          if (match != null) {
            String lastNum = match.group(0)!;
            String toggled = lastNum.startsWith('-')
                ? lastNum.substring(1)
                : '-$lastNum';
            _input = _input.substring(0, match.start) + toggled;
          }
        }
      } else if (value == '%') {
        if (_input.isNotEmpty) {
          RegExp reg = RegExp(r'(\d+\.?\d*)$');
          var match = reg.firstMatch(_input);
          if (match != null) {
            String lastNum = match.group(0)!;
            double percent = double.tryParse(lastNum) ?? 0;
            percent = percent / 100;
            _input = _input.substring(0, match.start) + percent.toString();
          }
        }
      } else if (value == '=') {
        try {
          _result = _calculateResult(_input);
        } catch (e) {
          _result = 'Error';
        }
      } else {
        _input += value;
      }
    });
  }

  String _calculateResult(String input) {
    try {
      String finalInput = input.replaceAll('×', '*').replaceAll('÷', '/');
      double res = _evaluate(finalInput);
      if (res % 1 == 0) {
        return res.toInt().toString();
      }
      return res.toString();
    } catch (e) {
      return 'Error';
    }
  }

  double _evaluate(String expr) {
    List<String> tokens = [];
    String number = '';
    for (int i = 0; i < expr.length; i++) {
      String ch = expr[i];
      if ('0123456789.'.contains(ch)) {
        number += ch;
      } else if ('+-*/'.contains(ch)) {
        if (number.isNotEmpty) {
          tokens.add(number);
          number = '';
        }
        tokens.add(ch);
      }
    }
    if (number.isNotEmpty) tokens.add(number);

    double result = double.parse(tokens[0]);
    for (int i = 1; i < tokens.length; i += 2) {
      String op = tokens[i];
      double num = double.parse(tokens[i + 1]);
      if (op == '+') result += num;
      if (op == '-') result -= num;
      if (op == '*') result *= num;
      if (op == '/') result /= num;
    }
    return result;
  }

  Widget _buildButton(
    String text, {
    Color? color,
    Color? textColor,
    int flex = 1,
    bool isBig = false,
    double? fontSize,
  }) {
    return Expanded(
      flex: flex,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double size = constraints.maxWidth < constraints.maxHeight
              ? constraints.maxWidth
              : constraints.maxHeight;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            child: SizedBox(
              height: size,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: color ?? Colors.grey[200],
                  foregroundColor: textColor ?? Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(size * 0.25),
                  ),
                  padding: EdgeInsets.zero,
                ),
                onPressed: text.isEmpty ? null : () => _buttonPressed(text),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize ?? size * 0.32,
                    color:
                        textColor ??
                        (color == Colors.white ? Colors.black : Colors.white),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // iOS style colors
    const Color opColor = Color(0xFFFF9500);
    const Color funcColor = Color(0xFFA5A5A5);
    const Color numColor = Color(0xFF333333);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double buttonFontSize = constraints.maxWidth * 0.07;
            return Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.bottomRight,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          child: Text(
                            _input,
                            style: TextStyle(
                              fontSize: constraints.maxWidth * 0.08,
                              color: const Color(0xFF888888),
                            ),
                            maxLines: 1,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          child: Text(
                            _result,
                            style: TextStyle(
                              fontSize: constraints.maxWidth * 0.13,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Make the button area flexible to avoid overflow
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            _buildButton(
                              'AC',
                              color: funcColor,
                              textColor: Colors.black,
                              fontSize: buttonFontSize,
                            ),
                            _buildButton(
                              '+/-',
                              color: funcColor,
                              textColor: Colors.black,
                              fontSize: buttonFontSize,
                            ),
                            _buildButton(
                              '%',
                              color: funcColor,
                              textColor: Colors.black,
                              fontSize: buttonFontSize,
                            ),
                            _buildButton(
                              '+',
                              color: opColor,
                              fontSize: buttonFontSize,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            _buildButton(
                              '7',
                              color: numColor,
                              fontSize: buttonFontSize,
                            ),
                            _buildButton(
                              '8',
                              color: numColor,
                              fontSize: buttonFontSize,
                            ),
                            _buildButton(
                              '9',
                              color: numColor,
                              fontSize: buttonFontSize,
                            ),
                            _buildButton(
                              '÷',
                              color: opColor,
                              fontSize: buttonFontSize,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            _buildButton(
                              '4',
                              color: numColor,
                              fontSize: buttonFontSize,
                            ),
                            _buildButton(
                              '5',
                              color: numColor,
                              fontSize: buttonFontSize,
                            ),
                            _buildButton(
                              '6',
                              color: numColor,
                              fontSize: buttonFontSize,
                            ),
                            _buildButton(
                              '×',
                              color: opColor,
                              fontSize: buttonFontSize,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            _buildButton(
                              '1',
                              color: numColor,
                              fontSize: buttonFontSize,
                            ),
                            _buildButton(
                              '2',
                              color: numColor,
                              fontSize: buttonFontSize,
                            ),
                            _buildButton(
                              '3',
                              color: numColor,
                              fontSize: buttonFontSize,
                            ),
                            _buildButton(
                              '-',
                              color: opColor,
                              fontSize: buttonFontSize,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            _buildButton(
                              '0',
                              color: numColor,
                              flex: 2,
                              isBig: true,
                              fontSize: buttonFontSize,
                            ),
                            _buildButton(
                              '.',
                              color: numColor,
                              fontSize: buttonFontSize,
                            ),
                            _buildButton(
                              '=',
                              color: opColor,
                              fontSize: buttonFontSize,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
