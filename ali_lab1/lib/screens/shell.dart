import 'package:flutter/material.dart';

import '../models/item.dart';
import '../models/profile.dart';
import '../models/seed_data.dart';
import 'list_tab.dart';
import 'profile_tab.dart';

class ShellScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const ShellScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _currentIndex = 0;
  late List<Item> _items;
  Profile _profile = Profile.empty();

  @override
  void initState() {
    super.initState();
    _items = List.from(SeedData.initialItems);
  }

  void _updateItem(Item updated) {
    setState(() {
      _items = _items.map((i) => i.id == updated.id ? updated : i).toList();
    });
  }

  void _addItem(Item newItem) {
    setState(() {
      _items = [newItem, ..._items];
    });
  }

  void _deleteItem(String id) {
    setState(() {
      _items = _items.where((i) => i.id != id).toList();
    });
  }

  void _updateProfile(Profile newProfile) {
    setState(() {
      _profile = newProfile;
    });
  }

  void _resetData() {
    setState(() {
      _items = List.from(SeedData.initialItems);
      _profile = Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Collect favourites for Tab 2
    final favouriteItems = _items.where((i) => i.favourite).toList();

    // Tabs definition
    final List<Widget> tabs = [
      ListTab(
        items: _items,
        profile: _profile,
        onItemChanged: _updateItem,
        onItemDeleted: _deleteItem,
        onItemAdded: _addItem,
        onNavigateToProfile: () => setState(() => _currentIndex = 2),
      ),
      // Placeholder for Favourites tab (Tab 2)
      ListTab(
        items: favouriteItems,
        profile: _profile,
        onItemChanged: _updateItem,
        onItemDeleted: _deleteItem,
        onItemAdded: _addItem,
        onNavigateToProfile: () => setState(() => _currentIndex = 2),
      ),
      // Profile Tab (Tab 3)
      ProfileTab(
        profile: _profile,
        onProfileChanged: _updateProfile,
        themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged,
        items: _items,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0
              ? 'Campus Events'
              : _currentIndex == 1
              ? 'Favourites'
              : 'Profile',
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                'Lab 01 Control Menu',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context); // Close drawer (R32)
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('About Lab 01'),
                    content: const Text(
                      'Single-screen/multi-tab Flutter application showcasing immutable states, records, sealed classes, and custom forms.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Reset Data'),
              onTap: () {
                Navigator.pop(context); // Close drawer (R32)
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Reset Data?'),
                    content: const Text(
                      'This will restore the 12 seed items and clear profile data.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          _resetData();
                          Navigator.pop(context);
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event), label: 'List'),
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
