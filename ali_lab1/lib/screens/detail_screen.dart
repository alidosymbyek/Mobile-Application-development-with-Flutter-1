import 'dart:async';

import 'package:flutter/material.dart';

import '../models/countdown.dart';
import '../models/item.dart';
import '../utils/format.dart';
import 'form_screen.dart';

class DetailScreen extends StatefulWidget {
  final Item item;
  final String profileName;
  final ValueChanged<Item> onItemChanged;
  final ValueChanged<String> onItemDeleted;
  final VoidCallback onNavigateToProfile;

  const DetailScreen({
    super.key,
    required this.item,
    required this.profileName,
    required this.onItemChanged,
    required this.onItemDeleted,
    required this.onNavigateToProfile,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Timer _timer;
  late Item _currentItem;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
    // 1-minute Timer.periodic for countdown update (R29)
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel timer on dispose (R29)
    super.dispose();
  }

  String _renderCountdown(Countdown countdown) {
    return switch (countdown) {
      UpcomingCountdown(remaining: final d) =>
        'Starts in ${d.inDays}d ${d.inHours.remainder(24)}h',
      StartedCountdown(elapsed: final d) =>
        'Started ${d.inHours}h ${d.inMinutes.remainder(60)}m ago',
      EndedCountdown() => 'Event Ended',
    };
  }

  Future<void> _handlePrimaryAction() async {
    if (widget.profileName.trim().isEmpty) {
      // If profile name is empty, show SnackBar with action switching to profile tab (R15)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please set your name in your profile first!'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: () {
              Navigator.pop(context); // Pop detail screen
              widget.onNavigateToProfile();
            },
          ),
        ),
      );
      return;
    }

    final isAlreadyOnList = _currentItem.containsName(widget.profileName);
    final actionName = _currentItem.category == EventCategory.sports
        ? 'Join'
        : _currentItem.category == EventCategory.music
        ? 'Borrow'
        : 'Register';

    // Ask with showDialog<bool> (R15)
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isAlreadyOnList ? 'Cancel $actionName?' : 'Confirm $actionName',
        ),
        content: Text(
          isAlreadyOnList
              ? 'Do you want to remove your name from this list?'
              : 'Do you want to add your name to this list?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      List<String> updatedNames = List.from(_currentItem.names);
      if (isAlreadyOnList) {
        updatedNames.remove(widget.profileName);
      } else {
        if (!_currentItem.isFull) {
          updatedNames.add(widget.profileName);
        }
      }

      final updatedItem = _currentItem.copyWith(names: updatedNames);
      setState(() {
        _currentItem = updatedItem;
      });
      widget.onItemChanged(updatedItem);
    }
  }

  Future<void> _handleEdit() async {
    final editedItem = await Navigator.push<Item>(
      context,
      MaterialPageRoute(
        builder: (context) => FormScreen(itemToEdit: _currentItem),
      ),
    );

    if (editedItem != null && mounted) {
      setState(() {
        _currentItem = editedItem;
      });
      widget.onItemChanged(editedItem);
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      widget.onItemDeleted(_currentItem.id);
      Navigator.pop(context); // Return to list
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isUserOnList = _currentItem.containsName(widget.profileName);
    final isFull = _currentItem.isFull;

    // Primary action button label logic
    final actionLabel = _currentItem.category == EventCategory.sports
        ? (isUserOnList ? 'Leave' : 'Join')
        : _currentItem.category == EventCategory.music
        ? (isUserOnList ? 'Return' : 'Borrow')
        : (isUserOnList ? 'Unregister' : 'Register');

    // Button disabled when full and user not already on list (R16)
    final bool canPress = !isFull || isUserOnList;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _currentItem.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            // Nobody menu holding Edit and Delete (R31)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _handleEdit();
                } else if (value == 'delete') {
                  _handleDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Participants'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Stack header with image asset, category icon, and countdown (R13, R29)
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image from assets (fallback to color container if asset is missing)
                  Image.asset(
                    'assets/header_bg.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: colorScheme.surfaceContainerHighest, // Updated
                      child: Icon(
                        _currentItem.category.icon,
                        size: 64,
                        color: colorScheme.primary.withValues(
                          alpha: 0.5,
                        ), // Updated
                      ),
                    ),
                  ),
                  // Gradient overlay for readability
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7), // Updated
                        ],
                      ),
                    ),
                  ),
                  // Category icon in one corner
                  Positioned(
                    top: 16,
                    left: 16,
                    child: CircleAvatar(
                      backgroundColor: colorScheme.surface,
                      child: Icon(
                        _currentItem.category.icon,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  // Countdown in the other corner
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _renderCountdown(_currentItem.countdown),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // TabBarView Content
            Expanded(
              child: TabBarView(
                children: [
                  // Overview Tab
                  ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      Text(
                        _currentItem.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Scheduled Time'),
                        subtitle: Text(
                          FormatUtils.formatDate(_currentItem.when),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.place),
                        title: const Text('Location / Place'),
                        subtitle: Text(_currentItem.place),
                      ),
                      ListTile(
                        leading: const Icon(Icons.people),
                        title: const Text('Available Places'),
                        subtitle: Text(
                          'Taken: ${_currentItem.places.taken} / Limit: ${_currentItem.limit} (Free: ${_currentItem.places.free})',
                        ),
                      ),
                      if (_currentItem.optionalText != null) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentItem.optionalText!,
                        ), // R6 compliance via collection if
                      ],
                    ],
                  ),
                  // Participants Names Tab
                  ListView.builder(
                    itemCount: _currentItem.names.length,
                    itemBuilder: (context, index) {
                      final name = _currentItem.names[index];
                      final isYou = name == widget.profileName;
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                          ),
                        ),
                        title: Text(
                          isYou ? '$name (You)' : name,
                          style: TextStyle(
                            fontWeight: isYou
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isYou ? colorScheme.primary : null,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: canPress ? _handlePrimaryAction : null, // R16 compliance
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(actionLabel),
          ),
        ),
      ),
    );
  }
}
