import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:zonix/features/screens/pharmacist/validation_detail_page.dart';
import 'package:zonix/features/services/prescription_service.dart';
import 'package:zonix/features/utils/app_colors.dart';
import 'package:zonix/models/prescription.dart';

class PendingValidationsPage extends StatefulWidget {
  const PendingValidationsPage({super.key});

  @override
  State<PendingValidationsPage> createState() => _PendingValidationsPageState();
}

class _PendingValidationsPageState extends State<PendingValidationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrescriptionService>().loadPendingForPharmacist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recetas pendientes')),
      body: Consumer<PrescriptionService>(
        builder: (context, service, _) {
          if (service.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (service.pendingForPharmacist.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inbox,
                        size: 48, color: AppColors.brandMutedGray),
                    const SizedBox(height: 12),
                    Text(service.error ??
                        'No hay recetas pendientes de validación.'),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => service.loadPendingForPharmacist(),
                      child: const Text('Refrescar'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => service.loadPendingForPharmacist(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: service.pendingForPharmacist.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final p = service.pendingForPharmacist[index];
                return _prescriptionCard(p);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _prescriptionCard(Prescription p) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.brandTeal,
          child: Icon(Icons.receipt_long, color: Colors.white),
        ),
        title: Text('Receta #${p.id} · ${p.prescriptionTypeLabel}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Médico: ${p.prescribingDoctorName}'),
            if (p.orderId != null) Text('Pedido: #${p.orderId}'),
            if (p.expiresAt != null)
              Text(
                'Expira ${p.expiresAt!.toLocal()}',
                style: const TextStyle(color: AppColors.statusWarning),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ValidationDetailPage(prescription: p),
            ),
          );
        },
      ),
    );
  }
}
