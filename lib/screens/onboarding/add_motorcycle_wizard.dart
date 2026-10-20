import 'package:flutter/material.dart';

import '../../db/database_helper.dart';
import '../../models/motorcycle.dart';
import '../../models/user.dart';
import '../../utils/constants.dart';
import '../../widgets/main_nav_scaffold.dart';

/// Shown right after registration/login when the user has no motorcycles
/// yet. Kept as a single simple form rather than a multi-step wizard —
/// enough to demonstrate onboarding UX without over-engineering it.
class AddMotorcycleWizard extends StatefulWidget {
  final AppUser user;
  const AddMotorcycleWizard({super.key, required this.user});

  @override
  State<AddMotorcycleWizard> createState() => _AddMotorcycleWizardState();
}

class _AddMotorcycleWizardState extends State<AddMotorcycleWizard> {
  final _formKey = GlobalKey<FormState>();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController(text: DateTime.now().year.toString());
  final _plateCtrl = TextEditingController();
  final _odometerCtrl = TextEditingController(text: '0');
  bool _saving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final bike = Motorcycle(
      userId: widget.user.id!,
      brand: _brandCtrl.text.trim(),
      model: _modelCtrl.text.trim(),
      year: int.parse(_yearCtrl.text.trim()),
      plateNumber:
          _plateCtrl.text.trim().isEmpty ? null : _plateCtrl.text.trim(),
      currentOdometer: int.parse(_odometerCtrl.text.trim()),
      createdAt: DateTime.now().toIso8601String(),
    );

    await DatabaseHelper.instance.createMotorcycle(bike);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => MainNavScaffold(user: widget.user),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Your Motorcycle')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text(
                  "Let's set up your first bike so we can start tracking maintenance and fuel.",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _brandCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Brand (e.g. Honda)'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _modelCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Model (e.g. Click 125i)'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
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
                  decoration: const InputDecoration(
                      labelText: 'Plate Number (optional)'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _odometerCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Current Odometer (km)'),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 0) return 'Enter a valid odometer reading';
                    return null;
                  },
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
                      : const Text('Save & Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
