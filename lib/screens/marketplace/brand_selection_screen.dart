import 'package:flutter/material.dart';

import '../../data/motorcycle_catalog_data.dart';
import '../../utils/constants.dart';
import 'brand_models_screen.dart';

/// Entry point of the Marketplace feature: pick a brand, then browse its
/// models with prices. Static catalog data — no login or database needed
/// for this screen, so it's safe to open even with a fresh install.
class BrandSelectionScreen extends StatelessWidget {
  const BrandSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Marketplace')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Browse motorcycle brands and see model prices — great for planning your next bike.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.15,
                ),
                itemCount: MotorcycleCatalogData.brands.length,
                itemBuilder: (context, i) {
                  final brand = MotorcycleCatalogData.brands[i];
                  final modelCount =
                      MotorcycleCatalogData.modelsForBrand(brand.name).length;

                  return Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => BrandModelsScreen(brand: brand),
                        ));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: brand.color.withOpacity(0.18),
                              child: Icon(brand.icon, color: brand.color, size: 28),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              brand.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$modelCount model${modelCount == 1 ? "" : "s"}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
