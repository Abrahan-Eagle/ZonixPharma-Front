/// Receta médica (Rx) que el comprador adjunta a un pedido cuando hay
/// productos `requires_prescription = true`. La validación la realiza un
/// farmacéutico colegiado responsable de la farmacia despachadora.
class Prescription {
  static const String statusPending = 'pending_validation';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';
  static const String statusExpired = 'expired';

  static const String typeCommon = 'common';
  static const String typeRetained = 'retained';
  static const String typeSpecial = 'special';

  final int id;
  final int patientProfileId;
  final int? orderId;
  final int? commerceId;
  final String prescribingDoctorName;
  final String? prescribingDoctorLicense;
  final String? prescribingDoctorSpecialty;
  final DateTime? issuedAt;
  final String imageUrl;
  final String prescriptionType;
  final String status;
  final int? validatedByProfileId;
  final DateTime? validatedAt;
  final String? rejectionReason;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Prescription({
    required this.id,
    required this.patientProfileId,
    this.orderId,
    this.commerceId,
    required this.prescribingDoctorName,
    this.prescribingDoctorLicense,
    this.prescribingDoctorSpecialty,
    this.issuedAt,
    required this.imageUrl,
    required this.prescriptionType,
    required this.status,
    this.validatedByProfileId,
    this.validatedAt,
    this.rejectionReason,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    int? parseIntNullable(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString()).toLocal();
      } catch (_) {
        return null;
      }
    }

    return Prescription(
      id: parseInt(json['id']),
      patientProfileId: parseInt(json['patient_profile_id']),
      orderId: parseIntNullable(json['order_id']),
      commerceId: parseIntNullable(json['commerce_id']),
      prescribingDoctorName: (json['prescribing_doctor_name'] ?? '').toString(),
      prescribingDoctorLicense: json['prescribing_doctor_license']?.toString(),
      prescribingDoctorSpecialty:
          json['prescribing_doctor_specialty']?.toString(),
      issuedAt: parseDate(json['issued_at']),
      imageUrl: (json['image_url'] ?? '').toString(),
      prescriptionType: (json['prescription_type'] ?? typeCommon).toString(),
      status: (json['status'] ?? statusPending).toString(),
      validatedByProfileId: parseIntNullable(json['validated_by_profile_id']),
      validatedAt: parseDate(json['validated_at']),
      rejectionReason: json['rejection_reason']?.toString(),
      expiresAt: parseDate(json['expires_at']),
      createdAt: parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: parseDate(json['updated_at']) ?? DateTime.now(),
    );
  }

  bool get isPending => status == statusPending;
  bool get isApproved => status == statusApproved;
  bool get isRejected => status == statusRejected;
  bool get isExpired =>
      status == statusExpired ||
      (expiresAt != null && expiresAt!.isBefore(DateTime.now()));

  String get statusLabel {
    switch (status) {
      case statusApproved:
        return 'Aprobada';
      case statusRejected:
        return 'Rechazada';
      case statusExpired:
        return 'Expirada';
      case statusPending:
      default:
        return 'En revisión';
    }
  }

  String get prescriptionTypeLabel {
    switch (prescriptionType) {
      case typeRetained:
        return 'Receta retenida';
      case typeSpecial:
        return 'Receta especial';
      case typeCommon:
      default:
        return 'Receta común';
    }
  }
}
