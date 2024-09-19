import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqflite.dart' as sql;

class QueryHelper {
  //table creation

  static Future<void> createTable(sql.Database database) async {
    await database.execute("""
CREATE TABLE notes (
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  title TEXT,
  description TEXT,
  time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
)
""");
  }

//create db

  static Future<sql.Database> db() async {
    return sql.openDatabase("note_database.db", version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTable(database);
    });
  }

//insert a new note into table

  static Future<int> createNote(String title, String? description) async {
    final db = await QueryHelper.db();
    final dataNote = {'title': title, 'description': description};
    final id = await db.insert('notes', dataNote,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  //get all notes
  static Future<List<Map<String, dynamic>>> getAllNotes() async {
    final db = await QueryHelper.db();
    return db.query('notes', orderBy: 'id');
  }

  //get single note
  static Future<List<Map<String, dynamic>>> getNote(int id) async {
    final db = await QueryHelper.db();
    return db.query('notes', where: "id=?", whereArgs: [id], limit: 1);
  }

  //update note
  static Future<int> updateNote(
      int id, String title, String? description) async {
    final db = await QueryHelper.db();

    final dataNote = {
      'title': title,
      'description': description,
      'time': DateTime.now().toString()
    };
    final result =
        await db.update('notes', dataNote, where: "id=?", whereArgs: [id]);
    return result;
  }

  //delete note
  static Future<void> deleteNote(int id) async {
    final db = await QueryHelper.db();
    try {
      await db.delete('notes', where: "id=?", whereArgs: [id]);
    } catch (e) {
      e.toString();
    }
  }

  //delete all notes

  static Future<void> deleteAllNotes() async {
    final db = await QueryHelper.db();
    try {
      await db.delete('notes');
    } catch (e) {
      print(e.toString());
    }
  }

  //to find count in db

  static Future<int> getNoteCount() async {
    final db = await QueryHelper.db();
    try {
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT (*) FROM notes'),
      );
      return count ?? 0;
    } catch (e) {
      print(e.toString());
      return 0;
    }
  }
}
