import 'dart:convert';

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
       if(args != null && args is String) {
        final Map<String, dynamic> data = jsonDecode(args);
        _extractData(data);
       } else if (args is Map) {
         _extractData(args as Map<String, dynamic>);
       } else {
        
        debugPrint('❌ Invalid args received in TodoScreen: $args');
        debugPrint('dataType: ${args.runtimeType}');  
       }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Todo List'),
        ),
        body: Center(
          child: _todoList.isEmpty
              ? const Center(child: Text('No tasks to do today'))
              : ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) => ListTile(
                    title: Text('${index + 1}. ${_todoList[index].taskName}'),
                  ) ,
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: _todoList.length),
        ),
      ),
    );
  }

  _onAddTodo(TodoItem task) {
    if(task.taskName.isEmpty) {
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
          if (data is Map<String, dynamic>) {
            debugPrint('Task data (add_todo): $data');
            _onAddTodo(TodoItem.fromJson(data));
          } else {
            debugPrint('❌ Data in add_todo is not a Map');
          }
          break;
        // Thêm các case event khác ở đây
        default:
          debugPrint('❌ Unknown event_name: $eventName');
      }
    } else {
      debugPrint('❌ Invalid event data: $args');
    }
  }
}


class TodoItem {
  final int id;
  final String taskName;
  final bool isCompleted;

  TodoItem({required this.id, required this.taskName, this.isCompleted = false});

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(id: json['id'], taskName: json['taskName'], isCompleted: json['isCompleted']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'taskName': taskName, 'isCompleted': isCompleted};
  }
}