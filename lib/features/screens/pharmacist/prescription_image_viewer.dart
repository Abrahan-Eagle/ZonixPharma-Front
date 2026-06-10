import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zonix/config/app_config.dart';
import 'package:zonix/helpers/auth_helper.dart';
import 'package:zonix/models/prescription.dart';

/// Muestra la imagen de receta usando URL autenticada cuando el backend la provee.
class PrescriptionImageViewer extends StatefulWidget {
  final Prescription prescription;

  const PrescriptionImageViewer({super.key, required this.prescription});

  @override
  State<PrescriptionImageViewer> createState() =>
      _PrescriptionImageViewerState();
}

class _PrescriptionImageViewerState extends State<PrescriptionImageViewer> {
  late Future<Uint8List?> _bytesFuture;

  @override
  void initState() {
    super.initState();
    _bytesFuture = _loadBytes();
  }

  @override
  void didUpdateWidget(covariant PrescriptionImageViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.prescription.id != widget.prescription.id ||
        oldWidget.prescription.authenticatedDownloadUrl !=
            widget.prescription.authenticatedDownloadUrl) {
      _bytesFuture = _loadBytes();
    }
  }

  Future<Uint8List?> _loadBytes() async {
    final authPath = widget.prescription.authenticatedDownloadUrl;
    if (authPath == null || authPath.isEmpty) {
      return null;
    }
    final uri = authPath.startsWith('http')
        ? Uri.parse(authPath)
        : Uri.parse('${AppConfig.apiUrl}$authPath');
    final headers = await AuthHelper.getAuthHeaders();
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.prescription;
    if (p.isPdfDisplay) {
      return const Center(
        child: Icon(Icons.picture_as_pdf, size: 64),
      );
    }

    final publicUrl = p.imageUrl.trim();
    if (p.authenticatedDownloadUrl == null && publicUrl.isNotEmpty) {
      return Image.network(publicUrl, fit: BoxFit.cover);
    }

    return FutureBuilder<Uint8List?>(
      future: _bytesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final bytes = snapshot.data;
        if (bytes != null && bytes.isNotEmpty) {
          return Image.memory(bytes, fit: BoxFit.cover);
        }
        if (publicUrl.isNotEmpty) {
          return Image.network(publicUrl, fit: BoxFit.cover);
        }
        return const Center(
          child: Icon(Icons.image_not_supported_outlined, size: 48),
        );
      },
    );
  }
}
