import 'item.dart';

class SeedData {
  static final List<Item> initialItems = [
    // 1. Mandatory: 60-character title item
    Item(
      id: '1',
      title: 'Introduction to Advanced Flutter Architecture and State Patterns', // Exactly 60 chars
      category: EventCategory.tech,
      when: DateTime.now().add(const Duration(days: 2)),
      limit: 30,
      names: ['Alice', 'Bob'],
      mode: false,
      optionalText: 'Bring your laptop with Android Studio pre-installed.',
      favourite: true,
      place: 'Room 404 // Tech Building',
    ),

    // 2. Mandatory: Item at its limit (Full)
    Item(
      id: '2',
      title: 'Championship Football Finals',
      category: EventCategory.sports,
      when: DateTime.now().add(const Duration(days: 1)),
      limit: 3,
      names: [
        'John',
        'Jane',
        'Alex',
      ], // count (3) == limit (3) -> isFull = true
      mode: false,
      optionalText: 'Cleats required on the turf.',
      favourite: false,
      place: 'Main Stadium // Pitch A',
    ),

    // 3. Mandatory: Past item
    Item(
      id: '3',
      title: 'Classical Piano Recital',
      category: EventCategory.music,
      when: DateTime.now().subtract(const Duration(days: 5)), // Past date
      limit: 50,
      names: ['Emma', 'Liam'],
      mode: false,
      optionalText: 'Enjoy an evening of Mozart and Chopin.',
      favourite: true,
      place: 'City Concert Hall',
    ),

    // 4. Mandatory: Item with mode on (e.g., online link requirement)
    Item(
      id: '4',
      title: 'Global Remote DevOps Meetup',
      category: EventCategory.tech,
      when: DateTime.now().add(const Duration(days: 4)),
      limit: 100,
      names: ['Sara'],
      mode: true, // mode on -> place must contain '//'
      optionalText: 'Discussion on Docker and Kubernetes pipelines.',
      favourite: false,
      place: 'https://zoom.us/j/example // Online Stream',
    ),

    // 5. Mandatory: Item without optional text (optionalText = null)
    Item(
      id: '5',
      title: 'Modern Art Gallery Opening',
      category: EventCategory.arts,
      when: DateTime.now().add(const Duration(days: 3)),
      limit: 25,
      names: [],
      mode: false,
      optionalText: null, // No optional text
      favourite: false,
      place: 'Downtown Gallery // Hall B',
    ),

    // 6. Regular Item 6
    Item(
      id: '6',
      title: 'Community Board Game Night',
      category: EventCategory.social,
      when: DateTime.now().add(const Duration(days: 5)),
      limit: 15,
      names: ['Chris', 'Pat'],
      mode: false,
      optionalText: 'Snacks and drinks will be provided.',
      favourite: true,
      place: 'Student Union // Lounge',
    ),

    // 7. Regular Item 7
    Item(
      id: '7',
      title: 'Basketball Training Session',
      category: EventCategory.sports,
      when: DateTime.now().add(const Duration(days: 6)),
      limit: 12,
      names: ['Jordan'],
      mode: false,
      optionalText: 'Focus on dribbling and shooting drills.',
      favourite: false,
      place: 'Gymnasium // Court 2',
    ),

    // 8. Regular Item 8
    Item(
      id: '8',
      title: 'Acoustic Jam Session',
      category: EventCategory.music,
      when: DateTime.now().add(const Duration(days: 7)),
      limit: 20,
      names: ['Taylor', 'Morgan', 'Sam'],
      mode: false,
      optionalText: 'Bring your guitars and ukuleles!',
      favourite: false,
      place: 'Open Air Amphitheater',
    ),

    // 9. Regular Item 9
    Item(
      id: '9',
      title: 'Oil Painting Workshop',
      category: EventCategory.arts,
      when: DateTime.now().add(const Duration(days: 8)),
      limit: 10,
      names: ['Anna'],
      mode: false,
      optionalText: 'All brushes and canvases supplied.',
      favourite: true,
      place: 'Art Studio 3 // Campus',
    ),

    // 10. Regular Item 10
    Item(
      id: '10',
      title: 'Python & AI Coding Dojo',
      category: EventCategory.tech,
      when: DateTime.now().add(const Duration(days: 9)),
      limit: 40,
      names: ['Dave', 'Eve'],
      mode: true,
      optionalText: 'Introductory machine learning lab session.',
      favourite: false,
      place: 'https://meet.google.com/abc-xyz // Virtual Lab',
    ),

    // 11. Regular Item 11
    Item(
      id: '11',
      title: 'Morning Yoga & Mindfulness',
      category: EventCategory.sports,
      when: DateTime.now().add(const Duration(days: 10)),
      limit: 15,
      names: ['Zoe', 'Grace'],
      mode: false,
      optionalText: 'Bring your personal yoga mats.',
      favourite: false,
      place: 'Wellness Center // Room 1',
    ),

    // 12. Regular Item 12
    Item(
      id: '12',
      title: 'Board Game Strategy Night',
      category: EventCategory.social,
      when: DateTime.now().add(const Duration(days: 11)),
      limit: 12,
      names: ['Tom', 'Jerry'],
      mode: false,
      optionalText: 'Advanced strategy games featured.',
      favourite: true,
      place: 'Library Conference Room',
    ),
  ];
}
