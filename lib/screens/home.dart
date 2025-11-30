// lib/screens/home.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'dart:math';

import '../widgets/common.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../models/todo_item.dart';
import '../repositories/todo_repository.dart';

// --- TodoCard (Переклад логіки відображення) ---
class TodoCard extends StatelessWidget {
  final TodoItem item; 
  final VoidCallback? onDelete;
  final ValueChanged<bool?>? onToggleComplete; 

  const TodoCard({
    required this.item,
    this.onDelete,
    this.onToggleComplete,
    super.key,
  });

  String _formatTime(DateTime? dueTime) {
    if (dueTime == null) {
      return 'All Day (No Date)'; // Перекладено
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueTime.year, dueTime.month, dueTime.day);
    
    String datePart;
    if (taskDate.isAtSameMomentAs(today)) {
      datePart = 'Today'; // Перекладено
    } else if (taskDate.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      datePart = 'Tomorrow'; // Перекладено
    } else if (taskDate.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
      datePart = 'Yesterday'; // Перекладено
    } else {
      datePart = DateFormat('MM/dd/yyyy').format(dueTime); // Англійський формат дати
    }

    if (dueTime.hour != 0 || dueTime.minute != 0) {
      return '$datePart, ${DateFormat('h:mm a').format(dueTime)}'; // Англійський формат часу (12-годинний)
    }
    
    return datePart;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textColor = item.isCompleted ? Colors.grey : Colors.black87;
    final textDecoration = item.isCompleted ? TextDecoration.lineThrough : TextDecoration.none;
    
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Checkbox(
              value: item.isCompleted,
              onChanged: onToggleComplete,
              activeColor: primaryColor,
              shape: const CircleBorder(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                        item.title,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                            decoration: textDecoration,
                            decorationColor: textColor,
                        ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                        children: [
                            Icon(Icons.calendar_month, size: 13, color: Colors.grey),
                            const SizedBox(width: 5),
                            Text(
                                _formatTime(item.dueTime),
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                        ],
                    ),
                ],
              ),
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: onDelete,
                splashRadius: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// --- HomePage (Переклад UI та логіки стану) ---
class HomePage extends StatefulWidget {
  final AuthService authService;
  const HomePage({required this.authService, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TodoRepository _todoRepo = TodoRepository(); 
  late User? _user;
  List<TodoItem> _tasks = []; 
  
  DateTime _selectedDate = _normalizeDate(DateTime.now()); 

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadTasks(); 
  }

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void _loadUser() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is User) {
        setState(() => _user = arg);
      } else {
        setState(() => _user = null);
      }
    });
  }
  
  Future<void> _loadTasks() async {
    final loadedTasks = await _todoRepo.loadTasks();
    
    if (loadedTasks.isEmpty) {
      final now = DateTime.now();
      loadedTasks.addAll([
        TodoItem(id: '1', title: 'Buy groceries', dueTime: DateTime(now.year, now.month, now.day, 19, 0)),
        TodoItem(id: '2', title: 'Walk the dog', isCompleted: true),
        TodoItem(id: '3', title: 'Plan vacation', dueTime: now.add(const Duration(days: 7))), // Перекладено
        TodoItem(id: '4', title: 'Timeless task', dueTime: null), // Перекладено
        TodoItem(id: '5', title: 'Tomorrow\'s report', dueTime: now.add(const Duration(days: 1))), // Перекладено
      ]);
    }

    setState(() {
      _tasks = loadedTasks;
      _sortTasks();
    });
  }

  Future<void> _saveTasks() async {
    await _todoRepo.saveTasks(_tasks);
  }

  void _sortTasks() {
    _tasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      
      if (a.dueTime != null && b.dueTime != null) {
        return a.dueTime!.compareTo(b.dueTime!);
      }
      
      if (a.dueTime == null && b.dueTime != null) return 1;
      if (a.dueTime != null && b.dueTime == null) return -1;
      return 0; 
    });
  }

  List<TodoItem> get _filteredTasks {
    final normalizedSelectedDate = _normalizeDate(_selectedDate);

    return _tasks.where((item) {
      if (item.dueTime == null) return true; 

      final normalizedItemDate = _normalizeDate(item.dueTime!);
      return normalizedItemDate.isAtSameMomentAs(normalizedSelectedDate);
    }).toList();
  }
  
  void _changeDate(DateTime newDate) {
    setState(() {
      _selectedDate = _normalizeDate(newDate);
    });
  }

  void _toggleComplete(int index, bool? isCompleted) async {
    if (isCompleted == null) return;
    
    final filteredItem = _filteredTasks[index];
    final originalItemIndex = _tasks.indexWhere((t) => t.id == filteredItem.id);
    
    if (originalItemIndex != -1) {
      _tasks[originalItemIndex] = filteredItem.copyWith(isCompleted: isCompleted);
      await _saveTasks();
      if (mounted) {
          setState(() {});
      }
    }
  }
  
  void _deleteTask(int index) async {
    final itemToDelete = _filteredTasks[index];
    _tasks.removeWhere((t) => t.id == itemToDelete.id);
    await _saveTasks();
    if (mounted) {
        setState(() {});
    }
  }

  void _addTaskDialog() {
    final controller = TextEditingController();
    DateTime selectedDate = _selectedDate; 
    TimeOfDay? selectedTime;
    bool allDay = true; 

    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateSB) {
          final primaryColor = Theme.of(context).primaryColor;
          
          return AlertDialog( // Перекладено
            title: const Text('Add new task'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(hint: 'Task name', controller: controller), // Перекладено
                  const SizedBox(height: 20),
                  
                  TextButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      'Date: ${DateFormat('MM/dd/yyyy').format(selectedDate)}', // Перекладено
                      style: TextStyle(color: primaryColor),
                    ),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)), 
                        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                      );
                      if (picked != null) {
                        setStateSB(() => selectedDate = _normalizeDate(picked));
                      }
                    },
                  ),

                  Row(
                    children: [
                      const Text('All Day:', style: TextStyle(fontSize: 16)), // Перекладено
                      Switch(
                        value: allDay,
                        onChanged: (val) {
                          setStateSB(() {
                            allDay = val;
                            if (allDay) selectedTime = null; 
                          });
                        },
                      ),
                    ],
                  ),

                  if (!allDay)
                    TextButton.icon(
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        selectedTime == null
                            ? 'Select time' // Перекладено
                            : selectedTime!.format(context),
                        style: TextStyle(color: primaryColor),
                      ),
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setStateSB(() => selectedTime = picked);
                        }
                      },
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), // Перекладено
              ElevatedButton(
                onPressed: () async {
                  final text = controller.text.trim();
                  if (text.isNotEmpty) {
                    DateTime? finalDueTime;
                    
                    if (allDay || selectedTime == null) {
                      finalDueTime = selectedDate; 
                    } else {
                      finalDueTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime!.hour,
                        selectedTime!.minute,
                      );
                    }
                    
                    final newItem = TodoItem(
                      id: Random().nextInt(1000000).toString(), 
                      title: text,
                      dueTime: finalDueTime,
                    );
                    
                    _tasks.add(newItem);
                    await _saveTasks();
                    
                    if (mounted) {
                        setState(() { _sortTasks(); });
                    }
                  }
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Add'), // Перекладено
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openProfile() async {
    await Navigator.pushNamed(context, '/profile', arguments: _user);
    setState(() {});
  }
  
  String _formatHeaderDate(DateTime date) {
    final now = DateTime.now();
    final today = _normalizeDate(now);
    final tomorrow = _normalizeDate(now.add(const Duration(days: 1)));
    final yesterday = _normalizeDate(now.subtract(const Duration(days: 1)));
    
    if (date.isAtSameMomentAs(today)) return 'Today'; // Перекладено
    if (date.isAtSameMomentAs(tomorrow)) return 'Tomorrow'; // Перекладено
    if (date.isAtSameMomentAs(yesterday)) return 'Yesterday'; // Перекладено

    return DateFormat('EEEE, MMM dd, yyyy').format(date); // Англійський формат заголовка
  }


  @override
  Widget build(BuildContext context) {
    final tasksForDay = _filteredTasks;
    
    return AppScaffold(
        title: 'Your ToDo List', // Перекладено
        fab: FloatingActionButton(
          onPressed: _addTaskDialog,
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 2,
          child: const Icon(Icons.add),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Hello, ${_user?.name ?? 'User'}', // Перекладено
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).primaryColor, 
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.account_circle, size: 30),
                  color: Colors.grey.shade600,
                  onPressed: _openProfile,
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Панель вибору дня
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    IconButton(
                        icon: const Icon(Icons.arrow_back_ios, size: 20),
                        onPressed: () => _changeDate(_selectedDate.subtract(const Duration(days: 1))),
                    ),
                    
                    GestureDetector(
                        onTap: () async {
                            final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                            );
                            if (picked != null) {
                                _changeDate(picked);
                            }
                        },
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                const Icon(Icons.calendar_today, size: 16, color: Colors.black87),
                                const SizedBox(width: 8),
                                Text(
                                    _formatHeaderDate(_selectedDate),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                            ],
                        ),
                    ),

                    IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 20),
                        onPressed: () => _changeDate(_selectedDate.add(const Duration(days: 1))),
                    ),
                ],
            ),
            
            const SizedBox(height: 15),
            Text( // Перекладено
              'Tasks for ${_formatHeaderDate(_selectedDate)}: ${tasksForDay.length}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            
            Expanded(
              child: tasksForDay.isEmpty
                  ? Center(
                      child: Text('No tasks for this day! 🏖️', style: TextStyle(color: Colors.grey.shade600)), // Перекладено
                    )
                  : ListView.builder(
                      itemCount: tasksForDay.length,
                      itemBuilder: (_, i) => TodoCard(
                        item: tasksForDay[i], 
                        onDelete: () => _deleteTask(i),
                        onToggleComplete: (val) => _toggleComplete(i, val),
                      ),
                    ),
            ),
          ],
        ),
      );
  }
}