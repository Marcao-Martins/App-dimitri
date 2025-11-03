import 'package:flutter/material.dart';
import '../../services/admin_medication_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// Página para adicionar novo medicamento
class AddMedicationPage extends StatefulWidget {
  const AddMedicationPage({super.key});

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // Controladores dos campos
  final _tituloController = TextEditingController();
  final _farmacoController = TextEditingController();
  final _classeController = TextEditingController();
  final _nomeComercialController = TextEditingController();
  final _mecanismoController = TextEditingController();
  final _posologiaCaesController = TextEditingController();
  final _posologiaGatosController = TextEditingController();
  final _ivcController = TextEditingController();
  final _comentariosController = TextEditingController();
  final _referenciaController = TextEditingController();
  final _linkController = TextEditingController();
  
  @override
  void dispose() {
    _tituloController.dispose();
    _farmacoController.dispose();
    _classeController.dispose();
    _nomeComercialController.dispose();
    _mecanismoController.dispose();
    _posologiaCaesController.dispose();
    _posologiaGatosController.dispose();
    _ivcController.dispose();
    _comentariosController.dispose();
    _referenciaController.dispose();
    _linkController.dispose();
    super.dispose();
  }
  
  Future<void> _createMedication() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final data = {
        'titulo': _tituloController.text,
        'farmaco': _farmacoController.text,
        'classe_farmacologica': _classeController.text,
        'nome_comercial': _nomeComercialController.text,
        'mecanismo_de_acao': _mecanismoController.text,
        'posologia_caes': _posologiaCaesController.text,
        'posologia_gatos': _posologiaGatosController.text,
        'ivc': _ivcController.text,
        'comentarios': _comentariosController.text,
        'referencia': _referenciaController.text,
        'link': _linkController.text,
      };
      
      await AdminMedicationService.createMedication(data);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medicamento criado com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Medicamento'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
            // Informações Básicas
            _SectionHeader(
              icon: Icons.info_outline,
              title: 'Informações Básicas',
              color: AppColors.primaryTeal,
            ),
            
            _buildTextField(
              controller: _tituloController,
              label: 'Título *',
              hint: 'Título descritivo do medicamento',
              icon: Icons.title,
              required: true,
            ),
            
            _buildTextField(
              controller: _farmacoController,
              label: 'Fármaco *',
              hint: 'Nome do princípio ativo',
              icon: Icons.medication,
              required: true,
            ),
            
            _buildTextField(
              controller: _classeController,
              label: 'Classe Farmacológica *',
              hint: 'Ex: Analgésico, Antibiótico, etc.',
              icon: Icons.category,
              required: true,
            ),
            
            _buildTextField(
              controller: _nomeComercialController,
              label: 'Nome Comercial',
              hint: 'Nome(s) comercial(is)',
              icon: Icons.shopping_bag,
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // Mecanismo de Ação
            _SectionHeader(
              icon: Icons.science,
              title: 'Mecanismo de Ação',
              color: AppColors.info,
            ),
            
            _buildTextField(
              controller: _mecanismoController,
              label: 'Mecanismo de Ação',
              hint: 'Como o medicamento atua no organismo',
              icon: Icons.science_outlined,
              maxLines: 4,
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // Posologia
            _SectionHeader(
              icon: Icons.pets,
              title: 'Posologia',
              color: AppColors.categoryOrange,
            ),
            
            _buildTextField(
              controller: _posologiaCaesController,
              label: 'Posologia em Cães',
              hint: 'Dose, via e frequência para cães',
              icon: Icons.pets,
              maxLines: 3,
            ),
            
            _buildTextField(
              controller: _posologiaGatosController,
              label: 'Posologia em Gatos',
              hint: 'Dose, via e frequência para gatos',
              icon: Icons.pets,
              maxLines: 3,
            ),
            
            _buildTextField(
              controller: _ivcController,
              label: 'Infusão Venosa Contínua (IVC)',
              hint: 'Protocolos de IVC',
              icon: Icons.water_drop,
              maxLines: 3,
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // Informações Adicionais
            _SectionHeader(
              icon: Icons.comment,
              title: 'Informações Adicionais',
              color: AppColors.warning,
            ),
            
            _buildTextField(
              controller: _comentariosController,
              label: 'Comentários',
              hint: 'Observações, precauções, etc.',
              icon: Icons.comment_outlined,
              maxLines: 5,
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // Referências
            _SectionHeader(
              icon: Icons.library_books,
              title: 'Referências',
              color: AppColors.categoryPurple,
            ),
            
            _buildTextField(
              controller: _referenciaController,
              label: 'Referência Bibliográfica',
              hint: 'Fonte das informações',
              icon: Icons.library_books_outlined,
              maxLines: 3,
            ),
            
            _buildTextField(
              controller: _linkController,
              label: 'Link',
              hint: 'URL para mais informações',
              icon: Icons.link,
              keyboardType: TextInputType.url,
            ),
            
            const SizedBox(height: 80), // Espaço para o botão fixo
          ],
        ),
      ),
      bottomNavigationBar: _isLoading
          ? const LinearProgressIndicator()
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: AppConstants.defaultPadding),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: _createMedication,
                        icon: const Icon(Icons.add),
                        label: const Text('Criar Medicamento'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: required
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              }
            : null,
      ),
    );
  }
}

/// Header de seção
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
