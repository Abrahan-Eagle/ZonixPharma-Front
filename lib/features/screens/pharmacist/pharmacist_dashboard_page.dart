import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:zonix/features/screens/pharmacist/pending_validations_page.dart';
import 'package:zonix/features/screens/pharmacist/pharmacist_onboarding_page.dart';
import 'package:zonix/features/services/prescription_service.dart';
import 'package:zonix/features/utils/app_colors.dart';

/// Dashboard del farmacéutico colegiado responsable.
class PharmacistDashboardPage extends StatefulWidget {
  const PharmacistDashboardPage({super.key});

  @override
  State<PharmacistDashboardPage> createState() =>
      _PharmacistDashboardPageState();
}

class _PharmacistDashboardPageState extends State<PharmacistDashboardPage> {
  bool _onboardingPrompted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load({bool forceRefresh = false}) async {
    final svc = context.read<PrescriptionService>();
    await svc.loadPharmacistDashboard(forceRefresh: forceRefresh);
    if (!mounted) return;
    final data = svc.pharmacistDashboard;
    if (svc.dashboardError == null &&
        data != null &&
        data['pharmacist'] == null &&
        !_onboardingPrompted) {
      _onboardingPrompted = true;
      final done = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const PharmacistOnboardingPage(),
        ),
      );
      if (mounted && done == true) {
        await _load(forceRefresh: true);
      }
    }
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(value,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrescriptionService>(
      builder: (context, svc, _) {
        final loading = svc.isDashboardLoading && svc.pharmacistDashboard == null;
        final error = svc.dashboardError;
        final data = svc.pharmacistDashboard;
        final stats = (data?['stats'] as Map?) ?? {};
        final licenseValid = data?['license_valid'] == true;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Panel del farmacéutico'),
            actions: [
              IconButton(
                tooltip: 'Refrescar',
                onPressed: loading ? null : () => _load(forceRefresh: true),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(error),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () => _load(forceRefresh: true),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _load(forceRefresh: true),
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (!licenseValid)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.statusError
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded,
                                      color: AppColors.statusError),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Tu licencia colegiada no está verificada o ha vencido. No podrás validar recetas hasta regularizarla.',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _statCard(
                                  'Pendientes',
                                  '${stats['pending'] ?? 0}',
                                  Icons.pending_actions,
                                  AppColors.brandTeal),
                              const SizedBox(width: 8),
                              _statCard(
                                  'Recibidas hoy',
                                  '${stats['today_total'] ?? 0}',
                                  Icons.assignment,
                                  AppColors.brandNavy),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _statCard(
                                  'Aprobadas hoy',
                                  '${stats['today_approved'] ?? 0}',
                                  Icons.check_circle,
                                  AppColors.statusSuccess),
                              const SizedBox(width: 8),
                              const Spacer(),
                            ],
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const PendingValidationsPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.fact_check),
                            label: const Text('Ver recetas pendientes'),
                          ),
                        ],
                      ),
                    ),
        );
      },
    );
  }
}
