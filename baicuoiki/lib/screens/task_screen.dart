import 'package:flutter/material.dart';
import 'package:baicuoiki/models/task.dart';
import 'package:baicuoiki/models/user.dart'; // User từ đây
import 'package:baicuoiki/services/auth_service.dart';
import 'package:baicuoiki/services/task_service.dart';
import 'package:baicuoiki/widgets/task_card.dart';
import 'package:baicuoiki/screens/task_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Thêm tiền tố
import 'dart:convert';

// Widget chính hiển thị danh sách công việc
class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TaskService _taskService = TaskService();
  final AuthService _authService = AuthService();
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  bool _isLoading = true;
  User? _user;
  String _searchQuery = '';
  String _filterStatus = 'All';
  String? _filterCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUserAndLoadTasks();
    });
  }

  void _initializeUserAndLoadTasks() {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is User) {
      _user = arguments;
      print('Khởi tạo người dùng với userId: ${_user!.id}');
      _loadTasks();
    } else {
      print('Lỗi: Không tìm thấy đối tượng User hợp lệ');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: Không tìm thấy người dùng. Vui lòng đăng nhập lại.')),
      );
    }
  }

  void _loadTasks() async {
    if (_user == null) {
      print('Lỗi: Người dùng là null trong _loadTasks');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: Không tìm thấy người dùng')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      print('Đang tải công việc cho userId: ${_user!.id}');
      final tasks = await _taskService.getTasks(_user!.id);
      print('Đã tải: ${tasks.length} công việc');
      setState(() {
        _tasks = tasks;
        _filteredTasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      print('Lỗi khi tải công việc: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải công việc: $e')),
      );
    }
  }

  void _addTask() async {
    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: Không tìm thấy người dùng')),
      );
      return;
    }

    final newTask = await showDialog<Task>(
      context: context,
      builder: (context) => AddTaskDialog(userId: _user!.id),
    );

    if (newTask != null) {
      try {
        final addedTask = await _taskService.addTask(newTask);
        if (addedTask != null) {
          setState(() {
            _tasks.add(addedTask);
            _filteredTasks = _tasks;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Thêm công việc thành công')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi thêm công việc: $e')),
        );
      }
    }
  }

  void _updateTask(Task task) async {
    try {
      final updatedTask = await _taskService.updateTask(task);
      if (updatedTask != null) {
        setState(() {
          final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
          if (index != -1) {
            _tasks[index] = updatedTask;
            _filteredTasks = _tasks;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật công việc thành công')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật công việc: $e')),
      );
    }
  }

  void _editTask(Task task) async {
    final updatedTask = await showDialog<Task>(
      context: context,
      builder: (context) => AddTaskDialog(userId: _user!.id, task: task),
    );

    if (updatedTask != null) {
      _updateTask(updatedTask);
    }
  }

  void _deleteTask(String taskId) async {
    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: Không tìm thấy người dùng')),
      );
      return;
    }

    try {
      final success = await _taskService.deleteTask(taskId, _user!.id);
      if (success) {
        setState(() {
          _tasks.removeWhere((task) => task.id == taskId);
          _filteredTasks = _tasks;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xóa công việc thành công')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa công việc: $e')),
      );
    }
  }

  void _logout() async {
    try {
      await _authService.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi đăng xuất: $e')),
      );
    }
  }

  void _filterTasks() {
    setState(() {
      _filteredTasks = _tasks.where((task) {
        final matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            task.description.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesStatus = _filterStatus == 'All' || task.status == _filterStatus;
        final matchesCategory = _filterCategory == null || _filterCategory == 'All' || task.category == _filterCategory;
        return matchesSearch && matchesStatus && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        body: Center(
          child: _isLoading
              ? CircularProgressIndicator()
              : Text('Lỗi: Không tìm thấy người dùng. Vui lòng đăng nhập lại.'),
        ),
      );
    }

    print('Xây dựng TaskScreen với userId: ${_user!.id}');

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A82FB), Color(0xFFFC5C7D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xin chào, ${_user!.username}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Quản lý công việc của bạn',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.logout, color: Colors.white),
                      onPressed: _logout,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm công việc...',
                              prefixIcon: Icon(Icons.search, color: Colors.white70),
                              filled: true,
                              fillColor: Colors.white24,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                            onChanged: (value) {
                              _searchQuery = value;
                              _filterTasks();
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _filterStatus,
                          icon: Icon(Icons.filter_list, color: Colors.white),
                          dropdownColor: Color(0xFF6A82FB),
                          items: ['All', 'To do', 'In Progress', 'Done', 'Cancelled']
                              .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status, style: TextStyle(color: Colors.white)),
                          ))
                              .toList(),
                          onChanged: (value) {
                            _filterStatus = value!;
                            _filterTasks();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _filterCategory ?? 'All',
                      icon: Icon(Icons.category, color: Colors.white),
                      dropdownColor: Color(0xFF6A82FB),
                      items: ['All', ..._tasks.map((t) => t.category).whereType<String>().toSet()]
                          .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category, style: TextStyle(color: Colors.white)),
                      ))
                          .toList(),
                      onChanged: (value) {
                        _filterCategory = value == 'All' ? null : value;
                        _filterTasks();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _filteredTasks.isEmpty
                      ? Center(child: Text('Không tìm thấy công việc', style: TextStyle(fontSize: 18)))
                      : ListView.builder(
                    padding: EdgeInsets.all(16.0),
                    itemCount: _filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = _filteredTasks[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaskDetailScreen(task: task),
                            ),
                          );
                        },
                        child: TaskCard(
                          task: task,
                          onToggle: (value) {
                            _updateTask(task.copyWith(
                              status: value ? 'Done' : 'To do',
                              completed: value,
                            ));
                          },
                          onDelete: () => _deleteTask(task.id),
                          onEdit: () => _editTask(task),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        backgroundColor: Color(0xFFFC5C7D),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// Dialog để thêm hoặc chỉnh sửa công việc
class AddTaskDialog extends StatefulWidget {
  final String userId;
  final Task? task;

  AddTaskDialog({required this.userId, this.task});

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _status = 'To do';
  int _priority = 1;
  DateTime _dueDate = DateTime.now();
  String? _category;
  List<String> _attachments = [];
  String? _assignedTo;
  List<User> _users = []; // User từ package:baicuoiki/models/user.dart

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _status = widget.task!.status;
      _priority = widget.task!.priority;
      _dueDate = widget.task!.dueDate ?? DateTime.now();
      _category = widget.task!.category;
      _attachments = widget.task!.attachments ?? [];
      _assignedTo = widget.task!.assignedTo;
    }
    _loadUsers();
  }

  void _loadUsers() async {
    try {
      final token = await firebase_auth.FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/users'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _users = data.map((json) => User.fromJson(json)).toList(); // User từ package:baicuoiki/models/user.dart
        });
      }
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  Future<void> _uploadAttachment() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null) {
        final file = result.files.single;
        final token = await firebase_auth.FirebaseAuth.instance.currentUser?.getIdToken();
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('http://10.0.2.2:5000/api/attachments'),
        );
        request.headers['Authorization'] = 'Bearer $token';
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
        ));
        final response = await request.send();
        if (response.statusCode == 200) {
          final responseData = await response.stream.bytesToString();
          final data = jsonDecode(responseData);
          setState(() {
            _attachments.add(data['url']);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tải lên tệp thành công')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tải lên tệp thất bại')),
          );
        }
      }
    } catch (e) {
      print('Error uploading attachment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải lên tệp: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(widget.task == null ? 'Thêm công việc mới' : 'Chỉnh sửa công việc',
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Tiêu đề',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: _status,
              items: ['To do', 'In Progress', 'Done', 'Cancelled'].map((status) {
                return DropdownMenuItem(value: status, child: Text(status));
              }).toList(),
              onChanged: (value) => setState(() => _status = value!),
            ),
            DropdownButton<int>(
              value: _priority,
              items: [
                DropdownMenuItem(value: 1, child: Text('Thấp')),
                DropdownMenuItem(value: 2, child: Text('Trung bình')),
                DropdownMenuItem(value: 3, child: Text('Cao')),
              ],
              onChanged: (value) => setState(() => _priority = value!),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Hạn hoàn thành: ${DateFormat.yMd().format(_dueDate)}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _dueDate = picked);
                  },
                  child: Text('Chọn ngày', style: TextStyle(color: Color(0xFF6A82FB))),
                ),
              ],
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Danh mục',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) => _category = value,
            ),
            DropdownButton<String>(
              value: _assignedTo,
              hint: Text('Gán cho'),
              items: _users.map<DropdownMenuItem<String>>((user) {
                return DropdownMenuItem<String>(
                  value: user.id.toString(),
                  child: Text(user.username),
                );
              }).toList(),
              onChanged: (value) => setState(() => _assignedTo = value),
            ),
            TextButton(
              onPressed: _uploadAttachment,
              child: Text('Tải lên đính kèm'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Hủy', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tiêu đề là bắt buộc')),
              );
              return;
            }
            if (_descriptionController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Mô tả là bắt buộc')),
              );
              return;
            }
            final task = Task(
              id: widget.task?.id ?? '',
              title: _titleController.text,
              description: _descriptionController.text,
              status: _status,
              priority: _priority,
              dueDate: _dueDate,
              createdAt: widget.task?.createdAt ?? DateTime.now(),
              updatedAt: DateTime.now(),
              assignedTo: _assignedTo,
              userId: widget.userId, // sửa ở đây (trước là createdBy)
              category: _category,
              attachments: _attachments,
              completed: _status == 'Done',
            );
            Navigator.pop(context, task);

          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF6A82FB),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(widget.task == null ? 'Thêm' : 'Cập nhật', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

