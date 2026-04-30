/// Parser de payloads QR para abrir el catálogo buyer de una farmacia.
/// No mezclar con QR de pedidos (`zonix://pickup/`, `zonix://delivery/`).
class StorefrontQrKind {
  const StorefrontQrKind._(this.name);
  final String name;

  static const invalid = StorefrontQrKind._('invalid');
  static const commerce = StorefrontQrKind._('commerce');
  static const orderPickupOrDelivery = StorefrontQrKind._('orderPickupOrDelivery');
}

class StorefrontQrParsed {
  const StorefrontQrParsed(this.kind, this.commerceId);

  final StorefrontQrKind kind;
  final int? commerceId;

  factory StorefrontQrParsed.invalid() =>
      const StorefrontQrParsed(StorefrontQrKind.invalid, null);

  factory StorefrontQrParsed.commerce(int id) =>
      StorefrontQrParsed(StorefrontQrKind.commerce, id);

  factory StorefrontQrParsed.orderQr() =>
      const StorefrontQrParsed(StorefrontQrKind.orderPickupOrDelivery, null);
}

class StorefrontQrParser {
  /// Deep link canónico Zonix Pharma para una farmacia: `zonix://pharmacy/{id}`.
  static const String kDeepLinkPrefix = 'zonix://pharmacy/';

  /// Deep link legacy de Zonix Eats. Se mantiene como compatibilidad de lectura
  /// para QR antiguos generados antes de la migración a Pharma; no se emite ya.
  static const String kLegacyDeepLinkPrefix = 'zonix://restaurant/';

  /// Interpreta texto crudo del QR (deep link o URL HTTPS con `/r/{id}`).
  static StorefrontQrParsed parse(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return StorefrontQrParsed.invalid();

    final lower = t.toLowerCase();
    if (lower.startsWith('zonix://pickup/') ||
        lower.startsWith('zonix://delivery/')) {
      return StorefrontQrParsed.orderQr();
    }

    final uri = Uri.tryParse(t);
    if (uri != null && uri.scheme == 'zonix') {
      const validHosts = {'pharmacy', 'restaurant'};
      if (validHosts.contains(uri.host) && uri.pathSegments.isNotEmpty) {
        final id = int.tryParse(uri.pathSegments.first.split('?').first);
        if (id != null && id > 0) {
          return StorefrontQrParsed.commerce(id);
        }
      }
    }

    if (lower.startsWith(kDeepLinkPrefix)) {
      final rest = t.substring(kDeepLinkPrefix.length);
      final id = int.tryParse(rest.split('/').first.split('?').first);
      if (id != null && id > 0) {
        return StorefrontQrParsed.commerce(id);
      }
    }
    if (lower.startsWith(kLegacyDeepLinkPrefix)) {
      final rest = t.substring(kLegacyDeepLinkPrefix.length);
      final id = int.tryParse(rest.split('/').first.split('?').first);
      if (id != null && id > 0) {
        return StorefrontQrParsed.commerce(id);
      }
    }

    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      final segs = uri.pathSegments;
      for (var i = 0; i < segs.length - 1; i++) {
        if (segs[i].toLowerCase() == 'r') {
          final id = int.tryParse(segs[i + 1]);
          if (id != null && id > 0) {
            return StorefrontQrParsed.commerce(id);
          }
        }
      }
      if (segs.length >= 2 && segs[0].toLowerCase() == 'r') {
        final id = int.tryParse(segs[1]);
        if (id != null && id > 0) {
          return StorefrontQrParsed.commerce(id);
        }
      }
    }

    return StorefrontQrParsed.invalid();
  }
}
