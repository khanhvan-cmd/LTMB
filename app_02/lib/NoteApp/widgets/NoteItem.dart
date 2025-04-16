import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app_02/NoteApp/Model/NoteModel.dart';
import 'package:app_02/NoteApp/UI/NoteDetailScreen.dart';

class NoteItem extends StatelessWidget {
  final Note note;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final VoidCallback onToggleComplete;

  const NoteItem({
    super.key,
    required this.note,
    required this.onDelete,
    required this.onShare,
    required this.onToggleComplete,
  });

  Color getPriorityColor() {
    switch (note.priority) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return Colors.white;
    }
    try {
      if (hexColor.length != 6) {
        return Colors.white;
      }
      final validHex = RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(hexColor);
      if (!validHex) {
        return Colors.white;
      }
      return Color(int.parse('0xFF$hexColor'));
    } catch (e) {
      return Colors.white;
    }
  }

  // Hàm xác định màu chữ dựa trên độ sáng của nền
  Color getTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance < 0.5 ? Colors.white : Colors.black87;
  }

  Widget buildImage(String? imagePath, {double height = 60, double width = 60}) {
    if (imagePath == null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.note,
          color: Colors.deepPurple,
          size: 30,
        ),
      );
    }

    if (imagePath.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imagePath,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.broken_image,
                color: Colors.deepPurple,
                size: 30,
              ),
            );
          },
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(imagePath),
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.broken_image,
                color: Colors.deepPurple,
                size: 30,
              ),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final noteColor = parseColor(note.color);
    final textColor = getTextColor(noteColor);

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: noteColor,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(10),
          leading: buildImage(note.imagePath),
          title: Text(
            note.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor, // Tương phản với nền
              decoration: note.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Text(
                note.content.length > 50
                    ? '${note.content.substring(0, 50)}...'
                    : note.content,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor.withOpacity(0.8), // Tương phản với nền
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(
                    Icons.priority_high,
                    size: 16,
                    color: getPriorityColor(),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    note.priority == 1
                        ? 'Thấp'
                        : note.priority == 2
                        ? 'Trung bình'
                        : 'Cao',
                    style: TextStyle(
                      fontSize: 12,
                      color: getPriorityColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  note.isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                  color: note.isCompleted ? Colors.green : textColor.withOpacity(0.6),
                ),
                onPressed: onToggleComplete,
              ),
              IconButton(
                icon: Icon(
                  Icons.share,
                  color: textColor,
                ),
                onPressed: onShare,
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoteDetailScreen(note: note),
              ),
            );
            if (result == true) {
              onToggleComplete();
            }
          },
        ),
      ),
    );
  }
}