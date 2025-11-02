import 'package:flutter/material.dart';
import '../widgets/common.dart';

class TodoCard extends StatelessWidget {
  final String title;
  final String time;

  const TodoCard({
    required this.title,
    required this.time,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Card(
        // прибрано const — щоб не викликало помилки
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                time,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _tasks = [
    'Buy groceries',
    'Walk the dog',
    'Study Flutter'
  ];

  void _addTaskDialog() {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add new task'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter task name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                setState(() => _tasks.add(text));
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
        title: 'Today',
        body: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Good morning',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (_, i) => TodoCard(
                  title: _tasks[i],
                  time: '09:${i}0',
                ),
              ),
            ),
          ],
        ),
        fab: FloatingActionButton(
          onPressed: _addTaskDialog,
          child: const Icon(Icons.add),
        ),
      );
}
