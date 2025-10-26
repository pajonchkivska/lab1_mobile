import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magic Counter',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const CounterPage(),
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _counter = 0;
  final TextEditingController _controller = TextEditingController();

  void _increment() {
    setState(() => _counter++);
  }

  void _processInput() {
    final input = _controller.text.trim();

    if (input.toLowerCase() == 'avada kedavra') {
      setState(() => _counter = 0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('💥 Spell casted! Counter reset.')),
      );
    } else if (int.tryParse(input) != null) {
      setState(() => _counter += int.parse(input));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Enter a number or "Avada Kedavra"!')),
      );
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Magic Counter 🪄'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  '$_counter',
                  style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                labelText: 'Enter number or "Avada Kedavra"',
                prefixIcon: const Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _increment,
                  icon: const Icon(Icons.add),
                  label: const Text('Increment'),
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
                ElevatedButton.icon(
                  onPressed: _processInput,
                  icon: const Icon(Icons.check),
                  label: const Text('Apply Input'),
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              '💡 Tips:\n'
              '- Enter a number to add to the counter.\n'
              '- Enter "Avada Kedavra" to reset.\n'
              '- Press "Increment" to increase by 1.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
