import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:zonix/features/screens/orders/order_detail_page.dart';
import 'package:zonix/features/services/prescription_service.dart';
import 'package:zonix/features/utils/app_colors.dart';
import 'package:zonix/models/prescription.dart';

/// Lista de recetas del comprador.
class MyPrescriptionsPage extends StatefulWidget {
  const MyPrescriptionsPage({super.key});

  @override
  State<MyPrescriptionsPage> createState() => _MyPrescriptionsPageState();
}

class _MyPrescriptionsPageState extends State<MyPrescriptionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrescriptionService>().loadMyPrescriptions();
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case Prescription.statusApproved:
        return AppColors.statusSuccess;
      case Prescription.statusRejected:
        return AppColors.statusError;
      case Prescription.statusExpired:
        return AppColors.brandMutedGray;
      case Prescription.statusPending:
      default:
        return AppColors.brandTeal;
    }
  }

  Future<void> _confirmDelete(Prescription p, PrescriptionService service) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar receta'),
        content: Text(
          '¿Eliminar la receta #${p.id}? Solo puedes hacerlo mientras está pendiente de validación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final deleted = await service.deletePrescription(p.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted
              ? 'Receta eliminada.'
              : (service.error ?? 'No se pudo eliminar la receta.'),
        ),
      ),
    );
  }

  void _openOrder(Prescription p) {
    final orderId = p.orderId;
    if (orderId == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderDetailPage(orderId: orderId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis recetas médicas')),
      body: Consumer<PrescriptionService>(
        builder: (context, service, _) {
          if (service.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (service.error != null && service.myPrescriptions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.statusError),
                    const SizedBox(height: 8),
                    Text(service.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => service.loadMyPrescriptions(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (service.myPrescriptions.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aún no has subido recetas médicas. Cuando un pedido contenga medicamentos Rx, podrás adjuntar la receta desde el detalle del pedido.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => service.loadMyPrescriptions(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: service.myPrescriptions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final p = service.myPrescriptions[index];
                return Card(
                  child: ListTile(
                    onTap: p.orderId != null ? () => _openOrder(p) : null,
                    leading: CircleAvatar(
                      backgroundColor: _statusColor(p.status),
                      child: const Icon(Icons.receipt_long,
                          color: AppColors.white),
                    ),
                    title: Text('Receta #${p.id} · ${p.prescriptionTypeLabel}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Médico: ${p.prescribingDoctorName}'),
                        if (p.orderId != null)
                          Text('Pedido: #${p.orderId} · Toca para ver detalle'),
                        Text('Estado: ${p.statusLabel}'),
                        if (p.rejectionReason != null &&
                            p.rejectionReason!.isNotEmpty)
                          Text('Motivo: ${p.rejectionReason}',
                              style: const TextStyle(
                                  color: AppColors.statusError)),
                      ],
                    ),
                    trailing: p.status == Prescription.statusPending
                        ? IconButton(
                            tooltip: 'Eliminar receta pendiente',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _confirmDelete(p, service),
                          )
                        : (p.orderId != null
                            ? const Icon(Icons.chevron_right)
                            : null),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
