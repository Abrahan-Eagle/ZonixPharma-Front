class CartItem {
  final int id;
  final String nombre;
  final double? precio;
  final int quantity;
  final String? imagen;
  final int? stock;
  final String? category;
  final String? image;

  /// Notas de personalización / instrucciones especiales.
  final String? notes;

  /// ID del comercio (farmacia) — requerido para crear orden.
  final int? commerceId;

  /// Identificador estable de línea remota.
  final String? lineId;

  // ── Pharma: información farmacéutica del item ────────────────────────
  final bool requiresPrescription;
  final String? prescriptionType;
  final bool controlledSubstance;
  final bool coldChain;
  final String? activeIngredient;
  final String? concentration;
  final String? presentation;

  /// Clave lógica de linea (notas/lineId).
  String get lineKey {
    if (lineId != null && lineId!.trim().isNotEmpty) {
      return lineId!.trim();
    }
    final normalizedNotes = (notes ?? '').trim();
    return '$id|$normalizedNotes';
  }

  CartItem({
    required this.id,
    required this.nombre,
    this.precio,
    required this.quantity,
    this.imagen,
    this.stock,
    this.category,
    this.image,
    this.notes,
    this.commerceId,
    this.lineId,
    this.requiresPrescription = false,
    this.prescriptionType,
    this.controlledSubstance = false,
    this.coldChain = false,
    this.activeIngredient,
    this.concentration,
    this.presentation,
  });

  /// Clona el item permitiendo sobreescribir campos puntuales.
  /// Preserva por defecto los flags farmacéuticos para no perderlos
  /// cuando se actualiza la cantidad.
  CartItem copyWith({
    int? id,
    String? nombre,
    double? precio,
    int? quantity,
    String? imagen,
    int? stock,
    String? category,
    String? image,
    String? notes,
    int? commerceId,
    String? lineId,
    bool? requiresPrescription,
    String? prescriptionType,
    bool? controlledSubstance,
    bool? coldChain,
    String? activeIngredient,
    String? concentration,
    String? presentation,
  }) {
    return CartItem(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      precio: precio ?? this.precio,
      quantity: quantity ?? this.quantity,
      imagen: imagen ?? this.imagen,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      image: image ?? this.image,
      notes: notes ?? this.notes,
      commerceId: commerceId ?? this.commerceId,
      lineId: lineId ?? this.lineId,
      requiresPrescription: requiresPrescription ?? this.requiresPrescription,
      prescriptionType: prescriptionType ?? this.prescriptionType,
      controlledSubstance: controlledSubstance ?? this.controlledSubstance,
      coldChain: coldChain ?? this.coldChain,
      activeIngredient: activeIngredient ?? this.activeIngredient,
      concentration: concentration ?? this.concentration,
      presentation: presentation ?? this.presentation,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
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

    return CartItem(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      nombre: json['nombre'] ?? '',
      precio: (json['precio'] is int)
          ? (json['precio'] as int).toDouble()
          : (json['precio'] is String)
              ? double.tryParse(json['precio']) ?? 0.0
              : (json['precio'] is double)
                  ? json['precio']
                  : 0.0,
      quantity: json['quantity'] ?? 1,
      imagen: json['imagen'],
      stock: json['stock'],
      category: json['category'],
      image: json['image'] ?? json['imagen'],
      notes: json['notes'],
      commerceId: json['commerce_id'],
      lineId: json['line_id']?.toString(),
      requiresPrescription: parseBool(json['requires_prescription']),
      prescriptionType: json['prescription_type']?.toString(),
      controlledSubstance: parseBool(json['controlled_substance']),
      coldChain: parseBool(json['cold_chain']),
      activeIngredient: json['active_ingredient']?.toString(),
      concentration: json['concentration']?.toString(),
      presentation: json['presentation']?.toString(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.id == id &&
        other.nombre == nombre &&
        other.precio == precio &&
        other.quantity == quantity &&
        other.imagen == imagen &&
        other.stock == stock &&
        other.category == category &&
        other.image == image &&
        other.notes == notes &&
        other.commerceId == commerceId &&
        other.lineId == lineId &&
        other.requiresPrescription == requiresPrescription &&
        other.prescriptionType == prescriptionType &&
        other.controlledSubstance == controlledSubstance &&
        other.coldChain == coldChain;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      nombre,
      precio,
      quantity,
      imagen,
      stock,
      category,
      image,
      notes,
      commerceId,
      lineId,
      requiresPrescription,
      prescriptionType,
      controlledSubstance,
      coldChain,
    );
  }

  @override
  String toString() {
    return 'CartItem(id: $id, nombre: $nombre, precio: $precio, quantity: $quantity, '
        'commerceId: $commerceId, requiresPrescription: $requiresPrescription)';
  }
}
