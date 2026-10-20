import 'package:flutter/material.dart';

import '../../models/catalog_model.dart';
import '../../utils/constants.dart';

class ModelDetailScreen extends StatelessWidget {
  final CatalogBrand brand;
  final CatalogModel model;
  const ModelDetailScreen({super.key, required this.brand, required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(model.modelName)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: brand.color.withOpacity(0.18),
              child: Icon(Icons.two_wheeler, color: brand.color, size: 48),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '${brand.name} ${model.modelName}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              model.priceRangeLabel,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.accent),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _specRow('Category', model.category),
                  const Divider(color: AppColors.surfaceLight),
                  _specRow('Engine Displacement', model.engineDisplacement),
                  const Divider(color: AppColors.surfaceLight),
                  _specRow('Price Range', model.priceRangeLabel),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('About this model',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(model.description,
              style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Interest noted for ${brand.name} ${model.modelName}. (Demo action — no backend wired up yet.)'),
                ),
              );
            },
            icon: const Icon(Icons.favorite_border),
            label: const Text("I'm Interested"),
          ),
        ],
      ),
    );
  }

  Widget _specRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
