import 'package:flutter/material.dart';
import 'package:baicuoiki/models/task.dart';
import 'package:baicuoiki/services/task_service.dart';
import 'package:intl/intl.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late String _status;
  final TaskService _taskService = TaskService();

  @override
  void initState() {
    super.initState();
    _status = widget.task.status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title),
        backgroundColor: Color(0xFF6A82FB),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trạng thái:', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _status,
              items: ['To do', 'In Progress', 'Done', 'Cancelled'].map((status) {
                return DropdownMenuItem(value: status, child: Text(status));
              }).toList(),
              onChanged: (value) async {
                if (value != null) {
                  final updatedTask = widget.task.copyWith(
                    status: value,
                    completed: value == 'Done',
                  );
                  try {
                    await _taskService.updateTask(updatedTask);
                    setState(() => _status = value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cập nhật trạng thái thành công')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi khi cập nhật trạng thái: $e')),
                    );
                  }
                }
              },
            ),
            SizedBox(height: 16),
            Text('Mô tả:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(widget.task.description.isNotEmpty ? widget.task.description : 'Không có mô tả'),
            SizedBox(height: 16),
            Text('Ưu tiên: ${widget.task.priority == 1 ? 'Thấp' : widget.task.priority == 2 ? 'Trung bình' : 'Cao'}'),
            Text('Hạn hoàn thành: ${widget.task.dueDate != null ? DateFormat.yMd().format(widget.task.dueDate!) : 'Không có'}'),
            Text('Tạo lúc: ${DateFormat.yMd().format(widget.task.createdAt)}'),
            Text('Cập nhật lúc: ${DateFormat.yMd().format(widget.task.updatedAt)}'),
            Text('Giao cho: ${widget.task.assignedTo ?? 'Chưa giao'}'),
            Text('Người tạo: ${widget.task.userId}'),

            Text('Danh mục: ${widget.task.category ?? 'Không có'}'),
            SizedBox(height: 16),
            Text('Đính kèm:', style: TextStyle(fontWeight: FontWeight.bold)),
            widget.task.attachments != null && widget.task.attachments!.isNotEmpty
                ? Column(
              children: widget.task.attachments!.map((url) => ListTile(
                title: Text(url),
                onTap: () {
                  // Xử lý mở URL (có thể dùng url_launcher)
                },
              )).toList(),
            )
                : Text('Không có đính kèm'),
          ],
        ),
      ),
    );
  }
}