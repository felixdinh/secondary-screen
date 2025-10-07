import 'package:flutter/material.dart';
import 'package:presentation_displays/secondary_display.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<TodoItem> _todoList = [];

  @override
  Widget build(BuildContext context) {
    return SecondaryDisplay(
      callback: (args) {
        debugPrint('📥 TodoScreen received args: $args (type: ${args.runtimeType})');
        if (args is Map) {
          // Convert Map<Object?, Object?> to Map<String, dynamic>
          final Map<String, dynamic> dataMap = Map<String, dynamic>.from(args);
          _extractData(dataMap);
        } else {
          debugPrint('❌ Invalid args received in TodoScreen: $args');
          debugPrint('dataType: ${args.runtimeType}');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Todo List'),
        ),
        body: _todoList.isEmpty
            ? const Center(child: Text('No tasks to do today'))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'You have ${_todoList.length} tasks to do today',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
                      itemBuilder: (context, index) => ListTile(
                        title: Text(
                          '${index + 1}. ${_todoList[index].taskName}',
                          style: _getTextStyle(_todoList[index]),
                        ),
                      ),
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: _todoList.length,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  TextStyle _getTextStyle(TodoItem item) {
    if (item.isCompleted) { 
      return const TextStyle(
        fontSize: 18,
        decoration: TextDecoration.lineThrough,
        color: Colors.grey,
      );
    }
    return const TextStyle(fontSize: 18);
  }

  _onAddTodo(TodoItem task) {
    if (task.taskName.isEmpty) {
      debugPrint('❌ Task name is empty, skipping');
      return;
    }

    // Kiểm tra xem task đã tồn tại chưa (dựa trên id)
    final existingTaskIndex = _todoList.indexWhere((t) => t.id == task.id);
    if (existingTaskIndex != -1) {
      // Update existing task
      debugPrint('🔄 Updating existing task: ${task.taskName}');
      _todoList[existingTaskIndex] = task;
    } else {
      // Add new task
      debugPrint('➕ Adding new task: ${task.taskName}');
      _todoList.add(task);
    }

    debugPrint('📋 Total tasks in TodoScreen: ${_todoList.length}');
    setState(() {});
  }

  _extractData(Map<String, dynamic> args) {
    debugPrint('TodoScreen received data: $args');
    if (args.containsKey('event_name') && args.containsKey('data')) {
      final eventName = args['event_name'] as String?;
      final data = args['data'];
      switch (eventName) {
        case 'add_todo':
          if (data is Map) {
            final taskData = Map<String, dynamic>.from(data);
            debugPrint('Task data (add_todo): $taskData');
            _onAddTodo(TodoItem.fromJson(taskData));
          } else {
            debugPrint('❌ Data in add_todo is not a Map: $data (type: ${data.runtimeType})');
          }
          break;
        case 'update_todo':
          if (data is Map) {
            final taskData = Map<String, dynamic>.from(data);
            debugPrint('Task data (update_todo): $taskData');
            _onUpdateTodo(TodoItem.fromJson(taskData));
          } else {
            debugPrint('❌ Data in update_todo is not a Map: $data (type: ${data.runtimeType})');
          }
          break;
        default:
          debugPrint('❌ Unknown event_name: $eventName');
      }
    } else {
      debugPrint('❌ Invalid event data: $args');
    }

  }

  void _onUpdateTodo(TodoItem updatedTask) {
    final index = _todoList.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      debugPrint('🔄 Updating task completion: ${updatedTask.toJson()}');
      _todoList[index] = updatedTask;
      setState(() {});
    } else {
      debugPrint('❌ Task to update not found: ${updatedTask.id}');
    }
  }
}

class TodoItem {
  final int id;
  final String taskName;
  final bool isCompleted;

  TodoItem(
      {required this.id, required this.taskName, this.isCompleted = false});

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
        id: json['id'],
        taskName: json['taskName'],
        isCompleted: json['isCompleted']);
  }

  TodoItem copyWith({int? id, String? taskName, bool? isCompleted}) {
    return TodoItem(
      id: id ?? this.id,
      taskName: taskName ?? this.taskName,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'taskName': taskName, 'isCompleted': isCompleted};
  }
}
