import 'package:flutter/material.dart';

import '../../db/database_helper.dart';
import '../../models/motorcycle.dart';
import '../../models/user.dart';
import '../../utils/constants.dart';

/// Single screen handling both Create and Update — pass an existing
/// [motorcycle] to edit it, or omit it to create a new one.
class AddEditMotorcycleScreen extends StatefulWidget {
  final AppUser user;
  final Motorcycle? motorcycle;
  const AddEditMotorcycleScreen({super.key, required this.user, this.motorcycle});

  @override
  State<AddEditMotorcycleScreen> createState() => _AddEditMotorcycleScreenState();
}

class _AddEditMotorcycleScreenState extends State<AddEditMotorcycleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _brandCtrl;
  late TextEditingController _modelCtrl;
  late TextEditingController _yearCtrl;
  late TextEditingController _plateCtrl;
  late TextEditingController _odometerCtrl;
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.motorcycle != null;

  @override
  void initState() {
    super.initState();
    final m = widget.motorcycle;
    _brandCtrl = TextEditingController(text: m?.brand ?? '');
    _modelCtrl = TextEditingController(text: m?.model ?? '');
    _yearCtrl =
        TextEditingController(text: (m?.year ?? DateTime.now().year).toString());
    _plateCtrl = TextEditingController(text: m?.plateNumber ?? '');
    _odometerCtrl =
        TextEditingController(text: (m?.currentOdometer ?? 0).toString());
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final db = DatabaseHelper.instance;
      if (_isEditing) {
        final updated = widget.motorcycle!.copyWith(
          brand: _brandCtrl.text.trim(),
          model: _modelCtrl.text.trim(),
          year: int.parse(_yearCtrl.text.trim()),
          plateNumber: _plateCtrl.text.trim().isEmpty ? null : _plateCtrl.text.trim(),
          currentOdometer: int.parse(_odometerCtrl.text.trim()),
        );
        await db.updateMotorcycle(updated);
      } else {
        final bike = Motorcycle(
          userId: widget.user.id!,
          brand: _brandCtrl.text.trim(),
          model: _modelCtrl.text.trim(),
          year: int.parse(_yearCtrl.text.trim()),
          plateNumber: _plateCtrl.text.trim().isEmpty ? null : _plateCtrl.text.trim(),
          currentOdometer: int.parse(_odometerCtrl.text.trim()),
          createdAt: DateTime.now().toIso8601String(),
        );
        await db.createMotorcycle(bike);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Unable to save motorcycle: $error';
      });
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Motorcycle?'),
        content: const Text(
            'This will permanently delete this motorcycle and all its maintenance and fuel logs.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await DatabaseHelper.instance.deleteMotorcycle(widget.motorcycle!.id!);
        if (!mounted) return;
        Navigator.of(context).pop(true);
        Navigator.of(context).pop(true); // also pop the detail screen
      } catch (error) {
        if (!mounted) return;
        setState(() => _error = 'Unable to delete motorcycle: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Motorcycle' : 'Add Motorcycle'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _brandCtrl,
                  decoration: const InputDecoration(labelText: 'Brand'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _modelCtrl,
                  decoration: const InputDecoration(labelText: 'Model'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _yearCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Year'),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 1980 || n > DateTime.now().year + 1) {
                      return 'Enter a valid year';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _plateCtrl,
                  decoration: const InputDecoration(labelText: 'Plate Number (optional)'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _odometerCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Current Odometer (km)'),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 0) return 'Enter a valid odometer reading';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: AppColors.danger)),
                  const SizedBox(height: 12),
                ],
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black))
                      : Text(_isEditing ? 'Save Changes' : 'Add Motorcycle'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
