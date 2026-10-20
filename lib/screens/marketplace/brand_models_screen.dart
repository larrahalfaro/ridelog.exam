import 'package:flutter/material.dart';

import '../../data/motorcycle_catalog_data.dart';
import '../../models/catalog_model.dart';
import '../../utils/constants.dart';
import 'model_detail_screen.dart';

class BrandModelsScreen extends StatelessWidget {
  final CatalogBrand brand;
  const BrandModelsScreen({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    final models = MotorcycleCatalogData.modelsForBrand(brand.name);

    return Scaffold(
      appBar: AppBar(title: Text(brand.name)),
      body: models.isEmpty
          ? const Center(
              child: Text('No models listed for this brand yet.',
                  style: TextStyle(color: AppColors.textSecondary)),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: models.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final model = models[i];
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            ModelDetailScreen(brand: brand, model: model),
                      ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: brand.color.withOpacity(0.18),
                            child: Icon(Icons.two_wheeler, color: brand.color),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(model.modelName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 2),
                                Text(
                                    '${model.category} • ${model.engineDisplacement}',
                                    style: const TextStyle(
                                        fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(model.priceRangeLabel,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accent)),
                              const SizedBox(height: 4),
                              const Icon(Icons.chevron_right,
                                  size: 18, color: AppColors.textSecondary),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
