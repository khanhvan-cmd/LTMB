import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:app_02/NoteApp/DatabaseHelper/DatabaseHelper.dart';
import "package:app_02/NoteApp/Model/NoteModel.dart";
import "package:app_02/NoteApp/UI/NoteDetailScreen.dart";
import "package:app_02/NoteApp/UI/NoteForm.dart";
import "package:app_02/NoteApp/widgets/NoteItem.dart";
import "package:app_02/NoteApp/UI/NoteListScreen.dart";

class NoteDatabaseHelper {
  static final NoteDatabaseHelper instance = NoteDatabaseHelper._init();
  static Database? _database;

  NoteDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE notes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      priority INTEGER NOT NULL,
      createdAt TEXT NOT NULL,
      modifiedAt TEXT NOT NULL,
      tags TEXT,
      color TEXT,
      imagePath TEXT
    )
    ''');
  }

  // Cập nhật cơ sở dữ liệu khi có thay đổi version
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE notes ADD COLUMN imagePath TEXT');
    }
  }

  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final result = await db.query('notes');
    return result.map((json) => Note.fromMap(json)).toList();
  }

  Future<Note?> getNoteById(int id) async {
    final db = await database;
    final result = await db.query('notes', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Note.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Note>> getNotesByPriority(int priority) async {
    final db = await database;
    final result = await db.query('notes', where: 'priority = ?', whereArgs: [priority]);
    return result.map((json) => Note.fromMap(json)).toList();
  }

  Future<List<Note>> searchNotes(String query) async {
    final db = await database;
    final result = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return result.map((json) => Note.fromMap(json)).toList();
  }
}