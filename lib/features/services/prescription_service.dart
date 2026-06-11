import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:zonix/config/app_config.dart';
import 'package:zonix/features/utils/pharmacist_api_errors.dart';
import 'package:zonix/helpers/auth_helper.dart';
import 'package:zonix/models/prescription.dart';

/// Servicio buyer y pharmacist para recetas médicas (Rx).
///
/// Endpoints base:
///   buyer:
///     GET    /api/buyer/prescriptions
///     POST   /api/buyer/prescriptions
///     GET    /api/buyer/prescriptions/{id}
///     DELETE /api/buyer/prescriptions/{id}
///   pharmacist:
///     GET   /api/pharmacist/prescriptions/pending
///     GET   /api/pharmacist/prescriptions/{id}
///     POST  /api/pharmacist/prescriptions/{id}/approve
///     POST  /api/pharmacist/prescriptions/{id}/reject
class PrescriptionService extends ChangeNotifier {
  List<Prescription> _myPrescriptions = const [];
  List<Prescription> _pendingForPharmacist = const [];
  List<Prescription> _historyForPharmacist = const [];
  Map<String, dynamic>? _pharmacistDashboard;
  bool _dashboardLoading = false;
  String? _dashboardError;
  bool _isLoading = false;
  String? _error;

  List<Prescription> get myPrescriptions => _myPrescriptions;
  List<Prescription> get pendingForPharmacist => _pendingForPharmacist;
  List<Prescription> get historyForPharmacist => _historyForPharmacist;
  Map<String, dynamic>? get pharmacistDashboard => _pharmacistDashboard;
  bool get isDashboardLoading => _dashboardLoading;
  String? get dashboardError => _dashboardError;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// IDs de farmacias donde el farmacéutico es responsable (desde dashboard).
  List<int> get pharmacistCommerceIds {
    final raw = _pharmacistDashboard?['commerces'];
    if (raw is! List) return const [];
    return raw
        .map((v) => int.tryParse(v.toString()))
        .whereType<int>()
        .where((id) => id > 0)
        .toList(growable: false);
  }

  // ── Buyer ────────────────────────────────────────────────────────────

