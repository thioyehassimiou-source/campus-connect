import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class DownloadService {
  /// Télécharge un fichier depuis une URL
  static Future<void> downloadFile(String url, String filename, BuildContext context) async {
    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Télécharger le fichier
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        // Sauvegarder le fichier
        await saveToDevice(response.bodyBytes, filename);
        
        if (context.mounted) {
          Navigator.pop(context); // Fermer le loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fichier téléchargé: $filename')),
          );
        }
      } else {
        throw Exception('Erreur de téléchargement: ${response.statusCode}');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Fermer le loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  /// Sauvegarde des bytes sur l'appareil
  static Future<void> saveToDevice(Uint8List bytes, String filename) async {
    try {
      Directory? directory;
      
      if (Platform.isAndroid) {
        // Sur Android, utiliser le dossier Downloads
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        // Sur iOS, utiliser le dossier Documents
        directory = await getApplicationDocumentsDirectory();
      } else {
        // Autres plateformes
        directory = await getDownloadsDirectory();
      }

      if (directory != null) {
        final filePath = '${directory.path}/$filename';
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        print('✅ Fichier sauvegardé: $filePath');
      }
    } catch (e) {
      print('❌ Erreur sauvegarde: $e');
      rethrow;
    }
  }

  /// Sauvegarde un PDF avec prévisualisation
  static Future<void> savePdfWithPreview(
    Uint8List pdfBytes,
    String filename,
    BuildContext context,
  ) async {
    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: filename,
    );
  }

  /// Partage un PDF
  static Future<void> sharePdf(Uint8List pdfBytes, String filename) async {
    await Printing.sharePdf(bytes: pdfBytes, filename: filename);
  }
}
