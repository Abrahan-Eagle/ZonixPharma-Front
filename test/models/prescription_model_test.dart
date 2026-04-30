import 'package:flutter_test/flutter_test.dart';
import 'package:zonix/models/prescription.dart';

void main() {
  group('Prescription model', () {
    test('parses base JSON', () {
      final prescription = Prescription.fromJson({
        'id': 10,
        'patient_profile_id': 1,
        'order_id': 99,
        'commerce_id': 5,
        'prescribing_doctor_name': 'Dr. Méndez',
        'prescribing_doctor_license': 'MPPS-12345',
        'prescribing_doctor_specialty': 'Cardiología',
        'issued_at': '2026-04-01',
        'image_url': 'https://cdn/example.png',
        'prescription_type': 'common',
        'status': 'pending_validation',
        'expires_at': '2026-04-30T23:59:00Z',
        'created_at': '2026-04-30T10:00:00Z',
        'updated_at': '2026-04-30T10:00:00Z',
      });

      expect(prescription.id, 10);
      expect(prescription.orderId, 99);
      expect(prescription.commerceId, 5);
      expect(prescription.prescribingDoctorName, 'Dr. Méndez');
      expect(prescription.prescriptionType, 'common');
      expect(prescription.isPending, true);
      expect(prescription.statusLabel, 'En revisión');
      expect(prescription.prescriptionTypeLabel, 'Receta común');
    });

    test('approved status helpers', () {
      final prescription = Prescription.fromJson({
        'id': 11,
        'patient_profile_id': 1,
        'prescribing_doctor_name': 'Dra. Rivas',
        'image_url': 'rx.png',
        'prescription_type': 'retained',
        'status': 'approved',
      });
      expect(prescription.isApproved, true);
      expect(prescription.isPending, false);
      expect(prescription.statusLabel, 'Aprobada');
      expect(prescription.prescriptionTypeLabel, 'Receta retenida');
    });

    test('rejected status helpers', () {
      final prescription = Prescription.fromJson({
        'id': 12,
        'patient_profile_id': 1,
        'prescribing_doctor_name': 'Dr. Test',
        'image_url': 'rx.png',
        'prescription_type': 'special',
        'status': 'rejected',
        'rejection_reason': 'Receta vencida',
      });
      expect(prescription.isRejected, true);
      expect(prescription.statusLabel, 'Rechazada');
      expect(prescription.prescriptionTypeLabel, 'Receta especial');
      expect(prescription.rejectionReason, 'Receta vencida');
    });
  });
}