  /// GET /api/buyer/prescriptions/{id}
  Future<Prescription?> loadBuyerPrescriptionById(int id) async {
    try {
      final headers = await AuthHelper.getAuthHeaders();
      final url =
          Uri.parse('${AppConfig.apiUrl}/api/buyer/prescriptions/$id');
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map &&
            body['success'] == true &&
            body['data'] is Map) {
          return Prescription.fromJson(
              Map<String, dynamic>.from(body['data'] as Map));
        }
        _error = pharmacistHttpErrorMessage('Receta', response);
        notifyListeners();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> loadMyPrescriptions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final headers = await AuthHelper.getAuthHeaders();
      final url = Uri.parse('${AppConfig.apiUrl}/api/buyer/prescriptions');
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map && body['success'] == true && body['data'] is List) {
          final list = List<Map<String, dynamic>>.from(body['data'] as List);
          _myPrescriptions = list.map(Prescription.fromJson).toList();
        } else {
          _error = pharmacistHttpErrorMessage(
              'No se pudieron cargar las recetas', response);
        }
      } else {
        _error = pharmacistHttpErrorMessage(
            'No se pudieron cargar las recetas', response);
      }
    } catch (e) {
      _error = 'Error al cargar recetas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Prescription?> uploadPrescription({
    required int orderId,
    required String prescribingDoctorName,
    String? prescribingDoctorLicense,
    String? prescribingDoctorSpecialty,
    DateTime? issuedAt,
    String prescriptionType = Prescription.typeCommon,
    required String filePath,
    String? fileName,
    String? fileMime,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final token = await AuthHelper.getToken();
      final url = Uri.parse('${AppConfig.apiUrl}/api/buyer/prescriptions');
      final request = http.MultipartRequest('POST', url);
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';
      request.fields['order_id'] = '$orderId';
      request.fields['prescribing_doctor_name'] = prescribingDoctorName;
      if (prescribingDoctorLicense != null && prescribingDoctorLicense.isNotEmpty) {
        request.fields['prescribing_doctor_license'] = prescribingDoctorLicense;
      }
      if (prescribingDoctorSpecialty != null && prescribingDoctorSpecialty.isNotEmpty) {
        request.fields['prescribing_doctor_specialty'] = prescribingDoctorSpecialty;
      }
      if (issuedAt != null) {
        request.fields['issued_at'] = issuedAt.toIso8601String().substring(0, 10);
      }
      request.fields['prescription_type'] = prescriptionType;

      final mime = fileMime ?? 'image/jpeg';
      final mediaType = MediaType.parse(mime);
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        filePath,
        filename: fileName,
        contentType: mediaType,
      ));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body);
        if (body is Map &&
            body['success'] == true &&
            body['data'] is Map) {
          final prescription = Prescription.fromJson(
              Map<String, dynamic>.from(body['data'] as Map));
          _myPrescriptions = [prescription, ..._myPrescriptions];
          return prescription;
        }
      }
      _error =
          pharmacistHttpErrorMessage('No se pudo enviar la receta', response);
      return null;
    } catch (e) {
      _error = 'Error al enviar la receta: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePrescription(int prescriptionId) async {
    try {
      final headers = await AuthHelper.getAuthHeaders();
      final url = Uri.parse(
          '${AppConfig.apiUrl}/api/buyer/prescriptions/$prescriptionId');
      final response = await http.delete(url, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body);
        if (body is Map && body['success'] == true) {
          _myPrescriptions =
              _myPrescriptions.where((p) => p.id != prescriptionId).toList();
          notifyListeners();
          return true;
        }
      }
      _error = pharmacistHttpErrorMessage(
          'No se pudo eliminar la receta', response);
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error al eliminar la receta: $e';
      notifyListeners();
      return false;
    }
  }

  // ── Pharmacist ───────────────────────────────────────────────────────

  /// GET /api/pharmacist/dashboard — cache en memoria para panel y Pusher.
  Future<Map<String, dynamic>?> loadPharmacistDashboard({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _pharmacistDashboard != null && !_dashboardLoading) {
      return _pharmacistDashboard;
    }
    _dashboardLoading = true;
    _dashboardError = null;
    notifyListeners();
    try {
      final headers = await AuthHelper.getAuthHeaders();
      final url = Uri.parse('${AppConfig.apiUrl}/api/pharmacist/dashboard');
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map &&
            body['success'] == true &&
            body['data'] is Map) {
          _pharmacistDashboard =
              Map<String, dynamic>.from(body['data'] as Map);
          return _pharmacistDashboard;
        }
        _dashboardError =
            pharmacistHttpErrorMessage('Dashboard', response);
      } else {
        _dashboardError =
            pharmacistHttpErrorMessage('Dashboard', response);
      }
    } catch (e) {
      _dashboardError = 'Error al cargar el panel: $e';
    } finally {
      _dashboardLoading = false;
      notifyListeners();
    }
    return null;
  }

  /// GET /api/pharmacist/prescriptions/{id}
  Future<Prescription?> loadPharmacistPrescriptionById(int id) async {
    try {
      final headers = await AuthHelper.getAuthHeaders();
      final url =
          Uri.parse('${AppConfig.apiUrl}/api/pharmacist/prescriptions/$id');
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map && body['success'] == true && body['data'] is Map) {
          return Prescription.fromJson(
              Map<String, dynamic>.from(body['data'] as Map));
        }
      }
      _error = pharmacistHttpErrorMessage('Receta', response);
      notifyListeners();
      return null;
    } catch (e) {
      _error = 'Error al cargar la receta: $e';
      notifyListeners();
      return null;
    }
  }

  Future<void> loadPendingForPharmacist() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final headers = await AuthHelper.getAuthHeaders();
      final url =
          Uri.parse('${AppConfig.apiUrl}/api/pharmacist/prescriptions/pending');
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map && body['success'] == true && body['data'] is List) {
          final list =
              List<Map<String, dynamic>>.from(body['data'] as List);
          _pendingForPharmacist = list.map(Prescription.fromJson).toList();
        } else {
          _error = pharmacistHttpErrorMessage(
              'No se pudieron cargar las recetas pendientes', response);
        }
      } else {
        _error = pharmacistHttpErrorMessage(
            'No se pudieron cargar las recetas pendientes', response);
      }
    } catch (e) {
      _error = 'Error al cargar pendientes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// GET /api/pharmacist/prescriptions/history?status=approved|rejected|expired
  Future<void> loadHistoryForPharmacist({String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final headers = await AuthHelper.getAuthHeaders();
      final query = <String, String>{};
      if (status != null && status.isNotEmpty) {
        query['status'] = status;
      }
      final url = Uri.parse(
        '${AppConfig.apiUrl}/api/pharmacist/prescriptions/history',
      ).replace(queryParameters: query.isEmpty ? null : query);
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map && body['success'] == true && body['data'] is List) {
          final list = List<Map<String, dynamic>>.from(body['data'] as List);
          _historyForPharmacist = list.map(Prescription.fromJson).toList();
        } else {
          _error = pharmacistHttpErrorMessage(
              'No se pudo cargar el historial', response);
        }
      } else {
        _error = pharmacistHttpErrorMessage(
            'No se pudo cargar el historial', response);
      }
    } catch (e) {
      _error = 'Error al cargar historial: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Prescription?> approve(int prescriptionId) async {
    return _decide(prescriptionId, approve: true);
  }

  Future<Prescription?> reject(int prescriptionId, String reason) async {
    return _decide(prescriptionId, approve: false, reason: reason);
  }

  Future<Prescription?> _decide(
    int prescriptionId, {
    required bool approve,
    String? reason,
  }) async {
    try {
      final headers = await AuthHelper.getAuthHeaders();
      final action = approve ? 'approve' : 'reject';
      final url = Uri.parse(
          '${AppConfig.apiUrl}/api/pharmacist/prescriptions/$prescriptionId/$action');
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(approve ? {} : {'reason': reason ?? ''}),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body);
        if (body is Map && body['success'] == true && body['data'] is Map) {
          final updated = Prescription.fromJson(
              Map<String, dynamic>.from(body['data'] as Map));
          _pendingForPharmacist = _pendingForPharmacist
              .where((p) => p.id != prescriptionId)
              .toList();
          notifyListeners();
          return updated;
        }
      }
      _error = pharmacistHttpErrorMessage(
          approve ? 'No se pudo aprobar la receta' : 'No se pudo rechazar la receta',
          response);
      notifyListeners();
      return null;
    } catch (e) {
      _error = 'Error: $e';
      notifyListeners();
      return null;
    }
  }

}
