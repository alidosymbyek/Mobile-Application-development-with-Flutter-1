import 'package:flutter/material.dart';

import '../models/item.dart';
import '../models/profile.dart';
import '../widgets/empty_state.dart';
import '../widgets/item_card.dart';
import 'detail_screen.dart';
import 'form_screen.dart';

class ListTab extends StatefulWidget {
  final List<Item> items;
  final Profile profile;
  final ValueChanged<Item> onItemChanged;
  final ValueChanged<String> onItemDeleted;
  final ValueChanged<Item> onItemAdded;
  final VoidCallback onNavigateToProfile;

  const ListTab({
    super.key,
    required this.items,
    required this.profile,
    required this.onItemChanged,
    required this.onItemDeleted,
    required this.onItemAdded,
    required this.onNavigateToProfile,
  });

  @override
  State<ListTab> createState() => _ListTabState();
}

class _ListTabState extends State<ListTab> {
  String _searchQuery = '';
  EventCategory? _selectedCategory;
  bool _showPastItems = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter logic using functional methods (R7)
    final filteredItems = widget.items.where((item) {
      final matchesSearch =
          item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.place.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == null || item.category == _selectedCategory;
      final matchesPast = _showPastItems || !item.isPast;
      return matchesSearch && matchesCategory && matchesPast;
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          // Search & Filter Header (R21)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search items...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _selectedCategory == null,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = null);
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ...EventCategory.values.map((cat) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(cat.label),
                            selected: _selectedCategory == cat,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = selected ? cat : null;
                              });
                            },
                          ),
                        );
                      }),
                      FilterChip(
                        label: const Text('Show Past'),
                        selected: _showPastItems,
                        onSelected: (selected) {
                          setState(() {
                            _showPastItems = selected;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // List / Grid Section (R20, R23)
          Expanded(
            child: filteredItems.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.event_busy,
                    message: 'No items match your criteria.',
                    actionLabel: 'Add New Item',
                    onActionPressed: () async {
                      final newItem = await Navigator.push<Item>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FormScreen(),
                        ),
                      );
                      if (newItem != null) {
                        widget.onItemAdded(newItem);
                      }
                    },
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth >= 600) {
                        // GridView for tablets (cells <= 360px wide) (R20)
                        final crossAxisCount = (constraints.maxWidth / 360)
                            .ceil();
                        return GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount > 0
                                    ? crossAxisCount
                                    : 1,
                                childAspectRatio: 3.0,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return ItemCard(
                              item: item,
                              onFavouriteToggled: widget.onItemChanged,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailScreen(
                                      item: item,
                                      profileName: widget.profile.name,
                                      onItemChanged: widget.onItemChanged,
                                      onItemDeleted: widget.onItemDeleted,
                                      onNavigateToProfile:
                                          widget.onNavigateToProfile,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      } else {
                        // ListView for phones (R20)
                        return ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: filteredItems.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return ItemCard(
                              item: item,
                              onFavouriteToggled: widget.onItemChanged,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailScreen(
                                      item: item,
                                      profileName: widget.profile.name,
                                      onItemChanged: widget.onItemChanged,
                                      onItemDeleted: widget.onItemDeleted,
                                      onNavigateToProfile:
                                          widget.onNavigateToProfile,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newItem = await Navigator.push<Item>(
            context,
            MaterialPageRoute(builder: (context) => const FormScreen()),
          );
          if (newItem != null) {
            widget.onItemAdded(newItem);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
