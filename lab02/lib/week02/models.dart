class Author {
  final String name;
  final String? country;

  const Author({required this.name, this.country});

  @override
  String toString() => 'Author($name, ${country ?? 'unknown'})';
}
class Magazine extends LibraryItem {
  final int issue;

  const Magazine({required super.title, required super.year, required this.issue});

  @override
  String describe() => '$title, issue #$issue ($year)';
}
class Ghost implements LibraryItem {
  @override
  final String title;
  @override
  final int year;

  const Ghost({required this.title, required this.year});

  @override
  String describe() => '$title is a ghost — no real data';

  @override
  bool get isOld => true;
}
enum Genre {
  craft('Craft'),
  theory('Theory'),
  unknown('Unknown');

  const Genre(this.label);
  final String label;

  static Genre fromString(String? raw) => switch (raw) {
    'craft' => Genre.craft,
    'theory' => Genre.theory,
    _ => Genre.unknown,
  };
}

class Book extends LibraryItem with Borrowable {
  final int pages;
  final Author author;
  final Genre genre;
  final String? description;

  const Book({
    required super.title,
    required super.year,
    required this.pages,
    required this.author,
    required this.genre,
    this.description,
  });

  const Book.missing()
      : pages = 0,
        author = const Author(name: 'Unknown'),
        genre = Genre.unknown,
        description = null,
        super(title: 'Untitled', year: 0);

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    title: json['title'] as String? ?? 'Untitled',
    year: json['year'] as int? ?? 0,
    pages: json['pages'] as int? ?? 0,
    author: Author(
      name: json['author'] as String? ?? 'Unknown',
      country: json['country'] as String?,
    ),
    genre: Genre.fromString(json['genre'] as String?),
    description: json['description'] as String?,
  );

  bool get isLong => pages > 400;

  @override
  String describe() => '$title ($year) — ${author.name}, ${genre.label}';

  Book copyWith({
    String? title,
    int? year,
    int? pages,
    Author? author,
    Genre? genre,
    String? description,
  }) =>
      Book(
        title: title ?? this.title,
        year: year ?? this.year,
        pages: pages ?? this.pages,
        author: author ?? this.author,
        genre: genre ?? this.genre,
        description: description ?? this.description,
      );

  @override
  String toString() =>
      '$title ($year) — ${author.name}, ${genre.label}, $pages p.';
}
abstract class LibraryItem {
  final String title;
  final int year;

  const LibraryItem({required this.title, required this.year});

  String describe();

  bool get isOld => year < 2000;
}

mixin Borrowable on LibraryItem {
  String borrowLabel() => 'Borrow "$title"';
}
