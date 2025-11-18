import 'dart:convert';
import 'dart:io';

import 'package:backend/providers/database_provider.dart';

Future<void> main() async {
  final provider = DatabaseProvider();
  try {
    await provider.initialize();
    final farmacos = provider.farmacos.map((f) => f.toJson()).toList();

    final outDir = Directory('backend/data');
    if (!outDir.existsSync()) {
      outDir.createSync(recursive: true);
    }

    final outFile = File('${outDir.path}/farmacos_veterinarios.json');
    await outFile.writeAsString(const JsonEncoder.withIndent('  ').convert(farmacos), flush: true);
    print('✅ JSON cache gravado em: ${outFile.path} (${farmacos.length} itens)');
  } catch (e, st) {
    print('❌ Erro ao gerar JSON cache: $e');
    print(st);
    exitCode = 1;
  }
}
