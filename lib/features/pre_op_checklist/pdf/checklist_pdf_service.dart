import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../../models/checklist.dart';

class ChecklistPdfService {
  /// Gera PDF do checklist pré-operatório
  static Future<Uint8List> generatePdfBytes({
    required String patientName,
    required String species,
    required double weightKg,
    required String asaClassification,
    required List<ChecklistItem> items,
    DateTime? fastingStartTime,
  }) async {
    final pdf = pw.Document();

    // Agrupar itens por categoria
    final Map<String, List<ChecklistItem>> itemsByCategory = {};
    for (var item in items) {
      if (!itemsByCategory.containsKey(item.category)) {
        itemsByCategory[item.category] = [];
      }
      itemsByCategory[item.category]!.add(item);
    }

    final totalItems = items.length;
    final completedItems = items.where((item) => item.isCompleted).length;
    final progressPercentage = (completedItems / totalItems * 100).toStringAsFixed(1);

    // Calcular duração do jejum
    String fastingDurationText = '-';
    if (fastingStartTime != null) {
      final duration = DateTime.now().difference(fastingStartTime);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      fastingDurationText = '${hours}h ${minutes}min';
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Cabeçalho
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'CHECKLIST PRÉ-OPERATÓRIO',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'GDAV - Grupo de Desenvolvimento em Anestesiologia Veterinária',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue50,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'Progresso',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue800,
                            ),
                          ),
                          pw.Text(
                            '$progressPercentage%',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue800,
                            ),
                          ),
                          pw.Text(
                            '$completedItems/$totalItems itens',
                            style: const pw.TextStyle(
                              fontSize: 8,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 2),
              ],
            ),
          ),

          pw.SizedBox(height: 16),

          // Informações do Paciente
          _buildSection('INFORMAÇÕES DO PACIENTE', [
            _buildInfoRow('Paciente', patientName),
            _buildInfoRow('Espécie', species),
            _buildInfoRow('Peso', '$weightKg kg'),
            _buildInfoRow('Classificação ASA', asaClassification),
            _buildInfoRow('Tempo de Jejum', fastingDurationText),
            _buildInfoRow('Data/Hora', _formatDateTime(DateTime.now())),
          ]),

          pw.SizedBox(height: 20),

          // Itens do Checklist por Categoria
          ...itemsByCategory.entries.map((entry) {
            final category = entry.key;
            final categoryItems = entry.value;
            final completedInCategory = categoryItems.where((i) => i.isCompleted).length;

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Cabeçalho da categoria
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey300,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        category.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        '$completedInCategory/${categoryItems.length}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 8),

                // Itens da categoria
                ...categoryItems.map((item) => _buildChecklistItem(item)),

                pw.SizedBox(height: 16),
              ],
            );
          }),

          pw.SizedBox(height: 20),

          // Resumo final
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: completedItems == totalItems ? PdfColors.green50 : PdfColors.orange50,
              border: pw.Border.all(
                color: completedItems == totalItems ? PdfColors.green : PdfColors.orange,
                width: 2,
              ),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  completedItems == totalItems 
                      ? '✓ CHECKLIST COMPLETO'
                      : '⚠ CHECKLIST INCOMPLETO',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: completedItems == totalItems ? PdfColors.green800 : PdfColors.orange800,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  completedItems == totalItems
                      ? 'Todos os itens do checklist foram verificados. O paciente está pronto para o procedimento anestésico.'
                      : 'Existem itens pendentes no checklist. Certifique-se de completar todas as verificações antes de prosseguir.',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
                ),
                if (completedItems < totalItems) ...[
                  pw.SizedBox(height: 12),
                  pw.Text(
                    'Itens Pendentes:',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.orange800,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  ...items.where((item) => !item.isCompleted).map((item) => 
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 12, top: 2),
                      child: pw.Text(
                        '• ${item.title}',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Assinaturas
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildSignatureField('Responsável'),
              _buildSignatureField('Supervisor'),
            ],
          ),

          pw.SizedBox(height: 12),

          // Rodapé
          pw.Center(
            child: pw.Text(
              'Documento gerado em ${_formatDateTime(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  /// Constrói uma seção do PDF
  static pw.Widget _buildSection(String title, List<pw.Widget> content) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: content,
          ),
        ),
      ],
    );
  }

  /// Constrói uma linha de informação
  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói um item do checklist
  static pw.Widget _buildChecklistItem(ChecklistItem item) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      margin: const pw.EdgeInsets.only(bottom: 4),
      decoration: pw.BoxDecoration(
        color: item.isCompleted ? PdfColors.green50 : PdfColors.grey100,
        border: pw.Border.all(
          color: item.isCompleted ? PdfColors.green : PdfColors.grey300,
          width: 1,
        ),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Checkbox
          pw.Container(
            width: 16,
            height: 16,
            margin: const pw.EdgeInsets.only(right: 8, top: 2),
            decoration: pw.BoxDecoration(
              color: item.isCompleted ? PdfColors.green : PdfColors.white,
              border: pw.Border.all(
                color: item.isCompleted ? PdfColors.green : PdfColors.grey600,
                width: 2,
              ),
              borderRadius: pw.BorderRadius.circular(3),
            ),
            child: item.isCompleted
                ? pw.Center(
                    child: pw.Text(
                      '✓',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  )
                : null,
          ),

          // Conteúdo
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        item.title,
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: item.isCompleted ? PdfColors.grey800 : PdfColors.black,
                        ),
                      ),
                    ),
                    if (item.isCritical)
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.red,
                          borderRadius: pw.BorderRadius.circular(3),
                        ),
                        child: pw.Text(
                          'CRÍTICO',
                          style: pw.TextStyle(
                            fontSize: 7,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                if (item.description.isNotEmpty) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    item.description,
                    style: pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói um campo de assinatura
  static pw.Widget _buildSignatureField(String label) {
    return pw.Column(
      children: [
        pw.Container(
          width: 200,
          height: 1,
          color: PdfColors.grey800,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
      ],
    );
  }

  /// Formata data e hora
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Exporta o PDF para impressão ou compartilhamento
  static Future<void> exportPdf({
    required String patientName,
    required String species,
    required double weightKg,
    required String asaClassification,
    required List<ChecklistItem> items,
    DateTime? fastingStartTime,
  }) async {
    final pdfBytes = await generatePdfBytes(
      patientName: patientName,
      species: species,
      weightKg: weightKg,
      asaClassification: asaClassification,
      items: items,
      fastingStartTime: fastingStartTime,
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: 'Checklist_Pre_Operatorio_${patientName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }
}
