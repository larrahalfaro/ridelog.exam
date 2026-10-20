import 'package:flutter/material.dart';

/// A single motorcycle model in the browsable catalog (brand -> models -> price).
/// This is static reference data, not user-generated — it's meant to help
/// riders compare new-bike options, not to be a peer-to-peer listings board.
class CatalogModel {
  final String brand;
  final String modelName;
  final String category; // Scooter, Underbone, Sport, Naked, Cruiser, Adventure
  final int priceMin;
  final int priceMax;
  final String engineDisplacement; // e.g. "125cc"
  final String description;

  const CatalogModel({
    required this.brand,
    required this.modelName,
    required this.category,
    required this.priceMin,
    required this.priceMax,
    required this.engineDisplacement,
    required this.description,
  });

  String get priceRangeLabel {
    if (priceMin == priceMax) return '₱${_fmt(priceMin)}';
    return '₱${_fmt(priceMin)} - ₱${_fmt(priceMax)}';
  }

  static String _fmt(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }
}

/// A brand entry, mainly for the brand-selection grid (name + icon/color).
class CatalogBrand {
  final String name;
  final IconData icon;
  final Color color;

  const CatalogBrand({
    required this.name,
    required this.icon,
    required this.color,
  });
}
