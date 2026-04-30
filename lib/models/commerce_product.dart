/// Producto de farmacia visto desde el panel commerce.
/// Espejo de [Product] (modelo buyer) con los mismos campos farmacéuticos
/// para que la farmacia pueda crear/editar medicamentos completos.
class CommerceProduct {
  final int id;
  final int commerceId;
  final String name;
  final String description;
  final double price;
  final String? image;
  final bool available;
  final int? stock;
  final String? category;
  final int? categoryId;
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
  final String? prescriptionType;
  final bool controlledSubstance;
  final bool coldChain;

  CommerceProduct({
    required this.id,
    required this.commerceId,
    required this.name,
    required this.description,
    required this.price,
    this.image,
    required this.available,
    this.stock,
    this.category,
    this.categoryId,
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

  factory CommerceProduct.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) {
        final s = v.toLowerCase();
        return s == 'true' || s == '1';
      }
      return false;
    }

    return CommerceProduct(
      id: json['id'] ?? 0,
      commerceId: json['commerce_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] is String)
          ? double.tryParse(json['price']) ?? 0.0
          : (json['price'] ?? 0.0).toDouble(),
      image: json['image'],
      available: parseBool(json['available']),
      stock: json['stock'] != null
          ? int.tryParse(json['stock'].toString())
          : (json['stock_quantity'] != null
              ? int.tryParse(json['stock_quantity'].toString())
              : null),
      category: json['category']?.toString(),
      categoryId: json['category_id'],
      createdAt:
          DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
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
      'image': image,
      'available': available,
      'stock': stock,
      'category': category,
      'category_id': categoryId,
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

  CommerceProduct copyWith({
    int? id,
    int? commerceId,
    String? name,
    String? description,
    double? price,
    String? image,
    bool? available,
    int? stock,
    String? category,
    int? categoryId,
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
    return CommerceProduct(
      id: id ?? this.id,
      commerceId: commerceId ?? this.commerceId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      available: available ?? this.available,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
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
      requiresPrescription:
          requiresPrescription ?? this.requiresPrescription,
      prescriptionType: prescriptionType ?? this.prescriptionType,
      controlledSubstance:
          controlledSubstance ?? this.controlledSubstance,
      coldChain: coldChain ?? this.coldChain,
    );
  }

  @override
  String toString() {
    return 'CommerceProduct(id: $id, name: $name, price: $price, '
        'requiresPrescription: $requiresPrescription)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommerceProduct && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
