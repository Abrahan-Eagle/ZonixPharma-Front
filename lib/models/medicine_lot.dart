/// Lote de medicamento (para vista de inventario en farmacia).
class MedicineLot {
  final int id;
  final int productId;
  final String lotNumber;
  final DateTime expiryDate;
  final DateTime? manufacturedAt;
  final int quantityReceived;
  final int quantityAvailable;
  final DateTime? receivedAt;
  final String? supplier;
  final String? notes;

  MedicineLot({
    required this.id,
    required this.productId,
    required this.lotNumber,
    required this.expiryDate,
    this.manufacturedAt,
    required this.quantityReceived,
    required this.quantityAvailable,
    this.receivedAt,
    this.supplier,
    this.notes,
  });

  factory MedicineLot.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString()).toLocal();
      } catch (_) {
        return null;
      }
    }

    return MedicineLot(
      id: parseInt(json['id']),
      productId: parseInt(json['product_id']),
      lotNumber: (json['lot_number'] ?? '').toString(),
      expiryDate: parseDate(json['expiry_date']) ?? DateTime.now(),
      manufacturedAt: parseDate(json['manufactured_at']),
      quantityReceived: parseInt(json['quantity_received']),
      quantityAvailable: parseInt(json['quantity_available']),
      receivedAt: parseDate(json['received_at']),
      supplier: json['supplier']?.toString(),
      notes: json['notes']?.toString(),
    );
  }

  bool get isExpired => expiryDate.isBefore(DateTime.now());

  bool isExpiringSoon({int days = 60}) {
    final threshold = DateTime.now().add(Duration(days: days));
    return expiryDate.isBefore(threshold);
  }
}
