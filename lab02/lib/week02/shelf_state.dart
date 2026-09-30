import 'models.dart';

sealed class ShelfState {}

class Empty extends ShelfState {}

class Ready extends ShelfState {
  final List<Book> books;
  Ready(this.books);
}

class Broken extends ShelfState {
  final String message;
  Broken(this.message);
}

String describe(ShelfState state) => switch (state) {
  Empty() => 'The shelf is empty.',
  Ready(books: var b) => 'Ready with ${b.length} book(s).',
  Broken(message: var m) => 'Shelf broken: $m',
};

({int count, double avgPages}) statsOf(List<Book> books) => (
count: books.length,
avgPages: books.isEmpty
    ? 0
    : books.fold<int>(0, (sum, b) => sum + b.pages) / books.length,
);