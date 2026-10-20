import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../db/database_helper.dart';
import '../../models/fuel_log.dart';
import '../../models/maintenance_log.dart';
import '../../models/motorcycle.dart';
import '../../models/user.dart';
import '../../utils/constants.dart';

class ReportsScreen extends StatefulWidget {
  final AppUser user;
  const ReportsScreen({super.key, required this.user});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<Motorcycle> _bikes = [];
  Motorcycle? _selectedBike;
  List<MaintenanceLog> _maintenance = [];
  List<FuelLog> _fuel = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBikes();
  }

  Future<void> _loadBikes() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bikes = await DatabaseHelper.instance
          .getMotorcyclesForUser(widget.user.id!);
      if (!mounted) return;
      setState(() {
        _bikes = bikes;
        _selectedBike = bikes.isNotEmpty ? bikes.first : null;
      });
      if (_selectedBike != null) await _loadLogs();
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Unable to load reports: $error';
      });
    }
  }

  Future<void> _loadLogs() async {
    try {
      final db = DatabaseHelper.instance;
      final maintenance = await db.getMaintenanceLogs(_selectedBike!.id!);
      final fuel = await db.getFuelLogs(_selectedBike!.id!);
      if (!mounted) return;
      setState(() {
        _maintenance = maintenance;
        _fuel = fuel;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Unable to load report logs: $error');
      rethrow;
    }
  }

  /// Groups combined maintenance + fuel cost by the last 6 calendar months.
  List<double> _monthlySpendLast6Months() {
    final now = DateTime.now();
    final months = List.generate(
        6, (i) => DateTime(now.year, now.month - (5 - i), 1));
    final totals = List.filled(6, 0.0);

    for (final m in _maintenance) {
      final d = DateTime.tryParse(m.serviceDate);
      if (d == null) continue;
      for (int i = 0; i < months.length; i++) {
        if (d.year == months[i].year && d.month == months[i].month) {
          totals[i] += m.cost;
        }
      }
    }
    for (final f in _fuel) {
      final d = DateTime.tryParse(f.fillDate);
      if (d == null) continue;
      for (int i = 0; i < months.length; i++) {
        if (d.year == months[i].year && d.month == months[i].month) {
          totals[i] += f.cost;
        }
      }
    }
    return totals;
  }

  List<String> _monthLabelsLast6Months() {
    final now = DateTime.now();
    final months = List.generate(
        6, (i) => DateTime(now.year, now.month - (5 - i), 1));
    return months.map((m) => DateFormat('MMM').format(m)).toList();
  }

  /// km/L for each consecutive full-tank-to-full-tank pair, oldest to newest.
  List<double> _fuelEfficiencySeries() {
    final sorted = [..._fuel]..sort((a, b) =>
        DateTime.parse(a.fillDate).compareTo(DateTime.parse(b.fillDate)));
    final fullTanks = sorted.where((f) => f.isFullTank).toList();
    final series = <double>[];
    for (int i = 1; i < fullTanks.length; i++) {
      final distance =
          fullTanks[i].odometerAtFill - fullTanks[i - 1].odometerAtFill;
      if (distance > 0 && fullTanks[i].liters > 0) {
        series.add(distance / fullTanks[i].liters);
      }
    }
    return series;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(
        symbol: '${widget.user.preferredCurrency} ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _error != null
            ? _buildErrorState()
          : _bikes.isEmpty
              ? const Center(
                  child: Text('Add a motorcycle to see reports.',
                      style: TextStyle(color: AppColors.textSecondary)),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildBikeSelector(),
                    const SizedBox(height: 20),
                    _buildTotalsRow(currencyFmt),
                    const SizedBox(height: 24),
                    const Text('Monthly Spend (last 6 months)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    SizedBox(height: 220, child: _buildSpendChart()),
                    const SizedBox(height: 28),
                    const Text('Fuel Efficiency Trend (km/L)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    SizedBox(height: 220, child: _buildEfficiencyChart()),
                    const SizedBox(height: 28),
                    const Text('Cost Breakdown',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    SizedBox(height: 220, child: _buildBreakdownPie(currencyFmt)),
                  ],
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
              onPressed: _loadBikes,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBikeSelector() {
    return DropdownButtonFormField<Motorcycle>(
      value: _selectedBike,
      decoration: const InputDecoration(labelText: 'Motorcycle'),
      dropdownColor: AppColors.surfaceLight,
      items: _bikes
          .map((b) => DropdownMenuItem(value: b, child: Text(b.displayName)))
          .toList(),
      onChanged: (bike) async {
        setState(() => _selectedBike = bike);
        await _loadLogs();
      },
    );
  }

  Widget _buildTotalsRow(NumberFormat fmt) {
    final maintenanceTotal =
        _maintenance.fold<double>(0, (sum, m) => sum + m.cost);
    final fuelTotal = _fuel.fold<double>(0, (sum, f) => sum + f.cost);

    return Row(
      children: [
        Expanded(child: _statCard('Maintenance', fmt.format(maintenanceTotal))),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Fuel', fmt.format(fuelTotal))),
        const SizedBox(width: 12),
        Expanded(
            child: _statCard('Total', fmt.format(maintenanceTotal + fuelTotal))),
      ],
    );
  }

  Widget _statCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.accent)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendChart() {
    final totals = _monthlySpendLast6Months();
    final labels = _monthLabelsLast6Months();
    final maxY = (totals.isEmpty ? 100.0 : totals.reduce((a, b) => a > b ? a : b)) * 1.3 + 1;

    return BarChart(
      BarChartData(
        maxY: maxY,
        barGroups: List.generate(totals.length, (i) {
          return BarChartGroupData(x: i, barRods: [
            BarChartRodData(
              toY: totals[i],
              color: AppColors.accent,
              width: 18,
              borderRadius: BorderRadius.circular(4),
            ),
          ]);
        }),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(labels[i],
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildEfficiencyChart() {
    final series = _fuelEfficiencySeries();
    if (series.isEmpty) {
      return const Center(
        child: Text(
          'Log at least two full-tank fill-ups to see your efficiency trend.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
                series.length, (i) => FlSpot(i.toDouble(), series[i])),
            isCurved: true,
            color: AppColors.accent,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
                show: true, color: AppColors.accent.withOpacity(0.15)),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownPie(NumberFormat fmt) {
    final maintenanceTotal =
        _maintenance.fold<double>(0, (sum, m) => sum + m.cost);
    final fuelTotal = _fuel.fold<double>(0, (sum, f) => sum + f.cost);
    final total = maintenanceTotal + fuelTotal;

    if (total <= 0) {
      return const Center(
        child: Text('No spending recorded yet.',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  value: maintenanceTotal,
                  color: AppColors.accent,
                  title: '${(maintenanceTotal / total * 100).toStringAsFixed(0)}%',
                  radius: 60,
                  titleStyle: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
                PieChartSectionData(
                  value: fuelTotal,
                  color: AppColors.success,
                  title: '${(fuelTotal / total * 100).toStringAsFixed(0)}%',
                  radius: 60,
                  titleStyle: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(AppColors.accent, 'Maintenance'),
              const SizedBox(height: 8),
              _legendDot(AppColors.success, 'Fuel'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
            width: 12, height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }
}
