import 'package:flutter/material.dart';

import '../../db/database_helper.dart';
import '../../models/user.dart';
import '../../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  final AppUser user;
  const SettingsScreen({super.key, required this.user});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _unit;
  late String _currency;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _unit = widget.user.preferredUnit;
    _currency = widget.user.preferredCurrency;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final updated = widget.user.copyWith(
      preferredUnit: _unit,
      preferredCurrency: _currency,
    );
    await DatabaseHelper.instance.updateUser(updated);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Distance Unit',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'km', label: Text('Kilometers')),
                ButtonSegment(value: 'mi', label: Text('Miles')),
              ],
              selected: {_unit},
              onSelectionChanged: (v) => setState(() => _unit = v.first),
            ),
            const SizedBox(height: 24),
            const Text('Currency',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _currency,
              dropdownColor: AppColors.surfaceLight,
              items: const ['PHP', 'USD', 'EUR', 'JPY', 'IDR', 'MYR']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _currency = v!),
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
                  : const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
