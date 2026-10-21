import 'package:flutter/material.dart';

import 'countdown.dart';

enum EventCategory {
  tech('Tech', Icons.computer),
  sports('Sports', Icons.sports_soccer),
  arts('Arts', Icons.palette),
  music('Music', Icons.music_note),
  social('Social', Icons.people);

  final String label;
  final IconData icon;
  const EventCategory(this.label, this.icon);

  Color colorRole(ColorScheme scheme) {
    return switch (this) {
      EventCategory.tech => scheme.primary,
      EventCategory.sports => scheme.secondary,
      EventCategory.arts => scheme.tertiary,
      EventCategory.music => scheme.error,
      EventCategory.social => scheme.primaryContainer,
    };
  }
}

@immutable
class Item {
  final String id;
  final String title;
  final EventCategory category;
  final DateTime when;
  final int limit;
  final List<String> _names;
  final bool mode;
  final String? optionalText;
  final bool favourite;
  final String place;

  const Item({
    required this.id,
    required this.title,
    required this.category,
    required this.when,
    required this.limit,
    required this._names, // Updated to initializing formal
    required this.mode,
    this.optionalText,
    required this.favourite,
    required this.place,
  });

  Item.empty()
    : id = '',
      title = '',
      category = EventCategory.tech,
      when = DateTime.now().add(const Duration(days: 1)),
      limit = 10,
      _names = const [],
      mode = false,
      optionalText = null,
      favourite = false,
      place = '';

  List<String> get names => List.unmodifiable(_names);

  int get count => _names.length;
  int get freePlaces => limit - count;
  bool get isFull => count >= limit;
  bool get isPast => when.isBefore(DateTime.now());
  bool containsName(String name) => _names.contains(name);

  ({int taken, int free}) get places => (taken: count, free: freePlaces);

  Countdown get countdown {
    final now = DateTime.now();
    if (when.isAfter(now)) {
      return UpcomingCountdown(when.difference(now));
    } else {
      final elapsed = now.difference(when);
      if (elapsed.inHours < 24) {
        return StartedCountdown(elapsed);
      }
      return const EndedCountdown();
    }
  }

  Item copyWith({
    String? id,
    String? title,
    EventCategory? category,
    DateTime? when,
    int? limit,
    List<String>? names,
    bool? mode,
    String? optionalText,
    bool? favourite,
    String? place,
  }) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      when: when ?? this.when,
      limit: limit ?? this.limit,
      names: names ?? _names,
      mode: mode ?? this.mode,
      optionalText: optionalText ?? this.optionalText,
      favourite: favourite ?? this.favourite,
      place: place ?? this.place,
    );
  }
}
