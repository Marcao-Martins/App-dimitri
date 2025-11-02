// lib/features/consent_form/consent_form_page.dart
// Página principal do formulário de consentimento anestésico

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'consent_form_controller.dart';
import 'widgets/doctor_section.dart';
import 'widgets/animal_section.dart';
import 'widgets/owner_section.dart';
import 'widgets/procedure_section.dart';
import 'pdf/pdf_generator.dart';

class ConsentFormPage extends StatefulWidget {
  const ConsentFormPage({super.key});

  @override
  State<ConsentFormPage> createState() => _ConsentFormPageState();
}

class _ConsentFormPageState extends State<ConsentFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConsentFormController(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Termo de Consentimento'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showClearDialog(context),
              tooltip: 'Limpar formulário',
            ),
          ],
        ),
        body: Consumer<ConsentFormController>(
          builder: (context, controller, _) {
            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Seção do Médico
                  DoctorSection(
                    nameController: controller.veterinarianNameController,
                    crmvController: controller.crmvController,
                    clinicController: controller.clinicController,
                  ),
                  const SizedBox(height: 16),

                  // Seção do Animal
                  AnimalSection(
                    nameController: controller.patientNameController,
                    selectedSpecies: controller.selectedSpecies,
                    onSpeciesChanged: (value) {
                      if (value != null) controller.setSpecies(value);
                    },
                    breedController: controller.breedController,
                    selectedSex: controller.selectedSex,
                    onSexChanged: (value) {
                      if (value != null) controller.setSex(value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Seção do Responsável
                  OwnerSection(
                    nameController: controller.ownerNameController,
                    cpfController: controller.cpfController,
                    phoneController: controller.phoneController,
                    addressController: controller.addressController,
                  ),
                  const SizedBox(height: 16),

                  // Seção do Procedimento
                  ProcedureSection(
                    procedureController: controller.procedureController,
                    additionalInfoController:
                        controller.additionalInfoController,
                    cityController: controller.cityController,
                    selectedDate: controller.selectedDate,
                    onDateChanged: controller.setDate,
                  ),
                  const SizedBox(height: 16),

                  // Observações
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.note_add,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Observações Adicionais',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: controller.observationsController,
                            decoration: const InputDecoration(
                              labelText: 'Observações (opcional)',
                              hintText:
                                  'Informações adicionais relevantes...',
                              prefixIcon: Icon(Icons.notes),
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 4,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botões de ação
                  _buildActionButtons(context, controller),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, ConsentFormController controller) {
    return Column(
      children: [
        // Botão Preview
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isGenerating
                ? null
                : () => _handlePreview(context, controller),
            icon: const Icon(Icons.preview),
            label: const Text('Visualizar Termo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Botão Gerar PDF
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed:
                _isGenerating ? null : () => _handleGenerate(context, controller),
            icon: _isGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.picture_as_pdf),
            label: Text(_isGenerating ? 'Gerando...' : 'Gerar PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handlePreview(
      BuildContext context, ConsentFormController controller) async {
    if (!_formKey.currentState!.validate()) {
      _showValidationError(context, controller);
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final data = controller.getData();
      await PdfGenerator.preview(data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao visualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _handleGenerate(
      BuildContext context, ConsentFormController controller) async {
    if (!_formKey.currentState!.validate()) {
      _showValidationError(context, controller);
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final data = controller.getData();
      
      // Mostra opções de ação
      final action = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Gerar PDF'),
          content: const Text('Escolha uma ação:'),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context, 'save'),
              icon: const Icon(Icons.save),
              label: const Text('Salvar'),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pop(context, 'share'),
              icon: const Icon(Icons.share),
              label: const Text('Compartilhar'),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pop(context, 'print'),
              icon: const Icon(Icons.print),
              label: const Text('Imprimir'),
            ),
          ],
        ),
      );

      if (action == null || !mounted) return;

      switch (action) {
        case 'save':
          final path = await PdfGenerator.save(data);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  path != null
                      ? 'PDF salvo em: $path'
                      : 'Erro ao salvar PDF',
                ),
                backgroundColor: path != null ? Colors.green : Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
          break;
        case 'share':
          await PdfGenerator.share(data);
          break;
        case 'print':
          await PdfGenerator.printPdf(data);
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _showValidationError(
      BuildContext context, ConsentFormController controller) {
    final invalidFields = controller.getInvalidFields();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Campos Obrigatórios'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Por favor, preencha os seguintes campos:'),
            const SizedBox(height: 12),
            ...invalidFields.map((field) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                  child: Text('• $field'),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Formulário'),
        content:
            const Text('Tem certeza que deseja limpar todos os campos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<ConsentFormController>().clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Formulário limpo'),
                ),
              );
            },
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }
}
