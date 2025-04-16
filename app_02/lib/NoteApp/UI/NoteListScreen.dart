import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app_02/NoteApp/Services/ApiService.dart';
import 'package:app_02/NoteApp/Model/NoteModel.dart';
import 'package:app_02/NoteApp/UI/NoteDetailScreen.dart';
import 'package:app_02/NoteApp/UI/NoteForm.dart';
import 'package:app_02/NoteApp/UI/LoginScreen.dart';
import 'package:app_02/NoteApp/widgets/NoteItem.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteListScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const NoteListScreen({super.key, required this.onLogout});

  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  List<Note> notes = [];
  List<Note> allNotes = [];
  bool isLoading = false;
  bool isGridView = false;
  String sortOption = 'createdAt';
  String searchQuery = '';
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    refreshNotes();
  }

  Future refreshNotes() async {
    setState(() => isLoading = true);
    try {
      allNotes = await ApiService.instance.getAllNotes();
      if (searchQuery.isNotEmpty) {
        final normalizedQuery = ApiService.removeDiacritics(searchQuery).toLowerCase();
        notes = allNotes.where((note) {
          final normalizedTitle = ApiService.removeDiacritics(note.title).toLowerCase();
          final normalizedContent = ApiService.removeDiacritics(note.content).toLowerCase();
          return normalizedTitle.contains(normalizedQuery) || normalizedContent.contains(normalizedQuery);
        }).toList();
      } else {
        notes = List.from(allNotes);
      }
      sortNotes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải danh sách ghi chú: $e'),
          backgroundColor: Colors.red,
        ),
      );
      notes = [];
      allNotes = [];
    } finally {
      setState(() => isLoading = false);
    }
  }

  void sortNotes() {
    if (sortOption == 'priority') {
      notes.sort((a, b) => b.priority.compareTo(a.priority));
    } else {
      notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  void shareNote(Note note) {
    Share.share('Tiêu đề: ${note.title}\nNội dung: ${note.content}');
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
    // Tính độ sáng (luminance) của màu nền
    final luminance = backgroundColor.computeLuminance();
    // Nếu nền tối (luminance < 0.5), dùng chữ màu sáng; nếu nền sáng, dùng chữ màu tối
    return luminance < 0.5 ? Colors.white : Colors.black87;
  }

  Widget buildImage(String? imagePath, {double height = 100, double width = double.infinity}) {
    if (imagePath == null) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.note,
          color: Colors.deepPurple,
          size: 40,
        ),
      );
    }

    if (imagePath.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imagePath,
          height: height,
          width: width,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.broken_image,
                color: Colors.deepPurple,
                size: 40,
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
          height: height,
          width: width,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.broken_image,
                color: Colors.deepPurple,
                size: 40,
              ),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          elevation: 0,
        ),
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [Colors.deepPurple.shade900, Colors.black87]
                  : [Colors.deepPurple.shade100, Colors.white], // Gradient nhẹ hơn
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120.0,
                floating: true,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Danh sách ghi chú',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.deepPurple, Colors.deepPurpleAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                      color: Colors.white,
                    ),
                    onPressed: toggleTheme,
                    tooltip: isDarkMode
                        ? 'Chuyển sang chế độ sáng'
                        : 'Chuyển sang chế độ tối',
                  ),
                  IconButton(
                    icon: Icon(
                      isGridView ? Icons.list : Icons.grid_view,
                      color: Colors.white,
                    ),
                    onPressed: () => setState(() => isGridView = !isGridView),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      if (value == 'refresh') {
                        refreshNotes();
                      } else if (value == 'sort_priority') {
                        setState(() {
                          sortOption = 'priority';
                          sortNotes();
                        });
                      } else if (value == 'sort_time') {
                        setState(() {
                          sortOption = 'createdAt';
                          sortNotes();
                        });
                      } else if (value == 'logout') {
                        widget.onLogout();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                          value: 'refresh', child: Text('Làm mới')),
                      const PopupMenuItem(
                          value: 'sort_priority',
                          child: Text('Sắp xếp theo ưu tiên')),
                      const PopupMenuItem(
                          value: 'sort_time', child: Text('Sắp xếp theo thời gian')),
                      const PopupMenuItem(value: 'logout', child: Text('Đăng xuất')),
                    ],
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Colors.white.withOpacity(0.9), // Nền trắng mờ
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Tìm kiếm ghi chú',
                          labelStyle: TextStyle(color: Colors.deepPurple.shade400),
                          border: InputBorder.none,
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.deepPurple,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                            refreshNotes();
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                sliver: isLoading
                    ? const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                )
                    : notes.isEmpty
                    ? SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      'Không có ghi chú nào',
                      style: TextStyle(
                        fontSize: 18,
                        color: isDarkMode ? Colors.white : Colors.black87, // Tương phản tốt hơn
                      ),
                    ),
                  ),
                )
                    : isGridView
                    ? SliverGrid(
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final noteColor = parseColor(notes[index].color);
                      final textColor = getTextColor(noteColor);
                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: noteColor,
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              buildImage(
                                notes[index].imagePath,
                                height: 100,
                                width: double.infinity,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                notes[index].title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor, // Tương phản với nền
                                  decoration: notes[index].isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                notes[index].content.length > 50
                                    ? '${notes[index].content.substring(0, 50)}...'
                                    : notes[index].content,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textColor.withOpacity(0.8), // Tương phản với nền
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      notes[index].isCompleted
                                          ? Icons.check_circle
                                          : Icons.check_circle_outline,
                                      color: notes[index].isCompleted
                                          ? Colors.green
                                          : textColor.withOpacity(0.6),
                                    ),
                                    onPressed: () async {
                                      try {
                                        final updatedNote =
                                        notes[index].copyWith(
                                          isCompleted:
                                          !notes[index].isCompleted,
                                          modifiedAt: DateTime.now(),
                                        );
                                        await ApiService.instance
                                            .updateNote(updatedNote);
                                        refreshNotes();
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Lỗi cập nhật trạng thái: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.share,
                                      color: textColor,
                                    ),
                                    onPressed: () =>
                                        shareNote(notes[index]),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      try {
                                        await ApiService.instance
                                            .deleteNote(
                                            notes[index].id!);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Xóa ghi chú thành công'),
                                            backgroundColor:
                                            Colors.green,
                                          ),
                                        );
                                        refreshNotes();
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Lỗi xóa ghi chú: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: notes.length,
                  ),
                )
                    : SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => NoteItem(
                      note: notes[index],
                      onDelete: () async {
                        try {
                          await ApiService.instance
                              .deleteNote(notes[index].id!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                              Text('Xóa ghi chú thành công'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          refreshNotes();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lỗi xóa ghi chú: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      onShare: () => shareNote(notes[index]),
                      onToggleComplete: () async {
                        try {
                          final updatedNote = notes[index].copyWith(
                            isCompleted: !notes[index].isCompleted,
                            modifiedAt: DateTime.now(),
                          );
                          await ApiService.instance
                              .updateNote(updatedNote);
                          refreshNotes();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Lỗi cập nhật trạng thái: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                    childCount: notes.length,
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NoteFormScreen()),
            );
            if (result == true) {
              refreshNotes();
            }
          },
          backgroundColor: Colors.deepPurple,
          child: const Icon(
            Icons.add,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}