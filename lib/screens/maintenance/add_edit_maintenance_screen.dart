import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../db/database_helper.dart';
import '../../models/maintenance_log.dart';
import '../../models/motorcycle.dart';
import '../../utils/constants.dart';

class AddEditMaintenanceScreen extends StatefulWidget {
  final Motorcycle motorcycle;
  final MaintenanceLog? log;
  const AddEditMaintenanceScreen({super.key, required this.motorcycle, this.log});

  @override
  State<AddEditMaintenanceScreen> createState() =>
      _AddEditMaintenanceScreenState();
}

class _AddEditMaintenanceScreenState extends State<AddEditMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  late ServiceType _selectedType;
  late DateTime _selectedDate;
  late TextEditingController _odometerCtrl;
  late TextEditingController _costCtrl;
  late TextEditingController _shopCtrl;
  late TextEditingController _notesCtrl;
  bool _saving = false;

  bool get _isEditing => widget.log != null;

  @override
  void initState() {
    super.initState();
    final l = widget.log;
    _selectedType = l != null
        ? ServiceType.fromKey(l.serviceType)
        : ServiceType.oilChange;
    _selectedDate = l != null ? DateTime.parse(l.serviceDate) : DateTime.now();
    _odometerCtrl = TextEditingController(
        text: (l?.odometerAtService ?? widget.motorcycle.currentOdometer).toString());
    _costCtrl = TextEditingController(text: l?.cost.toString() ?? '');
    _shopCtrl = TextEditingController(text: l?.shopName ?? '');
    _notesCtrl = TextEditingController(text: l?.notes ?? '');
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final db = DatabaseHelper.instance;
    if (_isEditing) {
      final updated = MaintenanceLog(
        id: widget.log!.id,
        motorcycleId: widget.motorcycle.id!,
        serviceType: _selectedType.key,
        serviceDate: _selectedDate.toIso8601String(),
        odometerAtService: int.parse(_odometerCtrl.text.trim()),
        cost: double.parse(_costCtrl.text.trim()),
        shopName: _shopCtrl.text.trim().isEmpty ? null : _shopCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        createdAt: widget.log!.createdAt,
      );
      await db.updateMaintenanceLog(updated);
    } else {
      final log = MaintenanceLog(
        motorcycleId: widget.motorcycle.id!,
        serviceType: _selectedType.key,
        serviceDate: _selectedDate.toIso8601String(),
        odometerAtService: int.parse(_odometerCtrl.text.trim()),
        cost: double.parse(_costCtrl.text.trim()),
        shopName: _shopCtrl.text.trim().isEmpty ? null : _shopCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        createdAt: DateTime.now().toIso8601String(),
      );
      await db.createMaintenanceLog(log);
    }

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_isEditing ? 'Edit Maintenance' : 'Add Maintenance')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text('Service Type',
                    style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ServiceType.all.map((type) {
                    final selected = _selectedType.key == type.key;
                    return ChoiceChip(
                      label: Text(type.label),
                      avatar: Icon(type.icon,
                          size: 18,
                          color: selected ? Colors.black : AppColors.textSecondary),
                      selected: selected,
                      selectedColor: AppColors.accent,
                      backgroundColor: AppColors.surfaceLight,
                      labelStyle: TextStyle(
                          color: selected ? Colors.black : AppColors.textPrimary),
                      onSelected: (_) => setState(() => _selectedType = type),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Service Date'),
                    child: Text(DateFormat('MMM d, yyyy').format(_selectedDate)),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _odometerCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Odometer at Service (km)'),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 0) return 'Enter a valid odometer reading';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _costCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Cost'),
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n < 0) return 'Enter a valid cost';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _shopCtrl,
                  decoration: const InputDecoration(labelText: 'Shop Name (optional)'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Notes (optional)'),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black))
                      : Text(_isEditing ? 'Save Changes' : 'Add Record'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
