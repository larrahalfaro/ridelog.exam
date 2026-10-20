import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../db/database_helper.dart';
import '../../models/fuel_log.dart';
import '../../models/motorcycle.dart';
import '../../utils/constants.dart';
import 'add_edit_fuel_screen.dart';

class FuelListScreen extends StatefulWidget {
  final Motorcycle motorcycle;
  const FuelListScreen({super.key, required this.motorcycle});

  @override
  State<FuelListScreen> createState() => _FuelListScreenState();
}

class _FuelListScreenState extends State<FuelListScreen> {
  List<FuelLog> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final logs = await DatabaseHelper.instance.getFuelLogs(widget.motorcycle.id!);
    if (!mounted) return;
    setState(() {
      _logs = logs;
      _loading = false;
    });
  }

  Future<void> _delete(FuelLog log) async {
    await DatabaseHelper.instance.deleteFuelLog(log.id!);
    _load();
  }

  /// Fuel efficiency (km/L) between this fill-up and the previous
  /// full-tank fill-up — the standard way riders calculate mileage.
  String? _efficiencyFor(int index) {
    final current = _logs[index];
    if (!current.isFullTank) return null;

    // Logs are sorted DESC by date; find the previous (older) full-tank entry.
    for (int j = index + 1; j < _logs.length; j++) {
      if (_logs[j].isFullTank) {
        final distance = current.odometerAtFill - _logs[j].odometerAtFill;
        if (distance <= 0 || current.liters <= 0) return null;
        final kmPerLiter = distance / current.liters;
        return '${kmPerLiter.toStringAsFixed(1)} km/L';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(symbol: '₱', decimalDigits: 0);
    final dateFmt = DateFormat('MMM d, yyyy');

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_fuel',
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => AddEditFuelScreen(motorcycle: widget.motorcycle),
          ));
          _load();
        },
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _logs.isEmpty
              ? const Center(
                  child: Text('No fuel records yet. Tap + to add one.',
                      style: TextStyle(color: AppColors.textSecondary)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _logs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final log = _logs[i];
                    final efficiency = _efficiencyFor(i);
                    return Dismissible(
                      key: ValueKey(log.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _delete(log),
                      child: Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.surfaceLight,
                            child: Icon(Icons.local_gas_station, color: AppColors.accent),
                          ),
                          title: Text(
                              '${log.liters.toStringAsFixed(1)} L${log.isFullTank ? " (Full)" : ""}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              '${dateFmt.format(DateTime.parse(log.fillDate))} • ${log.odometerAtFill} km${efficiency != null ? " • $efficiency" : ""}'),
                          trailing: Text(currencyFmt.format(log.cost),
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          onTap: () async {
                            await Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => AddEditFuelScreen(
                                  motorcycle: widget.motorcycle, log: log),
                            ));
                            _load();
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
