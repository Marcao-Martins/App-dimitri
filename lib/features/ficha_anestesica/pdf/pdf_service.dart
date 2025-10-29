import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../models/ficha_anestesica.dart';
import '../models/medicacao.dart';
import '../models/parametro_monitorizacao.dart';

class PdfService {
  /// Gera um PDF profissional completo da ficha anestésica
  static Future<Uint8List> generatePdfBytes(FichaAnestesica ficha) async {
    final pdf = pw.Document();

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
                pw.Text(
                  'FICHA ANESTÉSICA VETERINÁRIA',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'GDAV - Grupo de Desenvolvimento em Anestesiologia Veterinária',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 2),
              ],
            ),
          ),

          pw.SizedBox(height: 16),

          // Identificação do Paciente
          _buildSection('IDENTIFICAÇÃO DO PACIENTE', [
            _buildInfoRow('Nome', ficha.paciente.nome),
            _buildInfoRow('Data', ficha.paciente.data != null 
                ? '${ficha.paciente.data!.day}/${ficha.paciente.data!.month}/${ficha.paciente.data!.year}'
                : '-'),
            _buildInfoRow('Espécie', ficha.paciente.especie ?? '-'),
            _buildInfoRow('Sexo', ficha.paciente.sexo ?? '-'),
            _buildInfoRow('Peso', ficha.paciente.peso != null ? '${ficha.paciente.peso} kg' : '-'),
            _buildInfoRow('Idade', ficha.paciente.idade ?? '-'),
            _buildInfoRow('ASA', ficha.paciente.asa ?? '-'),
            _buildInfoRow('Procedimento', ficha.paciente.procedimento ?? '-'),
            _buildInfoRow('Doenças', ficha.paciente.doencas ?? '-'),
            _buildInfoRow('Observações', ficha.paciente.observacoes ?? '-'),
          ]),

          pw.SizedBox(height: 16),

          // Medicação Pré-anestésica
          if (ficha.preAnestesica.isNotEmpty) ...[
            _buildMedicationTable('MEDICAÇÃO PRÉ-ANESTÉSICA', ficha.preAnestesica),
            pw.SizedBox(height: 12),
          ],

          // Antimicrobianos
          if (ficha.antimicrobianos.isNotEmpty) ...[
            _buildMedicationTable('ANTIMICROBIANOS', ficha.antimicrobianos),
            pw.SizedBox(height: 12),
          ],

          // Indução
          if (ficha.inducao.isNotEmpty) ...[
            _buildMedicationTable('INDUÇÃO ANESTÉSICA', ficha.inducao),
            pw.SizedBox(height: 12),
          ],

          // Manutenção
          if (ficha.manutencao.isNotEmpty) ...[
            _buildMedicationTable('MANUTENÇÃO ANESTÉSICA', ficha.manutencao),
            pw.SizedBox(height: 12),
          ],

          // Locorregional
          if (ficha.locorregional.isNotEmpty) ...[
            _buildMedicationTable('ANESTESIA LOCORREGIONAL', ficha.locorregional),
            pw.SizedBox(height: 12),
          ],

          // Monitorização
          if (ficha.parametros.isNotEmpty) ...[
            _buildMonitoringTable(ficha.parametros),
            pw.SizedBox(height: 12),
          ],

          // Intercorrências
          if (ficha.intercorrencias.isNotEmpty) ...[
            _buildSection('INTERCORRÊNCIAS E OBSERVAÇÕES', 
              ficha.intercorrencias.map((ic) => pw.Text(
                '• ${ic.momento.hour}:${ic.momento.minute.toString().padLeft(2, '0')} - ${ic.descricao}',
                style: const pw.TextStyle(fontSize: 10),
              )).toList(),
            ),
            pw.SizedBox(height: 12),
          ],

          // Analgesia pós-operatória
          if (ficha.analgesiaPosOperatoria.isNotEmpty) ...[
            _buildMedicationTable('ANALGESIA PÓS-OPERATÓRIA', ficha.analgesiaPosOperatoria),
            pw.SizedBox(height: 12),
          ],

          pw.SizedBox(height: 24),

          // Rodapé
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Assinatura do Médico Veterinário: _________________________________',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Data: ___/___/______   CRMV: __________',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 12),
          pw.Text(
            'Documento gerado pelo aplicativo GDAV',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildSection(String title, List<pw.Widget> children) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildMedicationTable(String title, List<Medicacao> meds) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellHeight: 20,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
            },
            headers: ['Fármaco', 'Dose', 'Via', 'Hora'],
            data: meds.map((m) => [
              m.nome,
              m.dose ?? '-',
              m.via ?? '-',
              m.hora != null ? '${m.hora!.hour}:${m.hora!.minute.toString().padLeft(2, '0')}' : '-',
            ]).toList(),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildMonitoringTable(List<ParametroMonitorizacao> params) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'MONITORIZAÇÃO DE PARÂMETROS',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 8),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellHeight: 18,
            cellAlignments: {
              0: pw.Alignment.center,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
              4: pw.Alignment.center,
              5: pw.Alignment.center,
              6: pw.Alignment.center,
              7: pw.Alignment.center,
              8: pw.Alignment.center,
            },
            headers: ['Tempo', 'FC', 'FR', 'SpO2', 'ETCO2', 'PAS', 'PAD', 'PAM', 'Temp'],
            data: params.map((p) => [
              '${p.momento.hour}:${p.momento.minute.toString().padLeft(2, '0')}',
              p.fc?.toString() ?? '-',
              p.fr?.toString() ?? '-',
              p.spo2?.toString() ?? '-',
              p.etco2?.toString() ?? '-',
              p.pas?.toString() ?? '-',
              p.pad?.toString() ?? '-',
              p.pam?.toString() ?? '-',
              p.temp?.toStringAsFixed(1) ?? '-',
            ]).toList(),
          ),
        ],
      ),
    );
  }

  /// Helper: abrir o diálogo de impressão/compartilhamento
  static Future<void> printFicha(FichaAnestesica ficha) async {
    final bytes = await generatePdfBytes(ficha);
    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
      name: 'Ficha_Anestesica_${ficha.paciente.nome}.pdf',
    );
  }

  /// Salvar PDF em arquivo (para uso futuro com share/download)
  static Future<void> savePdfToFile(FichaAnestesica ficha, String path) async {
    // Implementar salvamento com path_provider se necessário
    // final bytes = await generatePdfBytes(ficha);
    // final file = File(path);
    // await file.writeAsBytes(bytes);
  }
}
