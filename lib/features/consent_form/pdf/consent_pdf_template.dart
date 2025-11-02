// lib/features/consent_form/pdf/consent_pdf_template.dart
// Template PDF profissional para o Termo de Consentimento

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/consent_data.dart';

class ConsentPdfTemplate {
  static Future<pw.Document> generate(ConsentData data) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Cabeçalho
          _buildHeader(data),
          pw.SizedBox(height: 20),

          // Título
          pw.Center(
            child: pw.Text(
              'TERMO DE CONSENTIMENTO LIVRE E ESCLARECIDO',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Center(
            child: pw.Text(
              'PARA PROCEDIMENTO ANESTÉSICO',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(height: 20),

          // Dados do Animal
          _buildSection('DADOS DO ANIMAL', [
            'Nome: ${data.patientName}',
            'Espécie: ${data.species}',
            'Raça: ${data.breed}',
            'Sexo: ${data.sex}',
          ]),
          pw.SizedBox(height: 15),

          // Dados do Responsável
          _buildSection('DADOS DO RESPONSÁVEL', [
            'Nome: ${data.ownerName}',
            'CPF: ${data.cpf}',
            'Telefone: ${data.phone}',
            'Endereço: ${data.address}',
          ]),
          pw.SizedBox(height: 15),

          // Procedimento
          _buildSection('PROCEDIMENTO', [
            'Tipo de Anestesia: ${data.procedureType}',
            if (data.additionalInfo.isNotEmpty)
              'Informações Adicionais: ${data.additionalInfo}',
          ]),
          pw.SizedBox(height: 15),

          // Cláusulas
          _buildClauses(),
          pw.SizedBox(height: 15),

          // Observações
          if (data.observations.isNotEmpty) ...[
            _buildSection('OBSERVAÇÕES', [data.observations]),
            pw.SizedBox(height: 15),
          ],

          // Local e Data
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('${data.city}, ${dateFormat.format(data.date)}'),
            ],
          ),
          pw.SizedBox(height: 40),

          // Assinaturas
          _buildSignatures(data),
        ],
      ),
    );

    return pdf;
  }

  static pw.Widget _buildHeader(ConsentData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          data.clinic,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text('Médico Veterinário: ${data.veterinarianName}'),
        pw.Text('CRMV: ${data.crmv}'),
        pw.Divider(thickness: 2),
      ],
    );
  }

  static pw.Widget _buildSection(String title, List<String> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
        ...items.map((item) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 3),
              child: pw.Text(item, style: const pw.TextStyle(fontSize: 10)),
            )),
      ],
    );
  }

  static pw.Widget _buildClauses() {
    final clauses = [
      'Eu, na qualidade de proprietário(a) ou responsável legal pelo animal acima identificado, DECLARO que fui devidamente informado(a) sobre todos os procedimentos que serão realizados durante o ato anestésico e/ou cirúrgico.',
      'DECLARO estar ciente dos riscos inerentes ao procedimento anestésico, incluindo, mas não se limitando a: reações adversas aos medicamentos, parada cardiorrespiratória, hipotermia, hipotensão, e possíveis complicações pós-operatórias.',
      'AUTORIZO a equipe médica veterinária a tomar todas as medidas necessárias para garantir o bem-estar do paciente durante e após o procedimento, incluindo medidas de emergência, caso sejam necessárias.',
      'DECLARO que informei ao médico veterinário todo o histórico clínico relevante do animal, incluindo alergias, medicações em uso, doenças pré-existentes e procedimentos anteriores.',
      'ESTOU CIENTE de que o jejum pré-anestésico é fundamental e que o não cumprimento das orientações pode resultar em complicações graves, incluindo aspiração de conteúdo gástrico.',
      'COMPROMETO-ME a seguir rigorosamente todas as orientações pós-operatórias fornecidas pela equipe veterinária e a comparecer às reavaliações agendadas.',
      'AUTORIZO a realização de exames complementares e procedimentos adicionais que se façam necessários durante o ato anestésico/cirúrgico para garantir a segurança do paciente.',
      'DECLARO que tive oportunidade de esclarecer todas as minhas dúvidas e que todas as informações foram prestadas de forma clara e compreensível.',
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DECLARAÇÃO DE CONSENTIMENTO',
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        ...clauses.asMap().entries.map((entry) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('${entry.key + 1}. ',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      )),
                  pw.Expanded(
                    child: pw.Text(
                      entry.value,
                      style: const pw.TextStyle(fontSize: 9),
                      textAlign: pw.TextAlign.justify,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  static pw.Widget _buildSignatures(ConsentData data) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: [
            _buildSignatureLine('Assinatura do Responsável\n${data.ownerName}'),
            _buildSignatureLine(
                'Assinatura do Médico Veterinário\n${data.veterinarianName}\nCRMV: ${data.crmv}'),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSignatureLine(String label) {
    return pw.Column(
      children: [
        pw.Container(
          width: 200,
          height: 50,
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(width: 1),
            ),
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Container(
          width: 200,
          child: pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 8),
            textAlign: pw.TextAlign.center,
          ),
        ),
      ],
    );
  }
}
