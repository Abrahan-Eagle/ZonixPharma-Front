/// Helpers para persistencia del índice de la bottom nav por rol.
/// Usado por [MainRouter] en main.dart.
///
/// Niveles:
///   0 = users (Buyer / paciente)
///   1 = commerce (Farmacia / Droguería)
///   2 = delivery / delivery_agent
///   3 = delivery_company
///   4 = admin
///   5 = pharmacist (farmacéutico colegiado responsable, Zonix Pharma)
library bottom_nav_persistence;

/// Clave de SharedPreferences para guardar el índice de la bottom nav de un rol.
/// Rol vacío se normaliza a 'users'.
String bottomNavStorageKey(String role) {
  final keyRole = role.isEmpty ? 'users' : role;
  return 'bottomNavIndex_$keyRole';
}

/// Nivel por defecto para el selector de rol en la app bar.
int defaultLevelForRole(String role) {
  switch (role) {
    case 'commerce':
      return 1;
    case 'delivery_agent':
    case 'delivery':
      return 2;
    case 'delivery_company':
      return 3;
    case 'admin':
      return 4;
    case 'pharmacist':
      return 5;
    case 'users':
    default:
      return 0;
  }
}

/// Niveles permitidos para el selector según rol (cada rol solo ve su nivel).
List<int> levelsForRole(String role) {
  switch (role) {
    case 'commerce':
      return [1];
    case 'delivery_agent':
    case 'delivery':
      return [2];
    case 'delivery_company':
      return [3];
    case 'admin':
      return [4];
    case 'pharmacist':
      return [5];
    case 'users':
    default:
      return [0];
  }
}
