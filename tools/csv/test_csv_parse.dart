import 'dart:io';
import 'package:csv/csv.dart';
import 'dart:math' show min;

void main() async {
  final file = File('Tabela_parâmetros.csv');
  if (!await file.exists()) {
    print('❌ File not found');
    return;
  }

  final data = await file.readAsString();
  print('File size: ${data.length} chars');
  print('First 200 chars:\n${data.substring(0, 200)}\n');

  // Normalizar CSV como no controller
  final lines = data.split('\n');
  final normalizedLines = <String>[];
  var currentLine = '';
  
  for (int lineIdx = 0; lineIdx < lines.length; lineIdx++) {
    final line = lines[lineIdx];
    
    // Detecta se é uma continuação: começa com espaço/tab E não é a primeira linha
    final isContinuation = lineIdx > 0 && 
        line.isNotEmpty && 
        (line.startsWith(' ') || line.startsWith('\t'));
    
    if (isContinuation) {
      // Juntar à linha anterior
      currentLine += ' ' + line.trim();
    } else {
      // Esta é uma nova linha
      if (currentLine.isNotEmpty) {
        normalizedLines.add(currentLine);
      }
      currentLine = line;
    }
  }
  if (currentLine.isNotEmpty) {
    normalizedLines.add(currentLine);
  }
  
  print('Normalized lines: ${normalizedLines.length}');
  print('Header: ${normalizedLines[0].substring(0, min(normalizedLines[0].length, 100))}');
  if (normalizedLines.length > 1) {
    print('Row 2 preview: ${normalizedLines[1].substring(0, min(normalizedLines[1].length, 100))}');
  }

  // Mostrar o CSV normalizado antes de fazer parse
  final normalizedCsv = normalizedLines.join('\n');
  print('\nNormalized CSV preview (first 500 chars):');
  print(normalizedCsv.substring(0, min(normalizedCsv.length, 500)));
  print('\n...\n');
  
  print('Normalized CSV total chars: ${normalizedCsv.length}');
  print('Normalized CSV line count: ${normalizedCsv.split('\n').length}');

  // DEBUG: mostrar header completo
  final headerLine = normalizedLines[0];
  print('\nDEBUG - Header line length: ${headerLine.length}');
  print('DEBUG - Header contains newline: ${headerLine.contains('\n')}');
  print('DEBUG - Header contains \\r: ${headerLine.contains('\r')}');
  
  // Encontrar caracteres especiais
  var hasSpecialChars = false;
  var specialCharCodes = <int>{};
  for (int i = 0; i < headerLine.length; i++) {
    final charCode = headerLine.codeUnitAt(i);
    if (charCode < 32 && charCode != 9) { // não é espaço normal, tab
      hasSpecialChars = true;
      specialCharCodes.add(charCode);
    }
  }
  if (hasSpecialChars) {
    print('DEBUG - Special char codes found: $specialCharCodes');
    for (final code in specialCharCodes) {
      print('  Code $code (decimal) = char "${String.fromCharCode(code)}"');
    }
  } else {
    print('DEBUG - No special control characters found');
  }
  
  print('\nDEBUG - Exact header:\n$headerLine\n');

  // Parse normalizado
  final List<List<dynamic>> csvTable =
      const CsvToListConverter(
        fieldDelimiter: ',',
        textDelimiter: '"',
      ).convert(normalizedCsv);

  print('\n=== PARSED RESULT ===');
  print('Total rows: ${csvTable.length}');
  if (csvTable.isNotEmpty) {
    print('Header row length: ${csvTable[0].length}');
  }
  if (csvTable.length > 1) {
    print('Row 2 length: ${csvTable[1].length}');
    for (int i = 0; i < min(6, csvTable[1].length); i++) {
      final field = csvTable[1][i].toString().trim();
      final preview = field.length > 60 ? '${field.substring(0, 57)}...' : field;
      print('  Col $i: "${preview}"');
    }
  }
}
