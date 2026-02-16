import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stateful Counter Activity',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CounterWidget(),
    );
  }
}

class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _counter = 0;
  static const int _maxCounter = 100;
  int _incrementStep = 1;
  final TextEditingController _incrementController = TextEditingController();
  final List<int> _history = [];
  final Set<int> _shownMilestones = <int>{};

  Color get counterColor {
    if (_counter == 0) return Colors.red;
    if (_counter > 50) return Colors.green;
    return Colors.black;
  }

  @override
  void initState() {
    super.initState();
    _incrementController.text = _incrementStep.toString();
  }

  @override
  void dispose() {
    _incrementController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showMilestoneDialog(int target) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Great job!'),
            content: Text('Congratulations! You reached $target.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }

  void _checkMilestone() {
    const targets = <int>{50, 100};
    if (targets.contains(_counter) && !_shownMilestones.contains(_counter)) {
      _shownMilestones.add(_counter);
      _showMilestoneDialog(_counter);
    }
  }

  void _applyCounterChange(int nextValue, {bool trackHistory = true}) {
    final int clampedValue = nextValue.clamp(0, _maxCounter);

    if (clampedValue == _counter) {
      if (nextValue > _maxCounter) {
        _showMessage('Maximum limit reached!');
      }
      return;
    }

    setState(() {
      if (trackHistory) {
        _history.add(_counter);
      }
      _counter = clampedValue;
    });

    if (nextValue > _maxCounter) {
      _showMessage('Maximum limit reached!');
    }

    _checkMilestone();
  }

  void _incrementCounter() {
    _applyCounterChange(_counter + _incrementStep);
  }

  void _decrementCounter() {
    _applyCounterChange(_counter - 1);
  }

  void _resetCounter() {
    _applyCounterChange(0);
  }

  void _undoCounter() {
    if (_history.isEmpty) {
      _showMessage('No history to undo.');
      return;
    }

    setState(() {
      _counter = _history.removeLast();
    });
  }

  void _setCustomIncrement() {
    final int? value = int.tryParse(_incrementController.text.trim());
    if (value == null || value <= 0) {
      _showMessage('Please enter a valid positive number.');
      return;
    }

    setState(() {
      _incrementStep = value;
    });

    _showMessage('Increment step set to +$_incrementStep.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stateful Counter Activity'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            children: [
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _incrementCounter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_counter',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: counterColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tap the counter or use the Increment button',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              Slider(
                min: 0,
                max: _maxCounter.toDouble(),
                value: _counter.toDouble(),
                onChanged: (double value) {
                  _applyCounterChange(value.toInt());
                },
                activeColor: Colors.blue,
                inactiveColor: Colors.red,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _incrementController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Custom increment',
                        hintText: 'Enter +2, +5, etc.',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: _setCustomIncrement,
                    child: const Text('Set'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Current increment step: +$_incrementStep'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton(
                    onPressed: _incrementCounter,
                    child: const Text('Increment'),
                  ),
                  FilledButton.tonal(
                    onPressed: _decrementCounter,
                    child: const Text('Decrement'),
                  ),
                  OutlinedButton(
                    onPressed: _resetCounter,
                    child: const Text('Reset'),
                  ),
                  OutlinedButton(
                    onPressed: _undoCounter,
                    child: const Text('Undo'),
                  ),
                ],
              ),
              if (_counter >= _maxCounter)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Maximum limit reached!',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 14),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Counter History (latest first)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _history.isEmpty
                    ? const Center(child: Text('No history yet'))
                    : ListView.builder(
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          final int reverseIndex = _history.length - 1 - index;
                          final int value = _history[reverseIndex];
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.history),
                            title: Text('Previous value: $value'),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
    );
  }
}
