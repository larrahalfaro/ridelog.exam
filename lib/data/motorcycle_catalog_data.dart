import 'package:flutter/material.dart';

import '../models/catalog_model.dart';

/// Static, hardcoded sample data for the Marketplace/catalog browsing
/// feature. In a real deployment this would come from an API or a
/// dedicated catalog table — for a student project, hardcoding it here
/// keeps the feature simple to demonstrate without needing to seed a
/// database or fetch from the internet. Feel free to add/edit entries.
class MotorcycleCatalogData {
  static const List<CatalogBrand> brands = [
    CatalogBrand(name: 'Honda', icon: Icons.two_wheeler, color: Color(0xFFE30613)),
    CatalogBrand(name: 'Yamaha', icon: Icons.two_wheeler, color: Color(0xFF1A3C8F)),
    CatalogBrand(name: 'Suzuki', icon: Icons.two_wheeler, color: Color(0xFF00308F)),
    CatalogBrand(name: 'Kawasaki', icon: Icons.two_wheeler, color: Color(0xFF00A650)),
    CatalogBrand(name: 'Royal Enfield', icon: Icons.two_wheeler, color: Color(0xFF6B4226)),
    CatalogBrand(name: 'KTM', icon: Icons.two_wheeler, color: Color(0xFFFF6600)),
  ];

  static const List<CatalogModel> models = [
    // Honda
    CatalogModel(
      brand: 'Honda',
      modelName: 'Click 125i',
      category: 'Scooter',
      priceMin: 84900,
      priceMax: 92900,
      engineDisplacement: '125cc',
      description:
          'A best-selling commuter scooter known for fuel efficiency and a smooth automatic transmission — a common first bike for daily riding.',
    ),
    CatalogModel(
      brand: 'Honda',
      modelName: 'BeAT',
      category: 'Scooter',
      priceMin: 68900,
      priceMax: 74900,
      engineDisplacement: '110cc',
      description:
          'A lightweight, budget-friendly scooter built for short city trips and easy handling for new riders.',
    ),
    CatalogModel(
      brand: 'Honda',
      modelName: 'CB150R',
      category: 'Naked',
      priceMin: 149900,
      priceMax: 159900,
      engineDisplacement: '150cc',
      description:
          'A sportier naked bike with a manual transmission, aimed at riders who want more performance than a scooter offers.',
    ),

    // Yamaha
    CatalogModel(
      brand: 'Yamaha',
      modelName: 'Mio i125',
      category: 'Scooter',
      priceMin: 69900,
      priceMax: 76900,
      engineDisplacement: '125cc',
      description:
          'One of the most popular entry-level scooters, favored for its low maintenance cost and compact size.',
    ),
    CatalogModel(
      brand: 'Yamaha',
      modelName: 'NMAX',
      category: 'Scooter',
      priceMin: 139900,
      priceMax: 149900,
      engineDisplacement: '155cc',
      description:
          'A premium maxi-scooter with more power and highway-capable comfort, popular for longer commutes.',
    ),
    CatalogModel(
      brand: 'Yamaha',
      modelName: 'MT-15',
      category: 'Naked',
      priceMin: 139900,
      priceMax: 149900,
      engineDisplacement: '155cc',
      description:
          'A lightweight naked sportbike with aggressive styling, popular among younger riders wanting a manual bike.',
    ),

    // Suzuki
    CatalogModel(
      brand: 'Suzuki',
      modelName: 'Raider R150',
      category: 'Underbone',
      priceMin: 119900,
      priceMax: 129900,
      engineDisplacement: '150cc',
      description:
          'A long-running underbone favorite known for its racing-inspired looks and peppy performance.',
    ),
    CatalogModel(
      brand: 'Suzuki',
      modelName: 'Skydrive',
      category: 'Scooter',
      priceMin: 74900,
      priceMax: 79900,
      engineDisplacement: '125cc',
      description:
          'A practical automatic scooter aimed at everyday commuting with a comfortable seat height.',
    ),

    // Kawasaki
    CatalogModel(
      brand: 'Kawasaki',
      modelName: 'Barako II',
      category: 'Underbone',
      priceMin: 84900,
      priceMax: 89900,
      engineDisplacement: '175cc',
      description:
          'A rugged utility underbone bike popular with riders who need extra load capacity and durability.',
    ),
    CatalogModel(
      brand: 'Kawasaki',
      modelName: 'Rouser NS200',
      category: 'Naked',
      priceMin: 139900,
      priceMax: 149900,
      engineDisplacement: '200cc',
      description:
          'A muscular naked bike with a bigger engine, aimed at riders who want more power for highway riding.',
    ),

    // Royal Enfield
    CatalogModel(
      brand: 'Royal Enfield',
      modelName: 'Classic 350',
      category: 'Cruiser',
      priceMin: 249000,
      priceMax: 269000,
      engineDisplacement: '349cc',
      description:
          'A retro-styled cruiser with a distinctive thump exhaust note, popular for weekend long rides.',
    ),
    CatalogModel(
      brand: 'Royal Enfield',
      modelName: 'Himalayan',
      category: 'Adventure',
      priceMin: 279000,
      priceMax: 299000,
      engineDisplacement: '411cc',
      description:
          'An adventure-touring bike built for mixed on/off-road riding and long-distance comfort.',
    ),

    // KTM
    CatalogModel(
      brand: 'KTM',
      modelName: 'Duke 200',
      category: 'Naked',
      priceMin: 189000,
      priceMax: 199000,
      engineDisplacement: '200cc',
      description:
          'A sharp-handling naked bike with sporty ergonomics, popular among riders who want aggressive performance in a lighter package.',
    ),
    CatalogModel(
      brand: 'KTM',
      modelName: 'Adventure 390',
      category: 'Adventure',
      priceMin: 349000,
      priceMax: 369000,
      engineDisplacement: '373cc',
      description:
          'A capable adventure bike with modern electronics, built for riders who want both daily usability and long-distance touring capability.',
    ),
  ];

  static List<CatalogModel> modelsForBrand(String brand) {
    return models.where((m) => m.brand == brand).toList();
  }
}
