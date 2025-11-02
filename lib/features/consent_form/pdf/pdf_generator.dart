// lib/features/consent_form/pdf/pdf_generator.dart
// Gerador de PDF com funcionalidades de salvar e compartilhar

import 'dart:io';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/consent_data.dart';
import 'consent_pdf_template.dart';

class PdfGenerator {
  // Gera e visualiza o PDF
  static Future<void> preview(ConsentData data) async {
    final pdf = await ConsentPdfTemplate.generate(data);
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  // Gera e compartilha o PDF
  static Future<void> share(ConsentData data) async {
    final pdf = await ConsentPdfTemplate.generate(data);
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: _generateFilename(data),
    );
  }

  // Gera e salva o PDF no dispositivo
  static Future<String?> save(ConsentData data) async {
    try {
      final pdf = await ConsentPdfTemplate.generate(data);
      final bytes = await pdf.save();

      // Obtém o diretório de documentos
      final Directory? directory = await _getDownloadDirectory();
      if (directory == null) return null;

      // Cria o arquivo
      final String filename = _generateFilename(data);
      final String filepath = '${directory.path}/$filename';
      final File file = File(filepath);

      // Salva o arquivo
      await file.writeAsBytes(bytes);
      return filepath;
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao salvar PDF: $e');
      return null;
    }
  }

  // Gera e imprime o PDF
  static Future<void> printPdf(ConsentData data) async {
    final pdf = await ConsentPdfTemplate.generate(data);
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: _generateFilename(data),
    );
  }

  // Gera nome do arquivo baseado nos dados
  static String _generateFilename(ConsentData data) {
    final date = data.date.toString().substring(0, 10).replaceAll('-', '');
    final patient = data.patientName.replaceAll(' ', '_');
    return 'Termo_Consentimento_${patient}_$date.pdf';
  }

  // Obtém diretório de download apropriado para cada plataforma
  static Future<Directory?> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // No Android, usa o diretório de Downloads
      final directory = Directory('/storage/emulated/0/Download');
      if (await directory.exists()) {
        return directory;
      }
      // Fallback para diretório externo
      return await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      // No iOS, usa o diretório de documentos do app
      return await getApplicationDocumentsDirectory();
    } else {
      // Outras plataformas
      return await getDownloadsDirectory();
    }
  }
}
