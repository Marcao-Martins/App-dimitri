import 'dart:io';

void main() async {
  final file = File('Tabela_parâmetros.csv');
  if (!await file.exists()) {
    print('❌ File not found');
    return;
  }

  final data = await file.readAsString();
  
  // Normalizar como no controller
  final lines = data.split('\n');
  final normalizedLines = <String>[];
  var currentLine = '';
  
  for (int idx = 0; idx < lines.length; idx++) {
    final line = lines[idx];
    final isNewLogicalLine = (idx == 0) || 
        (line.isNotEmpty && !line.startsWith(' ') && !line.startsWith('\t'));
    
    if (isNewLogicalLine) {
      if (currentLine.isNotEmpty) {
        final cleanedLine = currentLine.replaceAll('\r\n', ' ').replaceAll('\n', ' ').replaceAll('\r', ' ');
        normalizedLines.add(cleanedLine);
      }
      currentLine = line;
    } else {
      if (line.isNotEmpty) {
        currentLine += ' ' + line.trim();
      }
    }
  }
  if (currentLine.isNotEmpty) {
    final cleanedLine = currentLine.replaceAll('\r\n', ' ').replaceAll('\n', ' ').replaceAll('\r', ' ');
    normalizedLines.add(cleanedLine);
  }
  
  print('Normalized lines: ${normalizedLines.length}');

  // Parser manual customizado
  final csvTable = _parseCustomCsv(normalizedLines);
  
  print('Total rows: ${csvTable.length}');
  if (csvTable.isNotEmpty) {
    print('Header row (${csvTable[0].length} fields): ${csvTable[0].toString()}');
  }
  if (csvTable.length > 1) {
    print('Row 2 (${csvTable[1].length} fields):');
    for (int i = 0; i < csvTable[1].length; i++) {
      final field = csvTable[1][i].toString();
      final preview = field.length > 60 ? '${field.substring(0, 57)}...' : field;
      print('  Field $i: "${preview}"');
    }
  }
}

List<List<dynamic>> _parseCustomCsv(List<String> lines) {
  final result = <List<dynamic>>[];
  
  for (final line in lines) {
    final fields = <String>[];
    var currentField = '';
    var insideQuotes = false;
    
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      final nextChar = i + 1 < line.length ? line[i + 1] : '';
      
      if (char == '"') {
        // Toggle quote mode
        // Escapar quotes: "" dentro de um campo quoted se torna uma única "
        if (nextChar == '"' && insideQuotes) {
          currentField += '"';
          i++; // Skip next quote
        } else {
          insideQuotes = !insideQuotes;
        }
      } else if (char == ',' && !insideQuotes) {
        // Fim do campo
        fields.add(currentField.trim());
        currentField = '';
      } else {
        currentField += char;
      }
    }
    
    // Adicionar o último campo
    fields.add(currentField.trim());
    
    // Limpar campos vazios no final (por causa dos muitos espaços no header)
    while (fields.isNotEmpty && fields.last.isEmpty) {
      fields.removeLast();
    }
    
    if (fields.isNotEmpty) {
      result.add(fields);
    }
  }
  
  return result;
}
