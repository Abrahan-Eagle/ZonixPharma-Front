import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:zonix/features/screens/pharmacist/validation_detail_page.dart';
import 'package:zonix/features/services/prescription_service.dart';
import 'package:zonix/features/utils/app_colors.dart';
import 'package:zonix/models/prescription.dart';

/// Historial de recetas validadas por el farmacéutico (aprobadas, rechazadas, expiradas).
class PrescriptionsHistoryPage extends StatefulWidget {
  const PrescriptionsHistoryPage({super.key});

  @override
  State<PrescriptionsHistoryPage> createState() =>
      _PrescriptionsHistoryPageState();
}

class _PrescriptionsHistoryPageState extends State<PrescriptionsHistoryPage> {
  String? _statusFilter;

  static const _filters = <String?, String>{
    null: 'Todas',
    Prescription.statusApproved: 'Aprobadas',
    Prescription.statusRejected: 'Rechazadas',
    Prescription.statusExpired: 'Expiradas',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await context
        .read<PrescriptionService>()
        .loadHistoryForPharmacist(status: _statusFilter);
  }

  Color _statusColor(String status) {
    switch (status) {
      case Prescription.statusApproved:
        return AppColors.statusSuccess;
      case Prescription.statusRejected:
        return AppColors.statusError;
      case Prescription.statusExpired:
        return AppColors.brandMutedGray;
      default:
        return AppColors.brandTeal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de recetas')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: _filters.entries.map((entry) {
                final selected = _statusFilter == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(entry.value),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _statusFilter = entry.key);
                      _load();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: Consumer<PrescriptionService>(
              builder: (context, service, _) {
                if (service.isLoading && service.historyForPharmacist.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (service.error != null &&
                    service.historyForPharmacist.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(service.error!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: _load,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (service.historyForPharmacist.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _statusFilter == null
                            ? 'Aún no hay recetas procesadas en tus farmacias.'
                            : 'No hay recetas con este filtro.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: service.historyForPharmacist.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final p = service.historyForPharmacist[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _statusColor(p.status),
                            child: const Icon(Icons.receipt_long,
                                color: AppColors.white),
                          ),
                          title: Text(
                              'Receta #${p.id} · ${p.prescriptionTypeLabel}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Médico: ${p.prescribingDoctorName}'),
                              if (p.orderId != null)
                                Text('Pedido: #${p.orderId}'),
                              Text('Estado: ${p.statusLabel}'),
                              if (p.validatedAt != null)
                                Text(
                                  'Procesada: ${p.validatedAt!.toLocal()}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              if (p.rejectionReason != null &&
                                  p.rejectionReason!.isNotEmpty)
                                Text(
                                  'Motivo: ${p.rejectionReason}',
                                  style: const TextStyle(
                                      color: AppColors.statusError),
                                ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ValidationDetailPage(prescription: p),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
