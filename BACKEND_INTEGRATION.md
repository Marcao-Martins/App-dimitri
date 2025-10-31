# Guia de Integração com Back-end - Bulário de Medicamentos

## 📋 Mudanças Realizadas

Os dados artificiais dos medicamentos foram **removidos** do arquivo `lib/services/medication_service.dart`. O serviço agora está preparado para receber dados de um back-end externo.

## 🔄 Estado Atual

### Antes (Dados Mockados)
```dart
static final List<Medication> _medications = [
  Medication(id: 'ketamine', name: 'Ketamina', ...),
  Medication(id: 'propofol', name: 'Propofol', ...),
  // ... 20 medicamentos hardcoded
];
```

### Agora (Preparado para Back-end)
```dart
static final List<Medication> _medications = [];
static bool _isLoaded = false;

// Métodos auxiliares para gerenciar os dados:
- addMedication(Medication)
- clearMedications()
- setMedications(List<Medication>)
- isLoaded getter
```

## 🚀 Como Integrar com Back-end

### 1. Adicionar Dependências HTTP

Adicione ao `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0  # Para requisições HTTP
```

Execute:
```bash
flutter pub get
```

### 2. Implementar o Método de Carregamento

Adicione ao `MedicationService`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

static Future<void> loadMedicationsFromBackend() async {
  try {
    final response = await http.get(
      Uri.parse('https://sua-api.com/api/medications'),
      headers: {
        'Content-Type': 'application/json',
        // Adicione tokens de autenticação se necessário:
        // 'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setMedications(
        data.map((json) => Medication.fromJson(json)).toList()
      );
    } else {
      throw Exception('Erro ao carregar: ${response.statusCode}');
    }
  } catch (e) {
    print('Erro ao carregar medicamentos: $e');
    rethrow;
  }
}
```

### 3. Chamar no Início do App

No `main.dart` ou no `DrugGuidePage`:

```dart
@override
void initState() {
  super.initState();
  _loadData();
}

Future<void> _loadData() async {
  setState(() => _isLoading = true);
  
  try {
    await MedicationService.loadMedicationsFromBackend();
    setState(() {
      _medications = MedicationService.getAllMedications();
      _filteredMedications = _medications;
    });
  } catch (e) {
    // Mostrar erro ao usuário
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar medicamentos: $e')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}
```

## 📡 Formato Esperado da API

O back-end deve retornar um JSON array com objetos no seguinte formato:

```json
[
  {
    "id": "ketamine",
    "name": "Ketamina",
    "minDose": 5.0,
    "maxDose": 10.0,
    "unit": "mg/kg",
    "species": ["Canino", "Felino"],
    "category": "Anestésico Dissociativo",
    "indications": "Indução anestésica, procedimentos curtos",
    "contraindications": "Hipertensão, insuficiência cardíaca",
    "precautions": "Pode causar salivação excessiva",
    "description": "Anestésico dissociativo com propriedades analgésicas"
  },
  {
    "id": "propofol",
    "name": "Propofol",
    ...
  }
]
```

## 🔐 Considerações de Segurança

1. **Autenticação**: Adicione tokens JWT ou API keys nos headers
2. **HTTPS**: Use sempre conexões seguras
3. **Cache**: Considere implementar cache local (Hive, SQLite)
4. **Tratamento de Erros**: Implemente retry logic e fallbacks
5. **Timeout**: Configure timeouts apropriados

## 💾 Cache Local (Opcional)

Para melhorar a performance e permitir uso offline:

```dart
import 'package:hive/hive.dart';

static Future<void> saveMedicationsToCache() async {
  final box = await Hive.openBox('medications');
  await box.put('data', _medications.map((m) => m.toJson()).toList());
  await box.put('lastUpdate', DateTime.now().toIso8601String());
}

static Future<void> loadMedicationsFromCache() async {
  final box = await Hive.openBox('medications');
  final data = box.get('data') as List?;
  if (data != null) {
    setMedications(
      data.map((json) => Medication.fromJson(json)).toList()
    );
  }
}
```

## 🎯 Fluxo Recomendado

1. **App Inicia** → Tenta carregar do cache local
2. **Cache Existe?** → Mostra dados em cache
3. **Em Background** → Busca dados atualizados do back-end
4. **Dados Novos?** → Atualiza UI e cache
5. **Sem Conexão?** → Continua com cache (modo offline)

## 🧪 Testando com Dados Mockados (Temporário)

Durante o desenvolvimento, você pode adicionar dados temporários:

```dart
void initState() {
  super.initState();
  
  // TEMPORÁRIO: Adicionar dados de teste
  if (MedicationService.getAllMedications().isEmpty) {
    MedicationService.addMedication(
      Medication(
        id: 'test',
        name: 'Medicamento Teste',
        minDose: 1.0,
        maxDose: 2.0,
        unit: 'mg/kg',
        species: ['Canino'],
        category: 'Teste',
      ),
    );
  }
  
  _medications = MedicationService.getAllMedications();
  _filteredMedications = _medications;
}
```

## 📝 Checklist de Integração

- [ ] Adicionar dependência `http` no pubspec.yaml
- [ ] Implementar método `loadMedicationsFromBackend()`
- [ ] Configurar URL da API e autenticação
- [ ] Adicionar loading state na UI
- [ ] Implementar tratamento de erros
- [ ] Testar conexão com back-end
- [ ] Implementar cache local (opcional)
- [ ] Configurar refresh manual/automático
- [ ] Testar modo offline
- [ ] Adicionar testes unitários

## 🆘 Troubleshooting

**Erro de CORS (Web)**:
- Configure CORS no back-end para permitir requisições do domínio do Flutter Web

**Certificado SSL inválido**:
- Use certificados válidos em produção
- Para testes: `dart:io` permite bypasses (não recomendado)

**Lista vazia após carregar**:
- Verifique se o JSON está no formato correto
- Adicione logs para debug: `print(response.body)`
- Verifique se `fromJson()` está correto no modelo

**Performance lenta**:
- Implemente paginação no back-end
- Use cache local
- Carregue dados em background

---

**Data**: 31 de Outubro de 2025  
**Status**: ✅ Pronto para integração com back-end
