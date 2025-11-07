import 'dart:io';

void main() async {
  final file = File('Tabela_parâmetros.csv');
  final data = await file.readAsString();
  final lines = data.split('\n');
  
  print('=== FIRST 3 LINES (RAW BYTES) ===\n');
  
  for (int i = 0; i < 3 && i < lines.length; i++) {
    final line = lines[i];
    print('Line $i: length=${line.length}');
    print('  Text: "$line"');
    print('  Bytes: ');
    for (int j = 0; j < line.length; j++) {
      final code = line.codeUnitAt(j);
      if (j % 20 == 0) print('    ');
      print('${code.toString().padLeft(3)} ');
    }
    print('\n');
  }
  
  // After detection
  print('\n=== AFTER SPLIT - CHECKING STRUCTURE ===\n');
  print('Total split lines: ${lines.length}');
  for (int i = 0; i < 5 && i < lines.length; i++) {
    print('Line $i starts with space: ${lines[i].startsWith(' ')}');
    print('Line $i starts with tab: ${lines[i].startsWith('\t')}');
    print('Line $i: "${lines[i].substring(0, 60)}"');
  }
}
