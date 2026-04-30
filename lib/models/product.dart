/// Modelo de producto / medicamento (Zonix Pharma).
///
/// Conceptualmente es un Medicine. Mantiene el nombre [Product] por
/// compatibilidad con servicios y pantallas existentes.
class Product {
  final int id;
  final int commerceId;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String image;
  final String category;
  final bool isAvailable;
  final bool hasStockLimit;
  final int stock;
  final List<String> tags;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Datos farmacéuticos
  final String? activeIngredient;
  final String? dosageForm;
  final String? concentration;
  final String? presentation;
  final String? manufacturer;
  final String? healthRegistry;
  final String? barcode;
  final String? atcCode;
  final bool requiresPrescription;
  final String? prescriptionType; // common | retained | special
  final bool controlledSubstance;
  final bool coldChain;

  Product({
    required this.id,
    required this.commerceId,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.image,
    required this.category,
    required this.isAvailable,
    this.hasStockLimit = false,
    required this.stock,
    required this.tags,
    required this.rating,
    required this.reviewCount,
    required this.createdAt,
    required this.updatedAt,
    this.activeIngredient,
    this.dosageForm,
    this.concentration,
    this.presentation,
    this.manufacturer,
    this.healthRegistry,
    this.barcode,
    this.atcCode,
    this.requiresPrescription = false,
    this.prescriptionType,
    this.controlledSubstance = false,
    this.coldChain = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final v = value.toLowerCase();
        return v == 'true' || v == '1';
      }
      return false;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    int parseCommerceId(Map<String, dynamic> payload) {
      final direct = payload['commerce_id'];
      if (direct is int) return direct;
      if (direct is String) return int.tryParse(direct) ?? 0;
      final nested = payload['commerce'];
      if (nested is Map) {
        final nestedId = nested['id'];
        if (nestedId is int) return nestedId;
        if (nestedId is String) return int.tryParse(nestedId) ?? 0;
      }
      return 0;
    }

    return Product(
      id: parseInt(json['id']),
      commerceId: parseCommerceId(json),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: parseDouble(json['price']),
      originalPrice:
          json['original_price'] != null ? parseDouble(json['original_price']) : null,
      image: (json['image'] ?? json['image_url'] ?? '').toString(),
      category: (json['category_name'] ??
              (json['category'] is Map
                  ? (json['category']['name'] ?? '')
                  : (json['category']?.toString() ?? '')))
          .toString(),
      isAvailable: parseBool(json['available'] ?? json['is_available']),
      hasStockLimit: json['stock_quantity'] != null || json['stock'] != null,
      stock: parseInt(json['stock_quantity'] ?? json['stock'] ?? 0),
      tags: (json['tags'] is List)
          ? List<String>.from((json['tags'] as List).map((t) => t.toString()))
          : <String>[],
      rating: parseDouble(json['rating']),
      reviewCount: parseInt(json['review_count']),
      createdAt: DateTime.parse(
          (json['created_at'] ?? DateTime.now().toIso8601String()).toString()),
      updatedAt: DateTime.parse(
          (json['updated_at'] ?? DateTime.now().toIso8601String()).toString()),
      activeIngredient: json['active_ingredient']?.toString(),
      dosageForm: json['dosage_form']?.toString(),
      concentration: json['concentration']?.toString(),
      presentation: json['presentation']?.toString(),
      manufacturer: json['manufacturer']?.toString(),
      healthRegistry: json['health_registry']?.toString(),
      barcode: json['barcode']?.toString(),
      atcCode: json['atc_code']?.toString(),
      requiresPrescription: parseBool(json['requires_prescription']),
      prescriptionType: json['prescription_type']?.toString(),
      controlledSubstance: parseBool(json['controlled_substance']),
      coldChain: parseBool(json['cold_chain']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'commerce_id': commerceId,
      'name': name,
      'description': description,
      'price': price,
      'original_price': originalPrice,
      'image': image,
      'category': category,
      'is_available': isAvailable,
      'has_stock_limit': hasStockLimit,
      'stock': stock,
      'tags': tags,
      'rating': rating,
      'review_count': reviewCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'active_ingredient': activeIngredient,
      'dosage_form': dosageForm,
      'concentration': concentration,
      'presentation': presentation,
      'manufacturer': manufacturer,
      'health_registry': healthRegistry,
      'barcode': barcode,
      'atc_code': atcCode,
      'requires_prescription': requiresPrescription,
      'prescription_type': prescriptionType,
      'controlled_substance': controlledSubstance,
      'cold_chain': coldChain,
    };
  }

  Product copyWith({
    int? id,
    int? commerceId,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    String? image,
    String? category,
    bool? isAvailable,
    bool? hasStockLimit,
    int? stock,
    List<String>? tags,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? activeIngredient,
    String? dosageForm,
    String? concentration,
    String? presentation,
    String? manufacturer,
    String? healthRegistry,
    String? barcode,
    String? atcCode,
    bool? requiresPrescription,
    String? prescriptionType,
    bool? controlledSubstance,
    bool? coldChain,
  }) {
    return Product(
      id: id ?? this.id,
      commerceId: commerceId ?? this.commerceId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      image: image ?? this.image,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      hasStockLimit: hasStockLimit ?? this.hasStockLimit,
      stock: stock ?? this.stock,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      activeIngredient: activeIngredient ?? this.activeIngredient,
      dosageForm: dosageForm ?? this.dosageForm,
      concentration: concentration ?? this.concentration,
      presentation: presentation ?? this.presentation,
      manufacturer: manufacturer ?? this.manufacturer,
      healthRegistry: healthRegistry ?? this.healthRegistry,
      barcode: barcode ?? this.barcode,
      atcCode: atcCode ?? this.atcCode,
      requiresPrescription: requiresPrescription ?? this.requiresPrescription,
      prescriptionType: prescriptionType ?? this.prescriptionType,
      controlledSubstance: controlledSubstance ?? this.controlledSubstance,
      coldChain: coldChain ?? this.coldChain,
    );
  }

  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  double get discountPercentage =>
      hasDiscount ? ((originalPrice! - price) / originalPrice! * 100) : 0;

  /// Para UI: combina concentración + presentación en un display amigable.
  String get pharmaSummary {
    final parts = <String>[
      if ((activeIngredient ?? '').isNotEmpty) activeIngredient!,
      if ((concentration ?? '').isNotEmpty) concentration!,
      if ((presentation ?? '').isNotEmpty) presentation!,
    ];
    return parts.join(' · ');
  }
}
