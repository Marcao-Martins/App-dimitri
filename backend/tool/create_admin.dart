// tool/create_admin.dart
// Script utilitário para criar um usuário administrador
// 
// Uso: dart run tool/create_admin.dart

import 'dart:io';
import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';

void main() async {
  print('🔧 Criador de Usuário Administrador\n');
  
  // Solicita informações
  stdout.write('Nome do administrador: ');
  final name = stdin.readLineSync() ?? '';
  
  if (name.isEmpty) {
    print('❌ Nome não pode estar vazio');
    exit(1);
  }
  
  stdout.write('Email: ');
  final email = stdin.readLineSync() ?? '';
  
  if (email.isEmpty || !email.contains('@')) {
    print('❌ Email inválido');
    exit(1);
  }
  
  stdout.write('Senha (mínimo 8 caracteres): ');
  final password = stdin.readLineSync() ?? '';
  
  if (password.length < 8) {
    print('❌ Senha deve ter pelo menos 8 caracteres');
    exit(1);
  }
  
  print('\n🔐 Gerando hash da senha...');
  final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt(logRounds: 12));
  
  // Cria o objeto do usuário
  final admin = {
    'id': DateTime.now().millisecondsSinceEpoch.toString(),
    'name': name,
    'email': email,
    'password': hashedPassword,
    'role': 'administrator',
  };
  
  // Lê o arquivo users.json atual
  final file = File('data/users.json');
  List<dynamic> users = [];
  
  if (await file.exists()) {
    final content = await file.readAsString();
    if (content.trim().isNotEmpty && content.trim() != '[]') {
      users = jsonDecode(content) as List<dynamic>;
    }
  } else {
    await file.create(recursive: true);
  }
  
  // Verifica se o email já existe
  final emailExists = users.any((u) => u['email'] == email);
  if (emailExists) {
    print('❌ Email já está em uso');
    exit(1);
  }
  
  // Adiciona o novo admin
  users.add(admin);
  
  // Salva no arquivo
  await file.writeAsString(
    const JsonEncoder.withIndent('  ').convert(users),
  );
  
  print('\n✅ Administrador criado com sucesso!');
  print('\n📋 Detalhes:');
  print('   ID: ${admin['id']}');
  print('   Nome: ${admin['name']}');
  print('   Email: ${admin['email']}');
  print('   Role: ${admin['role']}');
  print('\n💡 Use estas credenciais para fazer login na API.');
}
