import 'dart:io';

void main() async {
  final file = File('Tabela_parâmetros.csv');
  final data = await file.readAsString();
  
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
  
  final csvTable = _parseCustomCsv(normalizedLines);
  
  // Procurar pelos 3 parâmetros de pressão arterial
  final parametrosDesejados = ['Pressão arterial sistólica', 'Pressão arterial média', 'Pressão arterial diastólica'];
  
  for (final param in parametrosDesejados) {
    for (int i = 0; i < csvTable.length; i++) {
      final row = csvTable[i];
      if (row.length >= 1 && row[0].contains(param)) {
        print('\n✓ $param:');
        print('  Cão: "${row.length > 1 ? row[1] : "N/A"}"');
        print('  Gato: "${row.length > 2 ? row[2] : "N/A"}"');
        print('  Cavalo: "${row.length > 3 ? row[3] : "N/A"}"');
        break;
      }
    }
  }
  
  print('\n\nTotal de linhas normalizadas: ${normalizedLines.length}');
  print('Total de parâmetros: ${csvTable.length - 1}');
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
        if (nextChar == '"' && insideQuotes) {
          currentField += '"';
          i++;
        } else {
          insideQuotes = !insideQuotes;
        }
      } else if (char == ',' && !insideQuotes) {
        fields.add(currentField.trim());
        currentField = '';
      } else {
        currentField += char;
      }
    }
    
    fields.add(currentField.trim());
    
    while (fields.isNotEmpty && fields.last.isEmpty) {
      fields.removeLast();
    }
    
    if (fields.isNotEmpty) {
      result.add(fields);
    }
  }
  
  return result;
}
