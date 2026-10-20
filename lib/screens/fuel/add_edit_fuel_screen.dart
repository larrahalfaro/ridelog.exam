import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../db/database_helper.dart';
import '../../models/fuel_log.dart';
import '../../models/motorcycle.dart';
import '../../utils/constants.dart';

class AddEditFuelScreen extends StatefulWidget {
  final Motorcycle motorcycle;
  final FuelLog? log;
  const AddEditFuelScreen({super.key, required this.motorcycle, this.log});

  @override
  State<AddEditFuelScreen> createState() => _AddEditFuelScreenState();
}

class _AddEditFuelScreenState extends State<AddEditFuelScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late TextEditingController _litersCtrl;
  late TextEditingController _costCtrl;
  late TextEditingController _odometerCtrl;
  late bool _isFullTank;
  bool _saving = false;

  bool get _isEditing => widget.log != null;

  @override
  void initState() {
    super.initState();
    final l = widget.log;
    _selectedDate = l != null ? DateTime.parse(l.fillDate) : DateTime.now();
    _litersCtrl = TextEditingController(text: l?.liters.toString() ?? '');
    _costCtrl = TextEditingController(text: l?.cost.toString() ?? '');
    _odometerCtrl = TextEditingController(
        text: (l?.odometerAtFill ?? widget.motorcycle.currentOdometer).toString());
    _isFullTank = l?.isFullTank ?? true;
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
      final updated = FuelLog(
        id: widget.log!.id,
        motorcycleId: widget.motorcycle.id!,
        fillDate: _selectedDate.toIso8601String(),
        liters: double.parse(_litersCtrl.text.trim()),
        cost: double.parse(_costCtrl.text.trim()),
        odometerAtFill: int.parse(_odometerCtrl.text.trim()),
        isFullTank: _isFullTank,
        createdAt: widget.log!.createdAt,
      );
      await db.updateFuelLog(updated);
    } else {
      final log = FuelLog(
        motorcycleId: widget.motorcycle.id!,
        fillDate: _selectedDate.toIso8601String(),
        liters: double.parse(_litersCtrl.text.trim()),
        cost: double.parse(_costCtrl.text.trim()),
        odometerAtFill: int.parse(_odometerCtrl.text.trim()),
        isFullTank: _isFullTank,
        createdAt: DateTime.now().toIso8601String(),
      );
      await db.createFuelLog(log);
    }

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Fuel Log' : 'Add Fuel Log')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Fill-up Date'),
                    child: Text(DateFormat('MMM d, yyyy').format(_selectedDate)),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _litersCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Liters'),
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n <= 0) return 'Enter a valid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _costCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Total Cost'),
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n <= 0) return 'Enter a valid cost';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _odometerCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Odometer at Fill-up (km)'),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 0) return 'Enter a valid odometer reading';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Full Tank'),
                  subtitle: const Text(
                    'Turn on if you filled the tank completely — needed for accurate km/L calculation.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  activeColor: AppColors.accent,
                  value: _isFullTank,
                  onChanged: (v) => setState(() => _isFullTank = v),
                ),
                const SizedBox(height: 24),
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
