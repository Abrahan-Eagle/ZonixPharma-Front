import '../../helpers/auth_helper.dart';

/// Contexto de farmacia activa (multi-sede) para el panel commerce.
///
/// Persiste el último `commerce.id` conocido y lo envía como `X-Commerce-Id`
/// en las llamadas al API `/api/commerce/*`.
class CommerceContext {
  static const String _activeCommerceIdKey = 'active_commerce_id';

  static Future<void> setActiveCommerceId(int id) async {
    if (id <= 0) return;
    await AuthHelper.storage.write(
      key: _activeCommerceIdKey,
      value: id.toString(),
    );
  }

  static Future<void> clearActiveCommerceId() async {
    await AuthHelper.storage.delete(key: _activeCommerceIdKey);
  }

  static Future<int?> getActiveCommerceId() async {
    final raw = await AuthHelper.storage.read(key: _activeCommerceIdKey);
    if (raw == null || raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  /// Headers Sanctum + `X-Commerce-Id` cuando hay farmacia activa.
  static Future<Map<String, String>> getAuthHeaders() async {
    final headers = await AuthHelper.getAuthHeaders();
    final commerceId = await getActiveCommerceId();
    if (commerceId != null && commerceId > 0) {
      headers['X-Commerce-Id'] = commerceId.toString();
    }
    return headers;
  }
}
