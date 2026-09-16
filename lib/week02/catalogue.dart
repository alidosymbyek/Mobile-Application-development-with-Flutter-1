import 'models.dart';

class Library {
  List<Book> get books => items.whereType<Book>().toList();

  List<String> get allTitles => items.map((i) => i.title).toList();

  List<Book> get booksAfterYear2010 => books.where((b) => b.year > 2010).toList();

  double get averagePages =>
      books.isEmpty ? 0 : books.fold<int>(0, (sum, b) => sum + b.pages) / books.length;
// fold, not reduce: reduce has no initial value and throws on an empty
// list; fold starts from 0, so an empty library gives 0 instead of crashing.

  Map<String, int> get bookCountByAuthor => books.fold<Map<String, int>>(
    {},
        (map, b) => map..update(b.author.name, (v) => v + 1, ifAbsent: () => 1),
  );

  Set<String> get authorNames => books.map((b) => b.author.name).toSet();

  Set<Genre> get genresPresent => books.map((b) => b.genre).toSet();

  List<String> get catalogueDisplay => [
    'CATALOGUE',
    for (final b in books) '${b.title} (${b.year})',
    ...authorNames,
    if (books.any((b) => b.pages == 0)) '(incomplete data)',
  ];
  final List<LibraryItem> items = [];

  void add(LibraryItem item) => items.add(item);

  Book? findByTitle(String title) {
    for (final item in items) {
      if (item is Book && item.title == title) return item;
    }
    return null;
  }

  String countryOf(String title) => findByTitle(title)?.author.country ?? 'unknown';

  late final DateTime openedAt;

  void open() {
    openedAt = DateTime.now();
  }

  String? _cachedReport;

  String buildReport() {
    return _cachedReport ??= items.map((i) => i.describe()).join('\n');
  }
}