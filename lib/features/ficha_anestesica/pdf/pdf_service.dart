import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../models/ficha_anestesica.dart';
import '../models/medicacao.dart';
import '../models/parametro_monitorizacao.dart';

/// Classe auxiliar para representar uma linha em um gráfico multi-linha
class ChartLine {
  final String label;
  final double? Function(ParametroMonitorizacao) getValue;
  final PdfColor color;

  ChartLine(this.label, this.getValue, this.color);
}

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
          
          // Gráficos de Tendência
          if (ficha.parametros.length >= 2) ...[
            pw.SizedBox(height: 12),
            _buildChartsSection(ficha.parametros),
            pw.SizedBox(height: 12),
          ],

          // Intercorrências
          if (ficha.intercorrencias.isNotEmpty) ...[
            _buildIntercorrenciasSection(ficha.intercorrencias),
            pw.SizedBox(height: 12),
          ],
          
          // Fármacos Intraoperatórios
          if (ficha.farmacosIntraoperatorios.isNotEmpty) ...[
            _buildFarmacosIntraoperatoriosTable(ficha.farmacosIntraoperatorios),
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

  static pw.Widget _buildChartsSection(List<ParametroMonitorizacao> params) {
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
            'GRÁFICOS DE TENDÊNCIA',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          
          // Gráfico de FC
          if (params.any((p) => p.fc != null))
            _buildLineChart(
              'Frequência Cardíaca (bpm)',
              params,
              (p) => p.fc?.toDouble(),
              PdfColors.red,
              0,
              200,
            ),
          pw.SizedBox(height: 12),
          
          // Gráfico de Pressão Arterial
          if (params.any((p) => p.pas != null || p.pad != null || p.pam != null))
            _buildMultiLineChart(
              'Pressão Arterial (mmHg)',
              params,
              [
                ChartLine('PAS', (p) => p.pas?.toDouble(), PdfColors.red700),
                ChartLine('PAD', (p) => p.pad?.toDouble(), PdfColors.blue700),
                ChartLine('PAM', (p) => p.pam?.toDouble(), PdfColors.green700),
              ],
              0,
              200,
            ),
          pw.SizedBox(height: 12),
          
          // Gráfico de SpO2
          if (params.any((p) => p.spo2 != null))
            _buildLineChart(
              'SpO2 (%)',
              params,
              (p) => p.spo2?.toDouble(),
              PdfColors.green,
              80,
              100,
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildLineChart(
    String title,
    List<ParametroMonitorizacao> params,
    double? Function(ParametroMonitorizacao) getValue,
    PdfColor color,
    double minY,
    double maxY,
  ) {
    final chartWidth = 480.0;
    final chartHeight = 100.0;
    
    // Coletar valores válidos com seus índices
    final validData = <int, double>{};
    for (var i = 0; i < params.length; i++) {
      final value = getValue(params[i]);
      if (value != null) {
        validData[i] = value;
      }
    }

    if (validData.isEmpty) return pw.SizedBox();
    
    final maxIndex = params.length - 1;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Container(
          width: chartWidth,
          height: chartHeight + 20,
          child: pw.Stack(
            children: [
              // Grade de fundo
              pw.Positioned(
                left: 0,
                top: 0,
                child: pw.Container(
                  width: chartWidth,
                  height: chartHeight,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.CustomPaint(
                    painter: (canvas, size) {
                      // Linhas horizontais da grade
                      for (var i = 0; i <= 4; i++) {
                        final y = (i / 4) * chartHeight;
                        canvas.drawLine(0, y, chartWidth, y);
                        canvas.setStrokeColor(PdfColors.grey200);
                        canvas.strokePath();
                      }
                    },
                  ),
                ),
              ),
              // Linha do gráfico
              pw.Positioned(
                left: 0,
                top: 0,
                child: pw.CustomPaint(
                  size: PdfPoint(chartWidth, chartHeight),
                  painter: (canvas, size) {
                    final entries = validData.entries.toList();
                    
                    // Desenhar linhas conectando os pontos
                    canvas.setStrokeColor(color);
                    canvas.setLineWidth(1.5);
                    
                    for (var i = 0; i < entries.length - 1; i++) {
                      final x1 = (entries[i].key / maxIndex) * chartWidth;
                      final y1 = chartHeight - ((entries[i].value - minY) / (maxY - minY) * chartHeight);
                      final x2 = (entries[i + 1].key / maxIndex) * chartWidth;
                      final y2 = chartHeight - ((entries[i + 1].value - minY) / (maxY - minY) * chartHeight);
                      
                      canvas.moveTo(x1, y1.clamp(0, chartHeight));
                      canvas.lineTo(x2, y2.clamp(0, chartHeight));
                      canvas.strokePath();
                    }
                    
                    // Desenhar pontos
                    canvas.setFillColor(color);
                    for (final entry in entries) {
                      final x = (entry.key / maxIndex) * chartWidth;
                      final y = chartHeight - ((entry.value - minY) / (maxY - minY) * chartHeight);
                      final yPos = y.clamp(0, chartHeight);
                      
                      canvas.drawEllipse(x - 2, yPos - 2, 4, 4);
                      canvas.fillPath();
                    }
                  },
                ),
              ),
              // Labels de tempo
              pw.Positioned(
                left: 0,
                top: chartHeight + 4,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.SizedBox(
                      width: chartWidth / 2,
                      child: pw.Text(
                        '${params.first.momento.hour}:${params.first.momento.minute.toString().padLeft(2, '0')}',
                        style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                      ),
                    ),
                    pw.SizedBox(
                      width: chartWidth / 2,
                      child: pw.Text(
                        '${params.last.momento.hour}:${params.last.momento.minute.toString().padLeft(2, '0')}',
                        style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildMultiLineChart(
    String title,
    List<ParametroMonitorizacao> params,
    List<ChartLine> lines,
    double minY,
    double maxY,
  ) {
    final chartWidth = 480.0;
    final chartHeight = 100.0;
    final maxIndex = params.length - 1;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Text(title, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 8),
            ...lines.map((line) => pw.Container(
              margin: const pw.EdgeInsets.only(right: 6),
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 10,
                    height: 2,
                    color: line.color,
                  ),
                  pw.SizedBox(width: 2),
                  pw.Text(line.label, style: const pw.TextStyle(fontSize: 7)),
                ],
              ),
            )),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Container(
          width: chartWidth,
          height: chartHeight + 20,
          child: pw.Stack(
            children: [
              // Grade
              pw.Positioned(
                left: 0,
                top: 0,
                child: pw.Container(
                  width: chartWidth,
                  height: chartHeight,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.CustomPaint(
                    painter: (canvas, size) {
                      for (var i = 0; i <= 4; i++) {
                        final y = (i / 4) * chartHeight;
                        canvas.drawLine(0, y, chartWidth, y);
                        canvas.setStrokeColor(PdfColors.grey200);
                        canvas.strokePath();
                      }
                    },
                  ),
                ),
              ),
              // Linhas
              pw.Positioned(
                left: 0,
                top: 0,
                child: pw.CustomPaint(
                  size: PdfPoint(chartWidth, chartHeight),
                  painter: (canvas, size) {
                    for (final line in lines) {
                      final validData = <int, double>{};
                      for (var i = 0; i < params.length; i++) {
                        final value = line.getValue(params[i]);
                        if (value != null) validData[i] = value;
                      }
                      
                      if (validData.isNotEmpty) {
                        final entries = validData.entries.toList();
                        
                        canvas.setStrokeColor(line.color);
                        canvas.setLineWidth(1.2);
                        
                        for (var i = 0; i < entries.length - 1; i++) {
                          final x1 = (entries[i].key / maxIndex) * chartWidth;
                          final y1 = chartHeight - ((entries[i].value - minY) / (maxY - minY) * chartHeight);
                          final x2 = (entries[i + 1].key / maxIndex) * chartWidth;
                          final y2 = chartHeight - ((entries[i + 1].value - minY) / (maxY - minY) * chartHeight);
                          
                          canvas.moveTo(x1, y1.clamp(0, chartHeight));
                          canvas.lineTo(x2, y2.clamp(0, chartHeight));
                          canvas.strokePath();
                        }
                        
                        canvas.setFillColor(line.color);
                        for (final entry in entries) {
                          final x = (entry.key / maxIndex) * chartWidth;
                          final y = chartHeight - ((entry.value - minY) / (maxY - minY) * chartHeight);
                          canvas.drawEllipse(x - 1.5, y.clamp(0, chartHeight) - 1.5, 3, 3);
                          canvas.fillPath();
                        }
                      }
                    }
                  },
                ),
              ),
              // Labels
              pw.Positioned(
                left: 0,
                top: chartHeight + 4,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.SizedBox(
                      width: chartWidth / 2,
                      child: pw.Text(
                        '${params.first.momento.hour}:${params.first.momento.minute.toString().padLeft(2, '0')}',
                        style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                      ),
                    ),
                    pw.SizedBox(
                      width: chartWidth / 2,
                      child: pw.Text(
                        '${params.last.momento.hour}:${params.last.momento.minute.toString().padLeft(2, '0')}',
                        style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Constrói seção de intercorrências com cores por gravidade
  static pw.Widget _buildIntercorrenciasSection(List<dynamic> intercorrencias) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'INTERCORRÊNCIAS',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Table(
            border: pw.TableBorder.symmetric(
              inside: const pw.BorderSide(color: PdfColors.grey300),
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(4),
            },
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      'Hora',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      'Gravidade',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      'Descrição',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              // Dados
              ...intercorrencias.map((ic) {
                final gravidade = ic.gravidade ?? 'leve';
                final cor = gravidade == 'grave'
                    ? PdfColors.red100
                    : gravidade == 'moderada'
                        ? PdfColors.orange100
                        : PdfColors.yellow100;
                
                return pw.TableRow(
                  decoration: pw.BoxDecoration(color: cor),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        '${ic.momento.hour.toString().padLeft(2, '0')}:${ic.momento.minute.toString().padLeft(2, '0')}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        gravidade.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        ic.descricao ?? '',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  /// Constrói tabela de fármacos intraoperatórios
  static pw.Widget _buildFarmacosIntraoperatoriosTable(List<dynamic> farmacos) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'FÁRMACOS ADMINISTRADOS DURANTE O PROCEDIMENTO',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Table(
            border: pw.TableBorder.symmetric(
              inside: const pw.BorderSide(color: PdfColors.grey300),
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1),
            },
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      'Hora',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      'Fármaco',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      'Dose',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      'Via',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              // Dados
              ...farmacos.map((farmaco) {
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        '${farmaco.hora.hour.toString().padLeft(2, '0')}:${farmaco.hora.minute.toString().padLeft(2, '0')}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        farmaco.nome ?? '',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        '${farmaco.dose} ${farmaco.unidade}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        farmaco.via ?? '',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
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
