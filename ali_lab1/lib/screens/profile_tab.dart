import 'package:flutter/material.dart';

import '../models/item.dart';
import '../models/profile.dart';

class ProfileTab extends StatefulWidget {
  final Profile profile;
  final ValueChanged<Profile> onProfileChanged;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final List<Item> items;

  const ProfileTab({
    super.key,
    required this.profile,
    required this.onProfileChanged,
    required this.themeMode,
    required this.onThemeChanged,
    required this.items,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late TextEditingController _nameController;
  late TextEditingController _groupController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _groupController = TextEditingController(text: widget.profile.group);
  }

  @override
  void didUpdateWidget(covariant ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile.name != _nameController.text) {
      _nameController.text = widget.profile.name;
    }
    if (widget.profile.group != _groupController.text) {
      _groupController.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onProfileChanged(
        Profile(
          name: _nameController.text.trim(),
          group: _groupController.text.trim(),
        ),
      );
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Compute number of lists the user (profile name) is on (R38)
    final userName = widget.profile.name.trim();
    final listsTakenCount = userName.isEmpty
        ? 0
        : widget.items.where((item) => item.containsName(userName)).length;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'User Profile',
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(color: colorScheme.primary),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _saveProfile(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _groupController,
                decoration: const InputDecoration(
                  labelText: 'Group Code (e.g., 23B03... or ABC-123)',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _saveProfile(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Group cannot be empty';
                  }
                  // Group validator using a RegExp (R38)
                  final groupRegex = RegExp(r'^[A-Za-z0-9\-_]{3,20}$');
                  if (!groupRegex.hasMatch(value.trim())) {
                    return 'Invalid group format (3-20 alphanumeric characters, dashes, or underscores)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('Save Profile'),
              ),
            ],
          ),
        ),
        const Divider(height: 40),
        Text(
          'Statistics',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(color: colorScheme.secondary),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              userName.isEmpty
                  ? 'Enter your name above to track participation.'
                  : 'You are on $listsTakenCount lists.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
        const Divider(height: 40),
        Text(
          'Theme Preference',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(color: colorScheme.secondary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: [
            ChoiceChip(
              label: const Text('System'),
              selected: widget.themeMode == ThemeMode.system,
              onSelected: (selected) {
                if (selected) widget.onThemeChanged(ThemeMode.system);
              },
            ),
            ChoiceChip(
              label: const Text('Light'),
              selected: widget.themeMode == ThemeMode.light,
              onSelected: (selected) {
                if (selected) widget.onThemeChanged(ThemeMode.light);
              },
            ),
            ChoiceChip(
              label: const Text('Dark'),
              selected: widget.themeMode == ThemeMode.dark,
              onSelected: (selected) {
                if (selected) widget.onThemeChanged(ThemeMode.dark);
              },
            ),
          ],
        ),
      ],
    );
  }
}
