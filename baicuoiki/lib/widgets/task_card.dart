import 'package:flutter/material.dart';
import 'package:baicuoiki/models/task.dart';
import 'package:intl/intl.dart';

// Widget hiển thị một công việc
class TaskCard extends StatelessWidget {
  final Task task; // Công việc
  final ValueChanged<bool> onToggle; // Hàm xử lý thay đổi trạng thái hoàn thành
  final VoidCallback onDelete; // Hàm xử lý xóa
  final VoidCallback onEdit; // Hàm xử lý chỉnh sửa

  TaskCard({
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Lề
      elevation: 5, // Độ nổi
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Bo góc
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF3F4F8)], // Gradient nhẹ
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15), // Bo góc
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(16), // Lề bên trong
          title: Text(
            task.title, // Tiêu đề
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF333333),
              decoration: task.completed ? TextDecoration.lineThrough : null, // Gạch ngang nếu hoàn thành
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description.isNotEmpty) // Nếu có mô tả
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    task.description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Hạn: ${task.dueDate != null ? DateFormat.yMd().format(task.dueDate!) : 'Không có'}', // Hạn hoàn thành
                  style: TextStyle(color: Color(0xFF6A82FB), fontSize: 14),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Ưu tiên: ${task.priority == 1 ? 'Thấp' : task.priority == 2 ? 'Trung bình' : 'Cao'}', // Độ ưu tiên
                  style: TextStyle(
                    color: task.priority == 3 ? Colors.red : task.priority == 2 ? Colors.orange : Colors.green, // Màu theo ưu tiên
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          leading: Checkbox(
            value: task.completed, // Trạng thái hoàn thành
            activeColor: Color(0xFF6A82FB), // Màu khi chọn
            onChanged: (value) {
              if (value != null) onToggle(value); // Gọi hàm xử lý
            },
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Color(0xFF6A82FB)), // Nút chỉnh sửa
                onPressed: onEdit,
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Color(0xFFFC5C7D)), // Nút xóa
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}