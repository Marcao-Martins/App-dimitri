// lib/features/consent_form/models/consent_data.dart
// Modelo de dados para o Termo de Consentimento Livre e Esclarecido

class ConsentData {
  // Dados do Médico Veterinário
  final String veterinarianName;
  final String crmv;
  final String clinic;

  // Dados do Animal
  final String patientName;
  final String species; // "Cão" ou "Gato"
  final String breed;
  final String sex; // "Macho" ou "Fêmea"

  // Dados do Responsável
  final String ownerName;
  final String cpf;
  final String phone;
  final String address;

  // Dados do Procedimento
  final String procedureType;
  final String additionalInfo;
  final String city;
  final DateTime date;

  // Observações adicionais
  final String observations;

  ConsentData({
    required this.veterinarianName,
    required this.crmv,
    required this.clinic,
    required this.patientName,
    required this.species,
    required this.breed,
    required this.sex,
    required this.ownerName,
    required this.cpf,
    required this.phone,
    required this.address,
    required this.procedureType,
    required this.additionalInfo,
    required this.city,
    required this.date,
    this.observations = '',
  });

  // Cria uma cópia com campos modificados
  ConsentData copyWith({
    String? veterinarianName,
    String? crmv,
    String? clinic,
    String? patientName,
    String? species,
    String? breed,
    String? sex,
    String? ownerName,
    String? cpf,
    String? phone,
    String? address,
    String? procedureType,
    String? additionalInfo,
    String? city,
    DateTime? date,
    String? observations,
  }) {
    return ConsentData(
      veterinarianName: veterinarianName ?? this.veterinarianName,
      crmv: crmv ?? this.crmv,
      clinic: clinic ?? this.clinic,
      patientName: patientName ?? this.patientName,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      sex: sex ?? this.sex,
      ownerName: ownerName ?? this.ownerName,
      cpf: cpf ?? this.cpf,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      procedureType: procedureType ?? this.procedureType,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      city: city ?? this.city,
      date: date ?? this.date,
      observations: observations ?? this.observations,
    );
  }

  // Serialização JSON para persistência
  Map<String, dynamic> toJson() {
    return {
      'veterinarianName': veterinarianName,
      'crmv': crmv,
      'clinic': clinic,
      'patientName': patientName,
      'species': species,
      'breed': breed,
      'sex': sex,
      'ownerName': ownerName,
      'cpf': cpf,
      'phone': phone,
      'address': address,
      'procedureType': procedureType,
      'additionalInfo': additionalInfo,
      'city': city,
      'date': date.toIso8601String(),
      'observations': observations,
    };
  }

  // Desserialização JSON
  factory ConsentData.fromJson(Map<String, dynamic> json) {
    return ConsentData(
      veterinarianName: json['veterinarianName'] as String,
      crmv: json['crmv'] as String,
      clinic: json['clinic'] as String,
      patientName: json['patientName'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String,
      sex: json['sex'] as String,
      ownerName: json['ownerName'] as String,
      cpf: json['cpf'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      procedureType: json['procedureType'] as String,
      additionalInfo: json['additionalInfo'] as String,
      city: json['city'] as String,
      date: DateTime.parse(json['date'] as String),
      observations: json['observations'] as String? ?? '',
    );
  }

  // Instância vazia para inicialização do formulário
  factory ConsentData.empty() {
    return ConsentData(
      veterinarianName: '',
      crmv: '',
      clinic: '',
      patientName: '',
      species: 'Cão',
      breed: '',
      sex: 'Macho',
      ownerName: '',
      cpf: '',
      phone: '',
      address: '',
      procedureType: '',
      additionalInfo: '',
      city: '',
      date: DateTime.now(),
    );
  }

  // Validação de campos obrigatórios
  bool isValid() {
    return veterinarianName.isNotEmpty &&
        crmv.isNotEmpty &&
        clinic.isNotEmpty &&
        patientName.isNotEmpty &&
        species.isNotEmpty &&
        breed.isNotEmpty &&
        sex.isNotEmpty &&
        ownerName.isNotEmpty &&
        cpf.isNotEmpty &&
        phone.isNotEmpty &&
        address.isNotEmpty &&
        procedureType.isNotEmpty &&
        city.isNotEmpty;
  }

  // Lista de campos inválidos para mensagens de erro
  List<String> getInvalidFields() {
    final List<String> invalid = [];
    if (veterinarianName.isEmpty) invalid.add('Nome do veterinário');
    if (crmv.isEmpty) invalid.add('CRMV');
    if (clinic.isEmpty) invalid.add('Clínica/Hospital');
    if (patientName.isEmpty) invalid.add('Nome do paciente');
    if (breed.isEmpty) invalid.add('Raça');
    if (ownerName.isEmpty) invalid.add('Nome do responsável');
    if (cpf.isEmpty) invalid.add('CPF');
    if (phone.isEmpty) invalid.add('Telefone');
    if (address.isEmpty) invalid.add('Endereço');
    if (procedureType.isEmpty) invalid.add('Tipo de anestesia/procedimento');
    if (city.isEmpty) invalid.add('Cidade');
    return invalid;
  }
}
