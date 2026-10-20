import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../db/database_helper.dart';
import '../../models/maintenance_log.dart';
import '../../models/motorcycle.dart';
import '../../utils/constants.dart';
import 'add_edit_maintenance_screen.dart';

class MaintenanceListScreen extends StatefulWidget {
  final Motorcycle motorcycle;
  const MaintenanceListScreen({super.key, required this.motorcycle});

  @override
  State<MaintenanceListScreen> createState() => _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends State<MaintenanceListScreen> {
  List<MaintenanceLog> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final logs =
        await DatabaseHelper.instance.getMaintenanceLogs(widget.motorcycle.id!);
    if (!mounted) return;
    setState(() {
      _logs = logs;
      _loading = false;
    });
  }

  Future<void> _delete(MaintenanceLog log) async {
    await DatabaseHelper.instance.deleteMaintenanceLog(log.id!);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(symbol: '₱', decimalDigits: 0);
    final dateFmt = DateFormat('MMM d, yyyy');

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_maintenance',
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) =>
                AddEditMaintenanceScreen(motorcycle: widget.motorcycle),
          ));
          _load();
        },
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _logs.isEmpty
              ? const Center(
                  child: Text('No maintenance records yet. Tap + to add one.',
                      style: TextStyle(color: AppColors.textSecondary)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _logs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final log = _logs[i];
                    final type = ServiceType.fromKey(log.serviceType);
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
                          leading: CircleAvatar(
                            backgroundColor: AppColors.surfaceLight,
                            child: Icon(type.icon, color: AppColors.accent),
                          ),
                          title: Text(type.label,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              '${dateFmt.format(DateTime.parse(log.serviceDate))} • ${log.odometerAtService} km${log.shopName != null ? " • ${log.shopName}" : ""}'),
                          trailing: Text(currencyFmt.format(log.cost),
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          onTap: () async {
                            await Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => AddEditMaintenanceScreen(
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
