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
  
  // Parser manual
  final csvTable = _parseCustomCsv(normalizedLines);
  
  // Procurar por PAS
  for (int i = 0; i < csvTable.length; i++) {
    final row = csvTable[i];
    if (row.length >= 1 && row[0].contains('Pressão arterial sistólica')) {
      print('Found PAS at row $i:');
      for (int j = 0; j < row.length; j++) {
        final field = row[j].toString();
        print('  Field $j: "${field.length > 80 ? field.substring(0, 77) + '...' : field}"');
      }
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
