/// Etiqueta legible para plazo TTL de subida/validación de receta Rx.
String formatRxCountdownLabel(DateTime until, DateTime now) {
  final diff = until.difference(now);
  if (diff.isNegative || diff.inSeconds <= 0) return 'Plazo vencido';
  if (diff.inMinutes < 1) return 'Queda menos de 1 min';
  if (diff.inMinutes < 60) return 'Quedan ${diff.inMinutes} min';
  final h = diff.inHours;
  final m = diff.inMinutes % 60;
  return m > 0 ? 'Quedan ${h}h ${m}min' : 'Quedan ${h}h';
}
