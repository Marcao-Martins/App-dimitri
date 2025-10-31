// routes/index.dart
// Rota raiz do servidor
// GET / - Informações sobre a API

import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: {
      'name': 'API Veterinária - Fármacos e Autenticação',
      'version': '1.0.0',
      'status': 'online',
      'endpoints': {
        'public': [
          'GET /',
          'GET /api/v1/farmacos',
          'POST /api/v1/auth/register',
          'POST /api/v1/auth/login',
        ],
        'protected': [
          'GET /api/v1/profile',
        ],
        'admin': [
          'POST /api/v1/farmacos',
        ],
      },
      'documentation': 'Consulte o README.md para mais informações',
    },
  );
}
