import 'data.dart';
import 'models.dart';
import 'catalogue.dart';
import 'shelf_state.dart';

void main() {
  final library = Library();
  for (final json in rawBooks) {
    library.add(Book.fromJson(json));
  }

  print('Titles: ${library.allTitles}');
  print('After 2010: ${library.booksAfterYear2010.map((b) => b.title).toList()}');
  print('Avg pages: ${library.averagePages}');
  print('By author: ${library.bookCountByAuthor}');
  print('Authors: ${library.authorNames}');
  print('Genres: ${library.genresPresent}');
  print(library.catalogueDisplay.join('\n'));

  final stats = statsOf(library.books);
  print('Stats: count=${stats.count}, avgPages=${stats.avgPages}');

  final states = [Empty(), Ready(library.books), Broken('shelf collapsed')];
  for (final s in states) {
    print(describe(s));
  }
}