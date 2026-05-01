import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:zonix/features/utils/safe_parse.dart';

/// Modelo de farmacia (alias histórico `Restaurant` mantenido para no
/// romper imports existentes en pantallas y servicios). En código nuevo
/// usar `Pharmacy = Restaurant` o `Commerce` directamente.
typedef Pharmacy = Restaurant;

class Restaurant {
  final int id;
  final int profileId;
  final String businessName;
  final String? address;
  final String? phone;
  final String? description;
  final String? image;
  final String? mobilePaymentBank;
  final String? mobilePaymentId;
  final String? mobilePaymentPhone;
  final bool open;
  final String? businessType;
  final Map<String, dynamic>? schedule;
  final Map<String, dynamic>? profile;
  final double? latitude;
  final double? longitude;

  /// Perfil del farmacéutico colegiado responsable (MPPS), si la API lo envía.
  final int? pharmacistInChargeProfileId;
  final String? healthPermit;
  final String? healthPermitExpiry;
  /// Categoría / tipo de establecimiento (además de [businessType]).
  final String? pharmacyCategory;

  Restaurant({
    required this.id,
    required this.profileId,
    required this.businessName,
    required this.address,
    required this.phone,
    this.description,
    this.image,
    required this.mobilePaymentBank,
    required this.mobilePaymentId,
    required this.mobilePaymentPhone,
    required this.open,
    this.businessType,
    this.schedule,
    this.profile,
    this.latitude,
    this.longitude,
    this.pharmacistInChargeProfileId,
    this.healthPermit,
    this.healthPermitExpiry,
    this.pharmacyCategory,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    // Manejo seguro del campo schedule (que puede venir como String JSON o como Map)
    Map<String, dynamic>? parsedSchedule;
    if (json['schedule'] != null) {
      if (json['schedule'] is String) {
        try {
          parsedSchedule = Map<String, dynamic>.from(
            jsonDecode(json['schedule'] as String)
          );
        } catch (e) {
          debugPrint('Error parsing schedule JSON: $e');
          parsedSchedule = null;
        }
      } else if (json['schedule'] is Map) {
        parsedSchedule = Map<String, dynamic>.from(json['schedule'] as Map);
      }
    }

    // Coordenadas: primero intentar campos directos, luego addresses[0]
    double? lat;
    double? lng;
    if (json['latitude'] != null) {
      lat = double.tryParse(json['latitude'].toString());
    }
    if (json['longitude'] != null) {
      lng = double.tryParse(json['longitude'].toString());
    }
    if ((lat == null || lng == null) && json['addresses'] is List && (json['addresses'] as List).isNotEmpty) {
      final first = (json['addresses'] as List).first;
      if (first is Map) {
        if (first['latitude'] != null) {
          lat = double.tryParse(first['latitude'].toString());
        }
        if (first['longitude'] != null) {
          lng = double.tryParse(first['longitude'].toString());
        }
      }
    }

    return Restaurant(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      profileId: json['profile_id'] is int ? json['profile_id'] : int.tryParse(json['profile_id'].toString()) ?? 0,
      businessName: json['business_name']?.toString() ?? '',
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
      description: json['description']?.toString(),
      image: json['image']?.toString(),
      mobilePaymentBank: json['mobile_payment_bank']?.toString() ?? '',
      mobilePaymentId: json['mobile_payment_id']?.toString() ?? '',
      mobilePaymentPhone: json['mobile_payment_phone']?.toString() ?? '',
      open: json['open'] == 1 || json['open'] == true || json['open'] == '1',
      businessType: json['business_type_relation'] is Map
          ? (json['business_type_relation']['name']?.toString())
          : json['business_type']?.toString(),
      schedule: parsedSchedule,
      profile: json['profile'] is Map ? Map<String, dynamic>.from(json['profile'] as Map) : null,
      latitude: lat,
      longitude: lng,
      pharmacistInChargeProfileId: json['pharmacist_in_charge_profile_id'] != null
          ? int.tryParse(json['pharmacist_in_charge_profile_id'].toString())
          : null,
      healthPermit: json['health_permit']?.toString(),
      healthPermitExpiry: json['health_permit_expiry']?.toString(),
      pharmacyCategory: json['pharmacy_category']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'business_name': businessName,
      'address': address,
      'phone': phone,
      'description': description,
      'image': image,
      'mobile_payment_bank': mobilePaymentBank,
      'mobile_payment_id': mobilePaymentId,
      'mobile_payment_phone': mobilePaymentPhone,
      'open': open,
      'business_type': businessType,
      'schedule': schedule,
      'profile': profile,
      'latitude': latitude,
      'longitude': longitude,
      'pharmacist_in_charge_profile_id': pharmacistInChargeProfileId,
      'health_permit': healthPermit,
      'health_permit_expiry': healthPermitExpiry,
      'pharmacy_category': pharmacyCategory,
    };
  }

  // Getters para compatibilidad con el código existente
  String get nombreLocal => businessName;
  String get direccion => address ?? '';
  String get telefono => phone ?? '';
  String get descripcion => description ?? '';
  String get logoUrl => image ?? '';
  String get pagoMovilBanco => mobilePaymentBank ?? '';
  String get pagoMovilCedula => mobilePaymentId ?? '';
  String get pagoMovilTelefono => mobilePaymentPhone ?? '';
  bool get abierto => open;
  Map<String, dynamic>? get horario => schedule;
  
  // Getters adicionales para compatibilidad
  String get name => businessName;
  bool get isOpen => open;
  @Deprecated('Usar pharmacyCategory o cuisineDisplay')
  String get cuisine =>
      (pharmacyCategory ?? profile?['cuisine']?.toString() ?? '').trim();

  /// Alias semántico Pharma (mismo valor que [cuisineDisplay]).
  String get pharmacyTypeDisplay => cuisineDisplay;

  /// Display del tipo de farmacia/establecimiento. Capitaliza y separa con •.
  String get cuisineDisplay {
    final typeLine =
        (businessType ?? pharmacyCategory ?? profile?['cuisine']?.toString() ?? '')
            .trim();
    final raw = typeLine.isNotEmpty ? typeLine : (description ?? 'Farmacia');
    if (raw.isEmpty) return 'Farmacia';
    final parts = raw.split(RegExp(r'[,;_]')).map((s) {
      final t = s.trim().replaceAll('_', ' ');
      return t.isEmpty ? '' : '${t[0].toUpperCase()}${t.length > 1 ? t.substring(1).toLowerCase() : ''}';
    }).where((s) => s.isNotEmpty).toList();
    return parts.isEmpty ? raw : parts.join(' • ');
  }
  double get rating => safeDouble(profile?['rating']);
  int get reviewCount => safeInt(profile?['review_count']);
  double get distance => 0.0; // Placeholder - calcular desde ubicación
  int get deliveryTime => safeInt(profile?['delivery_time'], 30);
  double get deliveryFee => safeDouble(profile?['delivery_fee']);

  @override
  String toString() {
    return 'Restaurant(id: $id, businessName: $businessName, open: $open)';
  }
}