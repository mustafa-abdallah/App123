import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';

/// المصدر الوحيد لبيانات الملاحظات؛ الواجهة لا تلمس قاعدة البيانات مباشرة.
class NotesRepository {
  NotesRepository(this._db);
  final AppDatabase _db;

  /// أقل فاصل بين نسختين في سجل التعديلات أثناء الكتابة المستمرة.
  static const versionGap = Duration(minutes: 5);

  Stream<List<Note>> watchAll() {
    final q = _db.select(_db.notes)
      ..where((n) => n.deletedAt.isNull())
      ..orderBy([(n) => OrderingTerm.desc(n.updatedAt)]);
    return q.watch();
  }

  Future<List<Note>> search(String query) => _db.searchNotes(query);

  Future<Note?> getById(String id) =>
      (_db.select(_db.notes)..where((n) => n.id.equals(id))).getSingleOrNull();

  Future<String> create() async {
    final id = const Uuid().v4();
    await _db.into(_db.notes).insert(NotesCompanion.insert(id: Value(id)));
    return id;
  }

  /// يحفظ الملاحظة ويضيف نسخة في السجل عند الحاجة، كله في معاملة واحدة.
  Future<void> save(String id,
      {required String title, required String body}) {
    return _db.transaction(() async {
      final now = DateTime.now();
      await (_db.update(_db.notes)..where((n) => n.id.equals(id))).write(
        NotesCompanion(
            title: Value(title), bodyMd: Value(body), updatedAt: Value(now)),
      );
      final last = await (_db.select(_db.noteVersions)
            ..where((v) => v.noteId.equals(id))
            ..orderBy([(v) => OrderingTerm.desc(v.createdAt)])
            ..limit(1))
          .getSingleOrNull();
      final due = last == null ||
          (last.bodyMd != body && now.difference(last.createdAt) > versionGap);
      if (due) {
        await _db.into(_db.noteVersions).insert(
            NoteVersionsCompanion.insert(noteId: id, title: title, bodyMd: body));
      }
    });
  }

  /// نسخة فورية في السجل (تُستخدم قبل استرجاع نسخة قديمة).
  Future<void> snapshot(String id,
      {required String title, required String body}) async {
    await _db.into(_db.noteVersions).insert(
        NoteVersionsCompanion.insert(noteId: id, title: title, bodyMd: body));
  }

  Future<List<NoteVersion>> versions(String noteId) => (_db.select(_db.noteVersions)
        ..where((v) => v.noteId.equals(noteId))
        ..orderBy([(v) => OrderingTerm.desc(v.createdAt)]))
      .get();

  Future<void> softDelete(String id) =>
      (_db.update(_db.notes)..where((n) => n.id.equals(id)))
          .write(NotesCompanion(deletedAt: Value(DateTime.now())));

  Future<void> restore(String id) =>
      (_db.update(_db.notes)..where((n) => n.id.equals(id)))
          .write(const NotesCompanion(deletedAt: Value<DateTime?>(null)));

  /// يحذف الملاحظة نهائيًا فقط إذا كانت فارغة تمامًا (فتحها المستخدم ثم خرج).
  Future<void> deleteIfEmpty(String id) => (_db.delete(_db.notes)
        ..where((n) =>
            n.id.equals(id) & n.title.equals('') & n.bodyMd.equals('')))
      .go();
}
