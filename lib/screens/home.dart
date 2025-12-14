import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo_item.dart';
import '../models/user.dart';
import '../repositories/todo_repository.dart';
import '../services/auth_service.dart';
import '../services/connectivity_service.dart';
import '../services/mqtt_service.dart';

class HomePage extends StatefulWidget {
  final AuthService authService;
  final TodoRepository todoRepo;
  final User? autoLoggedInUser;

  const HomePage({
    required this.authService,
    required this.todoRepo,
    this.autoLoggedInUser,
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TodoItem> _tasks = [];
  DateTime _selectedDate = _normalizeDate(DateTime.now());
  User? _user;

  ConnectivityService? _connectivity;
  bool _snackShown = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadTasks();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mqtt = context.read<MqttService>();
      _connectivity = context.read<ConnectivityService>();

      _connectivity!.addListener(_onConnectivityChanged);

      if (_connectivity!.isConnected) {
        mqtt.connect();
      } else {
        mqtt.disconnect();
        _showSnackOnce();
      }
    });
  }

  @override
  void dispose() {
    _connectivity?.removeListener(_onConnectivityChanged);
    context.read<MqttService>().disconnect();
    super.dispose();
  }

  void _onConnectivityChanged() {
    if (!mounted) return;

    final mqtt = context.read<MqttService>();
    final connectivity = context.read<ConnectivityService>();

    if (connectivity.isConnected) {
      _hideSnack();
      mqtt.connect();
    } else {
      mqtt.disconnect();
      _showSnackOnce();
    }
  }

  void _showSnackOnce() {
    if (_snackShown) return;
    _snackShown = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet. MQTT disconnected.'),
          duration: Duration(seconds: 6),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _hideSnack() {
    _snackShown = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    });
  }

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _formatHeaderDate(DateTime date) {
    final now = _normalizeDate(DateTime.now());
    final normalizedDate = _normalizeDate(date);

    if (normalizedDate.isAtSameMomentAs(now)) return 'Today';
    if (normalizedDate.isAtSameMomentAs(now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    if (normalizedDate.isAtSameMomentAs(now.add(const Duration(days: 1)))) {
      return 'Tomorrow';
    }
    return DateFormat('EEEE, MMM dd, yyyy').format(date);
  }

  String _formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  Future<void> _loadUser() async {
    User? loadedUser;

    if (widget.autoLoggedInUser != null) {
      loadedUser = widget.autoLoggedInUser;
    } else {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('current_user_email');
      if (email != null) {
        loadedUser = await widget.authService.repository.getUserByEmail(email);
      }
    }

    if (!mounted) return;
    setState(() => _user = loadedUser);
  }

  Future<void> _loadTasks() async {
    final loadedTasks = await widget.todoRepo.loadTasks();
    if (!mounted) return;
    setState(() => _tasks = loadedTasks);
  }

  Future<void> _saveTasks() async {
    await widget.todoRepo.saveTasks(_tasks);
  }

  List<TodoItem> get _filteredTasks {
    final normalizedSelectedDate = _normalizeDate(_selectedDate);

    final filtered = _tasks.where((item) {
      if (item.dueTime == null) return true;
      final normalizedItemDate = _normalizeDate(item.dueTime!);
      return normalizedItemDate.isAtSameMomentAs(normalizedSelectedDate);
    }).toList();

    filtered.sort((a, b) {
      if (a.isCompleted && !b.isCompleted) return 1;
      if (!a.isCompleted && b.isCompleted) return -1;
      return 0;
    });

    return filtered;
  }

  void _toggleComplete(int index) async {
    final targetItem = _filteredTasks[index];
    final originalIndex = _tasks.indexOf(targetItem);

    if (originalIndex != -1) {
      setState(() {
        _tasks[originalIndex] = _tasks[originalIndex].copyWith(
          isCompleted: !_tasks[originalIndex].isCompleted,
        );
      });
      await _saveTasks();
    }
  }

  void _deleteTask(int index) async {
    final targetItem = _filteredTasks[index];
    _tasks.removeWhere((item) => item.id == targetItem.id);
    await _saveTasks();
    if (!mounted) return;
    setState(() {});
  }

  void _changeDate(int days) {
    setState(() => _selectedDate = _selectedDate.add(Duration(days: days)));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && _normalizeDate(picked) != _normalizeDate(_selectedDate)) {
      setState(() => _selectedDate = _normalizeDate(picked));
    }
  }

  Future<void> _showLogoutDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Log Out?'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Logout')),
        ],
      ),
    );

    if (confirm == true) {
      await widget.authService.clearSession();
      context.read<MqttService>().disconnect();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Welcome, ${_user?.name ?? "User"}'),
            actions: [
              IconButton(icon: const Icon(Icons.logout), onPressed: _showLogoutDialog),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (connectivity.isConnected) const MqttEventWidget(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => _changeDate(-1),
                    ),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Column(
                        children: [
                          Text(
                            _formatHeaderDate(_selectedDate),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text('${_filteredTasks.length} tasks'),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: () => _changeDate(1),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredTasks.length,
                    itemBuilder: (context, index) {
                      final item = _filteredTasks[index];
                      return Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _deleteTask(index),
                        child: Card(
                          child: ListTile(
                            leading: Checkbox(
                              value: item.isCompleted,
                              onChanged: (_) => _toggleComplete(index),
                            ),
                            title: Text(item.title),
                            subtitle: item.dueTime != null
                                ? Text(item.isAllDay ? 'All Day' : _formatTime(item.dueTime!))
                                : const Text('No Time'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MqttEventWidget extends StatelessWidget {
  const MqttEventWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MqttService>(
      builder: (context, mqtt, _) {
        final ok = mqtt.status.contains('Connected') ||
            mqtt.status.contains('Subscribed') ||
            mqtt.status.contains('Reconnected');

        return Card(
          color: Colors.blue.shade50,
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MQTT Status: ${mqtt.status}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ok ? Colors.green : Colors.red,
                  ),
                ),
                const Divider(),
                const Text('Last ToDo event:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(mqtt.lastEvent, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );
  }
}
