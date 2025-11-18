import 'package:backend/providers/database_provider.dart';

Future<void> main() async {
  final provider = DatabaseProvider();
  try {
    await provider.initialize();
    print('Loaded ${provider.farmacos.length} farmacos');
    if (provider.farmacos.isNotEmpty) {
      final f = provider.farmacos.first;
      print('First: ${f.titulo} (${f.postId})');
    }
  } catch (e, st) {
    print('ERROR during load: $e');
    print(st);
  }
}
