import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:zonix/features/screens/pharmacist/prescription_image_viewer.dart';
import 'package:zonix/features/services/prescription_service.dart';
import 'package:zonix/features/utils/app_colors.dart';
import 'package:zonix/models/prescription.dart';

/// Detalle de una receta para que el farmacéutico colegiado decida.
class ValidationDetailPage extends StatefulWidget {
  final Prescription prescription;

  const ValidationDetailPage({super.key, required this.prescription});

  @override
  State<ValidationDetailPage> createState() => _ValidationDetailPageState();
}

class _ValidationDetailPageState extends State<ValidationDetailPage> {
  bool _busy = false;
  late Prescription _prescription;
  bool _loadingDetail = true;

  @override
  void initState() {
    super.initState();
    _prescription = widget.prescription;
    _refreshPrescription();
  }

  Future<void> _refreshPrescription() async {
    setState(() => _loadingDetail = true);
    final fresh = await context
        .read<PrescriptionService>()
        .loadPharmacistPrescriptionById(widget.prescription.id);
    if (mounted && fresh != null) {
      setState(() => _prescription = fresh);
    }
    if (mounted) setState(() => _loadingDetail = false);
  }

  Future<void> _approve() async {
    setState(() => _busy = true);
    final result = await context
        .read<PrescriptionService>()
        .approve(_prescription.id);
    if (!mounted) return;
    setState(() => _busy = false);
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receta aprobada.')),
      );
      Navigator.of(context).pop(result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(context.read<PrescriptionService>().error ??
                'No se pudo aprobar.')),
      );
    }
  }

  Future<void> _reject() async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Motivo del rechazo'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Indica al paciente por qué se rechaza la receta.',
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Rechazar'),
            ),
          ],
        );
      },
    );
    if (reason == null || reason.isEmpty) return;
    if (!mounted) return;

    setState(() => _busy = true);
    final result = await context
        .read<PrescriptionService>()
        .reject(_prescription.id, reason);
    if (!mounted) return;
    setState(() => _busy = false);
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receta rechazada.')),
      );
      Navigator.of(context).pop(result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(context.read<PrescriptionService>().error ??
                'No se pudo rechazar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _prescription;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Receta #${p.id}')),
      body: SafeArea(
        child: _loadingDetail
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.brandSurfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.brandStrokeLight),
                ),
                child: PrescriptionImageViewer(prescription: p),
              ),
            ),
            const SizedBox(height: 16),
            _row('Tipo', p.prescriptionTypeLabel),
            _row('Estado', p.statusLabel),
            _row('Médico', p.prescribingDoctorName),
            if ((p.prescribingDoctorLicense ?? '').isNotEmpty)
              _row('MPPS', p.prescribingDoctorLicense!),
            if ((p.prescribingDoctorSpecialty ?? '').isNotEmpty)
              _row('Especialidad', p.prescribingDoctorSpecialty!),
            if (p.issuedAt != null)
              _row('Emitida el',
                  p.issuedAt!.toLocal().toIso8601String().substring(0, 10)),
            if (p.orderId != null) _row('Pedido', '#${p.orderId}'),
            if (p.expiresAt != null)
              _row('Expira', p.expiresAt!.toLocal().toString()),
            const SizedBox(height: 24),
            if (p.isPending)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _reject,
                      icon: const Icon(Icons.cancel),
                      label: const Text('Rechazar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _busy ? null : _approve,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Aprobar'),
                    ),
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.brandSurfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.brandStrokeLight),
                ),
                child: Text(
                  'Esta receta ya fue procesada (${p.statusLabel}).',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
