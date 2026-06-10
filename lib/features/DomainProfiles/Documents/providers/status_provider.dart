import 'package:flutter/material.dart';
import 'package:zonix/features/utils/app_colors.dart';

class StatusProvider with ChangeNotifier {
  
  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.statusWarning;
      case 'verifying':
        return AppColors.statusInfo;
      case 'waiting':
        return AppColors.brandTealDeep;
      case 'dispatched':
        return AppColors.statusSuccess;
      case 'canceled':
        return AppColors.statusError;
      case 'expired':
        return AppColors.brandCtaAccent;
      default:
        return AppColors.black;
    }
  }

  AssetImage getStatusIcon(String status) {
    return const AssetImage('assets/images/splash_logo_dark.png'); // Puedes personalizar según el estado
  }


  String getStatusSpanish(String status) {
    switch (status) {
      case 'pending':
        return 'PENDIENTE';
      case 'verifying':
        return 'VERIFICANDO';
      case 'waiting':
        return 'ESPERANDO';
      case 'dispatched':
        return 'DESPACHADO';
      case 'canceled':
        return 'CANCELADO';
      case 'expired':
        return 'EXPIRADO';
      default:
        return 'ESTADO DESCONOCIDO';
    }
  }
}
