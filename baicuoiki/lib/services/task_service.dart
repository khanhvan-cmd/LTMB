import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:baicuoiki/models/task.dart';

class TaskService {
  final String baseUrl = 'http://10.0.2.2:5000/api/tasks';

  Future<String?> _getToken() async {
    return await firebase_auth.FirebaseAuth.instance.currentUser?.getIdToken();
  }

  Future<List<Task>> getTasks(String userId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks: ${response.body}');
    }
  }

  Future<Task?> addTask(Task task) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    if (task.title.isEmpty) {
      throw Exception('Title is required');
    }

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': task.title,
        'description': task.description,
        'status': task.status,
        'priority': task.priority,
        'dueDate': task.dueDate?.toIso8601String(),
        'assignedTo': task.assignedTo,
        'category': task.category,
        'attachments': task.attachments,
        'completed': task.completed,
      }),
    );

    if (response.statusCode == 201) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add task: ${response.body}');
    }
  }

  Future<Task?> updateTask(Task task) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/${task.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': task.title,
        'description': task.description,
        'status': task.status,
        'priority': task.priority,
        'dueDate': task.dueDate?.toIso8601String(),
        'assignedTo': task.assignedTo,
        'category': task.category,
        'attachments': task.attachments,
        'completed': task.completed,
      }),
    );

    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update task: ${response.body}');
    }
  }

  Future<bool> deleteTask(String taskId, String userId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/$taskId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete task: ${response.body}');
    }
  }
}