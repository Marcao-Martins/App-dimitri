import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/custom_card.dart';

/// Página para adicionar novo parâmetro veterinário
class AddParameterPage extends StatefulWidget {
  const AddParameterPage({super.key});

  @override
  State<AddParameterPage> createState() => _AddParameterPageState();
}

class _AddParameterPageState extends State<AddParameterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _showPreview = false;
  
  // Controladores dos campos
  final _nomeController = TextEditingController();
  final _caoController = TextEditingController();
  final _gatoController = TextEditingController();
  final _cavaloController = TextEditingController();
  final _comentariosController = TextEditingController();
  final _referenciasController = TextEditingController();
  
  @override
  void dispose() {
    _nomeController.dispose();
    _caoController.dispose();
    _gatoController.dispose();
    _cavaloController.dispose();
    _comentariosController.dispose();
    _referenciasController.dispose();
    super.dispose();
  }
  
  Future<void> _createParameter() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      // TODO: Implementar criação via API quando disponível
      // Por enquanto, apenas mostrar sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Funcionalidade de adição será implementada em breve'),
          backgroundColor: AppColors.warning,
        ),
      );
      
      if (mounted) {
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
        title: const Text('Adicionar Parâmetro'),
        actions: [
          if (!_isLoading)
            TextButton.icon(
              onPressed: () => setState(() => _showPreview = !_showPreview),
              icon: Icon(_showPreview ? Icons.edit : Icons.preview),
              label: Text(_showPreview ? 'Editar' : 'Preview'),
            ),
        ],
      ),
      body: _showPreview ? _buildPreview(context) : _buildForm(context),
      floatingActionButton: !_showPreview
          ? FloatingActionButton(
              onPressed: _isLoading ? null : _createParameter,
              tooltip: 'Criar Parâmetro',
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
            )
          : null,
    );
  }
  
  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          // Nome do Parâmetro
          _SectionHeader(
            icon: Icons.info_outline,
            title: 'Nome do Parâmetro',
            color: AppColors.primaryTeal,
          ),
          
          _buildTextField(
            controller: _nomeController,
            label: 'Nome *',
            hint: 'Nome do parâmetro veterinário',
            icon: Icons.monitor_heart,
            required: true,
          ),
          
          const SizedBox(height: AppConstants.defaultPadding * 2),
          
          // Valores por Espécie
          _SectionHeader(
            icon: Icons.pets,
            title: 'Valores por Espécie',
            color: AppColors.categoryOrange,
          ),
          
          _buildTextField(
            controller: _caoController,
            label: 'Valores - Cão *',
            hint: 'Intervalo normal para cães',
            icon: Icons.pets,
            maxLines: 3,
            required: true,
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          _buildTextField(
            controller: _gatoController,
            label: 'Valores - Gato',
            hint: 'Intervalo normal para gatos',
            icon: Icons.pets,
            maxLines: 3,
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          _buildTextField(
            controller: _cavaloController,
            label: 'Valores - Cavalo',
            hint: 'Intervalo normal para cavalos',
            icon: Icons.pets,
            maxLines: 3,
          ),
          
          const SizedBox(height: AppConstants.defaultPadding * 2),
          
          // Informações Adicionais
          _SectionHeader(
            icon: Icons.comment,
            title: 'Informações Adicionais',
            color: AppColors.warning,
          ),
          
          _buildTextField(
            controller: _comentariosController,
            label: 'Comentários',
            hint: 'Observações clínicas e considerações',
            icon: Icons.comment_outlined,
            maxLines: 5,
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          _buildTextField(
            controller: _referenciasController,
            label: 'Referências',
            hint: 'Fontes bibliográficas',
            icon: Icons.source_outlined,
            maxLines: 5,
          ),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }
  
  Widget _buildPreview(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PreviewSection(
            _nomeController.text,
            '${_caoController.text}\n${_gatoController.text}\n${_cavaloController.text}',
          ),
          
          if (_comentariosController.text.isNotEmpty)
            _PreviewSection('Comentários', _comentariosController.text),
          
          if (_referenciasController.text.isNotEmpty)
            _PreviewSection('Referências', _referenciasController.text),
        ],
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) {
        if (required && (value?.isEmpty ?? true)) {
          return 'Campo obrigatório';
        }
        return null;
      },
    );
  }
}

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
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewSection extends StatelessWidget {
  final String title;
  final String content;
  
  const _PreviewSection(this.title, this.content);
  
  @override
  Widget build(BuildContext context) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
