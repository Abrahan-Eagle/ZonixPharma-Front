/// Mapeo centralizado de estados de pedido → pasos de tracking (buyer UI).
class OrderTrackingController {
  OrderTrackingController._();

  /// Paso actual en timeline de 4 etapas (0 = recibido / pre-pago o Rx).
  static const Map<String, int> stepMap = {
    'pending_prescription_validation': 0,
    'pending_payment': 0,
    'pending': 0,
    'paid': 0,
    'processing': 1,
    'shipped': 2,
    'delivered': 3,
    'cancelled': 0,
  };

  /// Fracción de progreso lineal (0–1) para barras en lista de pedidos.
  static const Map<String, double> progressMap = {
    'pending_prescription_validation': 0.10,
    'pending_payment': 0.20,
    'pending': 0.20,
    'paid': 0.40,
    'processing': 0.55,
    'shipped': 0.80,
    'delivered': 1.0,
    'cancelled': 0.0,
  };

  static int progressStep(String status) =>
      stepMap[status.trim().toLowerCase()] ?? 0;

  static double progressFraction(String status) =>
      progressMap[status.trim().toLowerCase()] ?? 0.0;

  static bool isTrackable(String status) {
    final s = status.trim().toLowerCase();
    return s == 'pending_prescription_validation' ||
        s == 'pending_payment' ||
        s == 'pending' ||
        s == 'paid' ||
        s == 'processing' ||
        s == 'shipped';
  }

  static bool isCancellable(String status) {
    final s = status.trim().toLowerCase();
    return s == 'pending_payment' || s == 'pending_prescription_validation';
  }
}
