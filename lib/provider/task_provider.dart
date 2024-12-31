import 'package:flutter/material.dart';
import '../model/task.dart';

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [
    Task(title: 'Do home work and Cooking', isCompleted: true),
    Task(title: 'Do home work and Cooking'),
  ];

  List<Task> get tasks => _tasks;

  void toggleTaskStatus(int index) {
    _tasks[index] = Task(
      title: _tasks[index].title,
      isCompleted: !_tasks[index].isCompleted,
    );
    notifyListeners();
  }
}
