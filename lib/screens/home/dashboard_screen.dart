import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../db/database_helper.dart';
import '../../models/motorcycle.dart';
import '../../models/reminder.dart';
import '../../models/user.dart';
import '../../utils/constants.dart';
import '../../utils/reminder_logic.dart';
import '../../widgets/status_badge.dart';
import '../motorcycles/motorcycle_detail_screen.dart';
import '../onboarding/add_motorcycle_wizard.dart';
import '../marketplace/brand_selection_screen.dart';

class DashboardScreen extends StatefulWidget {
  final AppUser user;
  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Motorcycle> _bikes = [];
  Map<int, List<ReminderInfo>> _reminders = {};
  Map<int, double> _monthlySpend = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final db = DatabaseHelper.instance;
      final bikes = await db.getMotorcyclesForUser(widget.user.id!);

      final reminders = <int, List<ReminderInfo>>{};
      final spend = <int, double>{};

      final now = DateTime.now();
      for (final bike in bikes) {
        reminders[bike.id!] = await ReminderEngine.computeForMotorcycle(bike);

        final maintenance = await db.getMaintenanceLogs(bike.id!);
        final fuel = await db.getFuelLogs(bike.id!);
        double total = 0;
        for (final m in maintenance) {
          final d = DateTime.tryParse(m.serviceDate);
          if (d != null && d.year == now.year && d.month == now.month) {
            total += m.cost;
          }
        }
        for (final f in fuel) {
          final d = DateTime.tryParse(f.fillDate);
          if (d != null && d.year == now.year && d.month == now.month) {
            total += f.cost;
          }
        }
        spend[bike.id!] = total;
      }

      if (!mounted) return;
      setState(() {
        _bikes = bikes;
        _reminders = reminders;
        _monthlySpend = spend;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Unable to load dashboard data: $error';
      });
    }
  }

  int get _overdueCount {
    int count = 0;
    for (final list in _reminders.values) {
      count += list.where((r) => r.status == ReminderStatus.overdue).length;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(
        symbol: '${widget.user.preferredCurrency} ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${widget.user.name.split(' ').first} 👋'),
        actions: [
          IconButton(
            icon: const Icon(Icons.storefront_outlined),
            tooltip: 'Marketplace',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const BrandSelectionScreen(),
              ));
            },
          ),
        ],
      ),
        body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _error != null
            ? _buildErrorState()
          : _bikes.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.accent,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_overdueCount > 0) _buildOverdueBanner(),
                      _buildMarketplaceBanner(),
                      const SizedBox(height: 20),
                      Text('Your Motorcycles',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ..._bikes.map((bike) => _buildBikeCard(bike, currencyFmt)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.two_wheeler,
                size: 72, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text('No motorcycles yet',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text(
              'Add your first motorcycle to start tracking maintenance and fuel.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => AddMotorcycleWizard(user: widget.user),
                ));
                _load();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Motorcycle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverdueBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.danger),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$_overdueCount service${_overdueCount > 1 ? "s are" : " is"} overdue. Check Reminders.',
              style: const TextStyle(
                  color: AppColors.danger, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplaceBanner() {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const BrandSelectionScreen(),
          ));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.surfaceLight,
                child: Icon(Icons.storefront_outlined, color: AppColors.accent),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Shopping for a new bike?',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Browse brands and models with prices',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBikeCard(Motorcycle bike, NumberFormat currencyFmt) {
    final reminders = _reminders[bike.id!] ?? [];
    final overdue = reminders.where((r) => r.status == ReminderStatus.overdue).length;
    final spend = _monthlySpend[bike.id!] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => MotorcycleDetailScreen(user: widget.user, motorcycle: bike),
          ));
          _load();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.surfaceLight,
                    child: Icon(Icons.two_wheeler, color: AppColors.accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bike.displayName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${bike.currentOdometer} km',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  if (overdue > 0) const StatusBadge(status: ReminderStatus.overdue),
                ],
              ),
              const Divider(height: 24, color: AppColors.surfaceLight),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('This month: ${currencyFmt.format(spend)}',
                      style: const TextStyle(color: AppColors.textSecondary)),
                  const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
