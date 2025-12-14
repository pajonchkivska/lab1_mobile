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
import '../widgets/mqtt_event_widget.dart';
import '../widgets/todo_list_widget.dart';

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
  late Future<List<TodoItem>> _tasksFuture;

  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  User? _user;

  ConnectivityService? _connectivity;
  bool _snackShown = false;

  @override
  void initState() {
    super.initState();
    _tasksFuture = _refreshTasks();
    _loadUser();

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
    setState(() => _tasksFuture = _refreshTasks()); // online -> API, offline -> cache
  }

  Future<List<TodoItem>> _refreshTasks() async {
    final list = await widget.todoRepo.getTodos(); // LAB5
    _tasks = list;
    return list;
  }

  Future<void> _saveTasks() => widget.todoRepo.saveTasks(_tasks);

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

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  String _formatHeaderDate(DateTime date) {
    final now = _normalize(DateTime.now());
    final d = _normalize(date);
    if (d.isAtSameMomentAs(now)) return 'Today';
    if (d.isAtSameMomentAs(now.subtract(const Duration(days: 1)))) return 'Yesterday';
    if (d.isAtSameMomentAs(now.add(const Duration(days: 1)))) return 'Tomorrow';
    return DateFormat('EEEE, MMM dd, yyyy').format(date);
  }

  String _formatTime(DateTime time) => DateFormat('h:mm a').format(time);

  List<TodoItem> get _filteredTasks {
    final sd = _normalize(_selectedDate);
    final list = _tasks.where((t) {
      if (t.dueTime == null) return true;
      return _normalize(t.dueTime!).isAtSameMomentAs(sd);
    }).toList();

    list.sort((a, b) {
      if (a.isCompleted && !b.isCompleted) return 1;
      if (!a.isCompleted && b.isCompleted) return -1;
      return 0;
    });

    return list;
  }

  Future<void> _addTaskDialog() async {
    final controller = TextEditingController();

    final title = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Add new task'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter task title'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (title == null || title.isEmpty) return;

    final item = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      isCompleted: false,
      dueTime: _selectedDate,
      isAllDay: true,
    );

    setState(() => _tasks.add(item));
    await _saveTasks();
  }

  void _toggleComplete(int index) async {
    final item = _filteredTasks[index];
    final originalIndex = _tasks.indexOf(item);
    if (originalIndex == -1) return;

    setState(() {
      _tasks[originalIndex] =
          _tasks[originalIndex].copyWith(isCompleted: !_tasks[originalIndex].isCompleted);
    });
    await _saveTasks();
  }

  void _deleteTask(int index) async {
    final item = _filteredTasks[index];
    _tasks.removeWhere((t) => t.id == item.id);
    await _saveTasks();
    if (!mounted) return;
    setState(() {});
  }

  void _changeDate(int days) => setState(() => _selectedDate = _selectedDate.add(Duration(days: days)));

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked == null) return;
    final n = _normalize(picked);
    if (n != _normalize(_selectedDate)) setState(() => _selectedDate = n);
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

    if (confirm != true) return;

    await widget.authService.clearSession();
    context.read<MqttService>().disconnect();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (_, connectivity, __) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Welcome, ${_user?.name ?? "User"}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => setState(() => _tasksFuture = _refreshTasks()),
              ),
              IconButton(icon: const Icon(Icons.logout), onPressed: _showLogoutDialog),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _addTaskDialog,
            child: const Icon(Icons.add),
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
                    IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => _changeDate(-1)),
                    GestureDetector(
                      onTap: _selectDate,
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
                    IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: () => _changeDate(1)),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: FutureBuilder<List<TodoItem>>(
                    future: _tasksFuture,
                    builder: (_, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));

                      return TodoListWidget(
                        items: _filteredTasks,
                        formatTime: _formatTime,
                        onToggle: _toggleComplete,
                        onDelete: _deleteTask,
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
