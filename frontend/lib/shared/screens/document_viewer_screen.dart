import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:campusconnect/config/api_config.dart';

class DocumentViewerScreen extends StatelessWidget {
  final String title;
  final String url;

  const DocumentViewerScreen({
    super.key,
    required this.title,
    required this.url,
  });

  String get _fullUrl {
    if (url.startsWith('http')) return url;
    return '${ApiConfig.baseUrl}$url';
  }

  Future<void> _downloadFile(BuildContext context) async {
    final uri = Uri.parse(_fullUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir le fichier')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPdf = url.toLowerCase().endsWith('.pdf');
    final isImage = ['.jpg', '.jpeg', '.png', '.webp', '.gif'].any((ext) => url.toLowerCase().endsWith(ext));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () => _downloadFile(context),
          ),
        ],
      ),
      body: Center(
        child: isImage
            ? InteractiveViewer(
                child: Image.network(
                  _fullUrl,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const CircularProgressIndicator();
                  },
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isPdf ? Icons.picture_as_pdf_rounded : Icons.insert_drive_file_rounded,
                    size: 80,
                    color: isPdf ? Colors.red : Colors.blue,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Ce type de document doit être ouvert avec une application externe.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () => _downloadFile(context),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('OUVRIR LE DOCUMENT'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
