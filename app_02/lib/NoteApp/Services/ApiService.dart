import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_02/NoteApp/Model/NoteModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService instance = ApiService._init();
  final String baseUrl = 'https://my-json-server.typicode.com/khanhvan-cmd/testflutter';
  final http.Client _client = http.Client();

  List<Note> _localNotes = [];

  ApiService._init() {
    _loadLocalNotes();
  }

  Future<void> _saveLocalNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = _localNotes.map((note) => jsonEncode(note.toMap())).toList();
    await prefs.setStringList('local_notes', notesJson);
  }

  Future<void> _loadLocalNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList('local_notes');
    if (notesJson != null) {
      _localNotes = notesJson
          .map((json) => Note.fromMap(jsonDecode(json)))
          .toList();
    }
  }

  static String removeDiacritics(String str) {
    const withDiacritics =
        'ÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂưăạảấầẩẫậắằẳẵặẹẻẽềềểỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỴýỷỹ';
    const withoutDiacritics =
        'AAAAEEEIIOOOOUADIOUaaaeeeiioooouadioUAAIAAIAAIAAIAAEEEOAAIAAIAAIAAIAAEEEOAAIAAIAAIAAIAAEEEOAAIAAIAAIAAIAAEEEOAAIAAIAAIAAIAAEEEYYYYY';

    String result = str;
    for (int i = 0; i < withDiacritics.length; i++) {
      result = result.replaceAll(withDiacritics[i], withoutDiacritics[i]);
    }
    return result;
  }

  Future<Note> insertNote(Note note) async {
    try {
      final response = await _client
          .post(
        Uri.parse('$baseUrl/notes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(note.toMap()),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final newNote = Note.fromMap(jsonDecode(response.body));
        _localNotes.add(newNote);
        await _saveLocalNotes();
        return newNote;
      } else {
        throw Exception('Failed to create note: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      final newNote = note.copyWith(id: (_localNotes.length + 1));
      _localNotes.add(newNote);
      await _saveLocalNotes();
      return newNote;
    }
  }

  Future<List<Note>> getAllNotes() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/notes'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        final apiNotes = jsonList.map((json) => Note.fromMap(json)).toList();

        if (_localNotes.isEmpty) {
          _localNotes = apiNotes;
        } else {
          for (var apiNote in apiNotes) {
            final index = _localNotes.indexWhere((note) => note.id == apiNote.id);
            if (index == -1) {
              _localNotes.add(apiNote);
            }
          }
        }
        await _saveLocalNotes();
        return _localNotes;
      } else {
        throw Exception('Failed to load notes: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (_localNotes.isEmpty) {
        _localNotes = [
          Note(
            id: 1,
            userId: 1,
            title: "Họp nhóm dự án",
            content: "Chuẩn bị nội dung họp nhóm cho dự án phát triển ứng dụng, phân công nhiệm vụ cho từng thành viên.",
            priority: 3,
            createdAt: DateTime.now(),
            modifiedAt: DateTime.now(),
            tags: ["công việc", "họp nhóm"],
            color: "FF0000",
            isCompleted: false,
            imagePath: "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3",
          ),
          Note(
            id: 2,
            userId: 1,
            title: "Mua sắm cuối tuần",
            content: "Lên danh sách mua sắm: gạo, dầu ăn, rau củ, thịt cá cho tuần tới. Đi siêu thị vào sáng thứ Bảy.",
            priority: 2,
            createdAt: DateTime.now(),
            modifiedAt: DateTime.now(),
            tags: ["sinh hoạt", "mua sắm"],
            color: "00FF00",
            isCompleted: false,
            imagePath: "https://images.unsplash.com/photo-1542838132-92d0d6a0a9d5?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3",
          ),
        ];
        await _saveLocalNotes();
      }
      return _localNotes;
    }
  }

  Future<Note?> getNoteById(int id) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/notes/$id'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return Note.fromMap(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to get note: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      return _localNotes.firstWhere((note) => note.id == id, orElse: () => null as Note);
    }
  }

  Future<Note> updateNote(Note note) async {
    try {
      final response = await _client
          .put(
        Uri.parse('$baseUrl/notes/${note.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(note.toMap()),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final updatedNote = Note.fromMap(jsonDecode(response.body));
        final index = _localNotes.indexWhere((n) => n.id == updatedNote.id);
        if (index != -1) {
          _localNotes[index] = updatedNote;
        }
        await _saveLocalNotes();
        return updatedNote;
      } else {
        throw Exception('Failed to update note: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      final index = _localNotes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _localNotes[index] = note;
      }
      await _saveLocalNotes();
      return note;
    }
  }

  Future<bool> deleteNote(int id) async {
    try {
      final response = await _client
          .delete(Uri.parse('$baseUrl/notes/$id'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        _localNotes.removeWhere((note) => note.id == id);
        await _saveLocalNotes();
        return true;
      } else {
        throw Exception('Failed to delete note: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _localNotes.removeWhere((note) => note.id == id);
      await _saveLocalNotes();
      return true;
    }
  }

  Future<List<Note>> getNotesByPriority(int priority) async {
    final notes = await getAllNotes();
    return notes.where((note) => note.priority == priority).toList();
  }

  Future<List<Note>> searchNotes(String query) async {
    final notes = await getAllNotes();
    if (query.isEmpty) {
      return notes;
    }

    final normalizedQuery = removeDiacritics(query).toLowerCase();

    return notes.where((note) {
      final normalizedTitle = removeDiacritics(note.title).toLowerCase();
      final normalizedContent = removeDiacritics(note.content).toLowerCase();
      return normalizedTitle.contains(normalizedQuery) ||
          normalizedContent.contains(normalizedQuery);
    }).toList();
  }
}