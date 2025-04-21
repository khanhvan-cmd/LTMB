import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:app_02/NoteApp/Services/ApiService.dart';
import 'package:app_02/NoteApp/Model/NoteModel.dart';

class NoteFormScreen extends StatefulWidget {
  final Note? note;

  const NoteFormScreen({super.key, this.note});

  @override
  _NoteFormScreenState createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  int? selectedPriority;
  String? selectedColor;
  String? _imagePath;
  DateTime? _reminderTime;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      selectedPriority = widget.note!.priority;
      selectedColor = widget.note!.color;
      _tagsController.text = widget.note!.tags?.join(', ') ?? '';
      _imagePath = widget.note!.imagePath;
      _reminderTime = widget.note!.reminderTime; // Initialize reminder time
    } else {
      selectedPriority = 1;
      selectedColor = 'FFFFFF'; // Default to white
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _openColorPicker() {
    Color initialColor = Colors.white;
    if (selectedColor != null) {
      try {
        initialColor = Color(int.parse('FF$selectedColor', radix: 16));
      } catch (e) {
        // Handle invalid color code gracefully
      }
    }

    Color? tempColor = initialColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn màu'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: initialColor,
            onColorChanged: (Color color) {
              tempColor = color;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (tempColor != null) {
                setState(() {
                  selectedColor = tempColor!.value.toRadixString(16).substring(2).toUpperCase();
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickReminderTime() async {
    // Show date picker
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _reminderTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      // Show time picker after date is selected
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_reminderTime ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _reminderTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Thêm ghi chú' : 'Sửa ghi chú'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurpleAccent, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Tiêu đề',
                      labelStyle: TextStyle(color: Colors.deepPurple.shade400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tiêu đề';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      labelText: 'Nội dung',
                      labelStyle: TextStyle(color: Colors.deepPurple.shade400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập nội dung';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: selectedPriority,
                    decoration: InputDecoration(
                      labelText: 'Mức độ ưu tiên',
                      labelStyle: TextStyle(color: Colors.deepPurple.shade400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(value: 1, child: Text('Thấp')),
                      const DropdownMenuItem(value: 2, child: Text('Trung bình')),
                      const DropdownMenuItem(value: 3, child: Text('Cao')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedPriority = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Vui lòng chọn mức độ ưu tiên';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _openColorPicker,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Màu sắc',
                        labelStyle: TextStyle(color: Colors.deepPurple.shade400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: selectedColor != null
                                  ? Color(int.parse('FF$selectedColor', radix: 16))
                                  : Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            selectedColor != null ? '#$selectedColor' : 'Chọn màu',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tagsController,
                    decoration: InputDecoration(
                      labelText: 'Thẻ (cách nhau bởi dấu phẩy)',
                      labelStyle: TextStyle(color: Colors.deepPurple.shade400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickReminderTime,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Nhắc nhở',
                        labelStyle: TextStyle(color: Colors.deepPurple.shade400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.grey),
                          const SizedBox(width: 10),
                          Text(
                            _reminderTime != null
                                ? DateFormat('dd/MM/yyyy HH:mm').format(_reminderTime!)
                                : 'Chọn thời gian nhắc nhở',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _imagePath != null
                            ? _imagePath!.startsWith('http')
                            ? Image.network(
                          _imagePath!,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 100,
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 50,
                              ),
                            );
                          },
                        )
                            : Image.file(
                          File(_imagePath!),
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 100,
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 50,
                              ),
                            );
                          },
                        )
                            : Container(
                          height: 100,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 50,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _pickImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                        ),
                        child: const Text(
                          'Chọn ảnh',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          final newNote = Note(
                            id: widget.note?.id,
                            userId: 1,
                            title: _titleController.text,
                            content: _contentController.text,
                            priority: selectedPriority!,
                            createdAt: widget.note?.createdAt ?? DateTime.now(),
                            modifiedAt: DateTime.now(),
                            tags: _tagsController.text.isNotEmpty
                                ? _tagsController.text
                                .split(',')
                                .map((tag) => tag.trim())
                                .toList()
                                : null,
                            color: selectedColor,
                            isCompleted: widget.note?.isCompleted ?? false,
                            imagePath: _imagePath,
                            reminderTime: _reminderTime, // Add reminder time
                          );

                          if (widget.note == null) {
                            await ApiService.instance.insertNote(newNote);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Thêm ghi chú thành công'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            await ApiService.instance.updateNote(newNote);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cập nhật ghi chú thành công'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                          Navigator.pop(context, true);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lỗi: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      widget.note == null ? 'Thêm ghi chú' : 'Cập nhật ghi chú',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}