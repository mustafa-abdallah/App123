import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../database/database.dart';
import '../../../repositories/providers.dart';

final notesQueryProvider = StateProvider<String>((ref) => '');

/// كل الملاحظات، أو نتائج البحث عند وجود نص في خانة البحث.
final visibleNotesProvider = StreamProvider.autoDispose<List<Note>>((ref) {
  final repo = ref.watch(notesRepositoryProvider);
  final q = ref.watch(notesQueryProvider).trim();
  if (q.isEmpty) return repo.watchAll();
  return Stream.fromFuture(repo.search(q));
});
