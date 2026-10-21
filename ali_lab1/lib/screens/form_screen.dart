import 'package:flutter/material.dart';

import '../models/item.dart';
import '../utils/format.dart';

class FormScreen extends StatefulWidget {
  final Item? itemToEdit;

  const FormScreen({super.key, this.itemToEdit});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers and FocusNodes (R35)
  late TextEditingController _titleController;
  late TextEditingController _placeController;
  late TextEditingController _limitController;
  late TextEditingController _optionalTextController;

  final FocusNode _titleFocus = FocusNode();
  final FocusNode _placeFocus = FocusNode();
  final FocusNode _limitFocus = FocusNode();
  final FocusNode _optionalTextFocus = FocusNode();

  late EventCategory _selectedCategory;
  late DateTime _selectedDateTime;
  late bool _mode;
  late bool _favourite;
  late List<String> _existingNames;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.itemToEdit;

    _titleController = TextEditingController(text: item?.title ?? '');
    _placeController = TextEditingController(text: item?.place ?? '');
    _limitController = TextEditingController(
      text: item?.limit.toString() ?? '10',
    );
    _optionalTextController = TextEditingController(
      text: item?.optionalText ?? '',
    );

    _selectedCategory = item?.category ?? EventCategory.tech;
    _selectedDateTime =
        item?.when ?? DateTime.now().add(const Duration(days: 1));
    _mode = item?.mode ?? false;
    _favourite = item?.favourite ?? false;
    _existingNames = item?.names ?? const [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    _limitController.dispose();
    _optionalTextController.dispose();

    _titleFocus.dispose();
    _placeFocus.dispose();
    _limitFocus.dispose();
    _optionalTextFocus.dispose();
    super.dispose();
  }

  /// Checks if the current form values differ from initial values (R30)
  bool get _isDirty {
    final original = widget.itemToEdit;
    if (original == null) {
      return _titleController.text.isNotEmpty ||
          _placeController.text.isNotEmpty ||
          _limitController.text != '10' ||
          _optionalTextController.text.isNotEmpty ||
          _mode != false ||
          _selectedCategory != EventCategory.tech;
    }

    return _titleController.text != original.title ||
        _placeController.text != original.place ||
        _limitController.text != original.limit.toString() ||
        _optionalTextController.text != (original.optionalText ?? '') ||
        _mode != original.mode ||
        _selectedCategory != original.category ||
        !_selectedDateTime.isAtSameMomentAs(original.when);
  }

  /// Date & Time pickers combined into one DateTime (R36)
  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (pickedTime == null || !mounted) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  /// Simulated 1-second save operation (R17)
  Future<void> _saveForm() async {
    if (_isSaving) return; // Prevent double taps (R17)

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSaving = true;
      });

      // Simulate network/storage save gap
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return; // Check mounted after await (R14)

      final newItem = Item(
        id:
            widget.itemToEdit?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        category: _selectedCategory,
        when: _selectedDateTime,
        limit: int.parse(_limitController.text.trim()),
        names: _existingNames,
        mode: _mode,
        optionalText: _optionalTextController.text.trim().isEmpty
            ? null
            : _optionalTextController.text.trim(),
        favourite: _favourite,
        place: _placeController.text.trim(),
      );

      Navigator.pop(context, newItem); // Pop created/edited item (R26)
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.itemToEdit != null;

    return PopScope(
      canPop: !_isDirty || _isSaving, // PopScope dirty protection (R30)
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard changes?'),
            content: const Text(
              'You have unsaved changes. Are you sure you want to leave?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Discard'),
              ),
            ],
          ),
        );
        if (shouldPop == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context)
            .unfocus(), // Tap outside dismisses keyboard (R35)
        child: Scaffold(
          appBar: AppBar(title: Text(isEditing ? 'Edit Item' : 'New Item')),
          body: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction, // (R33)
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Title Field (3-60 chars) (R34)
                TextFormField(
                  controller: _titleController,
                  focusNode: _titleFocus,
                  maxLength: 60,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    hintText: 'Enter title (3-60 characters)',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_placeFocus),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.length < 3 || trimmed.length > 60) {
                      return 'Title must be between 3 and 60 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category Dropdown
                DropdownButtonFormField<EventCategory>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category *',
                    border: OutlineInputBorder(),
                  ),
                  items: EventCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Row(
                        children: [
                          Icon(cat.icon, size: 20),
                          const SizedBox(width: 8),
                          Text(cat.label),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
                const SizedBox(height: 16),

                // Mode Switch (R34)
                SwitchListTile(
                  title: const Text('Online Mode'),
                  subtitle: const Text(
                    'Enables online link validation for location',
                  ),
                  value: _mode,
                  onChanged: (val) => setState(() => _mode = val),
                ),
                const SizedBox(height: 16),

                // Location / Place Field (R34)
                TextFormField(
                  controller: _placeController,
                  focusNode: _placeFocus,
                  decoration: InputDecoration(
                    labelText: _mode
                        ? 'Location (Must contain //) *'
                        : 'Location *',
                    border: const OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_limitFocus),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return 'Location is required';
                    if (_mode && !trimmed.contains('//')) {
                      return 'Online mode location must contain "//"';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Capacity Limit Field (R34)
                TextFormField(
                  controller: _limitController,
                  focusNode: _limitFocus,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Participant Limit (1-500) *',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_optionalTextFocus),
                  validator: (value) {
                    final parsed = int.tryParse(value?.trim() ?? '');
                    if (parsed == null || parsed < 1 || parsed > 500) {
                      return 'Limit must be an integer between 1 and 500';
                    }
                    if (parsed < _existingNames.length) {
                      return 'Limit cannot be lower than existing participants (${_existingNames.length})';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date & Time Picker (R36)
                InkWell(
                  onTap: _pickDateTime,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date & Time *',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(FormatUtils.formatDate(_selectedDateTime)),
                  ),
                ),
                const SizedBox(height: 16),

                // Optional Description Field (R6)
                TextFormField(
                  controller: _optionalTextController,
                  focusNode: _optionalTextFocus,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Optional Description',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),

                // Save Button with Progress Indicator (R17)
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEditing ? 'Update Item' : 'Save Item'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
