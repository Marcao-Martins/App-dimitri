// lib/features/consent_form/consent_form_controller.dart
// Controller para gerenciar estado e lógica do formulário de consentimento

import 'package:flutter/material.dart';
import 'models/consent_data.dart';

class ConsentFormController extends ChangeNotifier {
  // Controllers de texto
  final veterinarianNameController = TextEditingController();
  final crmvController = TextEditingController();
  final clinicController = TextEditingController();
  
  final patientNameController = TextEditingController();
  final breedController = TextEditingController();
  
  final ownerNameController = TextEditingController();
  final cpfController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  
  final procedureController = TextEditingController();
  final additionalInfoController = TextEditingController();
  final cityController = TextEditingController();
  final observationsController = TextEditingController();

  // Estados de seleção
  String _selectedSpecies = 'Cão';
  String _selectedSex = 'Macho';
  DateTime _selectedDate = DateTime.now();

  String get selectedSpecies => _selectedSpecies;
  String get selectedSex => _selectedSex;
  DateTime get selectedDate => _selectedDate;

  void setSpecies(String species) {
    _selectedSpecies = species;
    notifyListeners();
  }

  void setSex(String sex) {
    _selectedSex = sex;
    notifyListeners();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Cria objeto ConsentData com os dados atuais
  ConsentData getData() {
    return ConsentData(
      veterinarianName: veterinarianNameController.text,
      crmv: crmvController.text,
      clinic: clinicController.text,
      patientName: patientNameController.text,
      species: _selectedSpecies,
      breed: breedController.text,
      sex: _selectedSex,
      ownerName: ownerNameController.text,
      cpf: cpfController.text,
      phone: phoneController.text,
      address: addressController.text,
      procedureType: procedureController.text,
      additionalInfo: additionalInfoController.text,
      city: cityController.text,
      date: _selectedDate,
      observations: observationsController.text,
    );
  }

  // Carrega dados no formulário
  void loadData(ConsentData data) {
    veterinarianNameController.text = data.veterinarianName;
    crmvController.text = data.crmv;
    clinicController.text = data.clinic;
    patientNameController.text = data.patientName;
    _selectedSpecies = data.species;
    breedController.text = data.breed;
    _selectedSex = data.sex;
    ownerNameController.text = data.ownerName;
    cpfController.text = data.cpf;
    phoneController.text = data.phone;
    addressController.text = data.address;
    procedureController.text = data.procedureType;
    additionalInfoController.text = data.additionalInfo;
    cityController.text = data.city;
    _selectedDate = data.date;
    observationsController.text = data.observations;
    notifyListeners();
  }

  // Limpa todos os campos
  void clear() {
    veterinarianNameController.clear();
    crmvController.clear();
    clinicController.clear();
    patientNameController.clear();
    breedController.clear();
    ownerNameController.clear();
    cpfController.clear();
    phoneController.clear();
    addressController.clear();
    procedureController.clear();
    additionalInfoController.clear();
    cityController.clear();
    observationsController.clear();
    _selectedSpecies = 'Cão';
    _selectedSex = 'Macho';
    _selectedDate = DateTime.now();
    notifyListeners();
  }

  // Valida se todos os campos obrigatórios estão preenchidos
  bool validate() {
    return getData().isValid();
  }

  // Retorna lista de campos inválidos
  List<String> getInvalidFields() {
    return getData().getInvalidFields();
  }

  @override
  void dispose() {
    veterinarianNameController.dispose();
    crmvController.dispose();
    clinicController.dispose();
    patientNameController.dispose();
    breedController.dispose();
    ownerNameController.dispose();
    cpfController.dispose();
    phoneController.dispose();
    addressController.dispose();
    procedureController.dispose();
    additionalInfoController.dispose();
    cityController.dispose();
    observationsController.dispose();
    super.dispose();
  }
}
