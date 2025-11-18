import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/theme_provider.dart';
import '../../services/auth_service.dart';

/// Página de Perfil do Usuário
/// Estrutura básica expansível para futuras funcionalidades
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = Provider.of<AuthService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header com foto e informações básicas
              _buildHeader(context, authService),
              
              const SizedBox(height: 24),
              
              // Seção de Configurações
              _buildSection(
                context,
                title: 'Configurações',
                children: [
                  _buildThemeToggle(context, themeProvider),
                  _buildDivider(),
                  _buildNotificationToggle(context),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Seção de Conta
              _buildSection(
                context,
                title: 'Conta',
                children: [
                  _buildPreferenceItem(
                    context,
                    icon: Icons.person_outline,
                    title: 'Alterar Nome',
                    subtitle: authService.currentUser?.email.split('@').first ?? 'Usuário',
                    onTap: () => _showEditNameDialog(context, authService),
                  ),
                  _buildDivider(),
                  _buildPreferenceItem(
                    context,
                    icon: Icons.email_outlined,
                    title: 'Alterar Email',
                    subtitle: authService.currentUser?.email ?? 'email@exemplo.com',
                    onTap: () => _showEditEmailDialog(context, authService),
                  ),
                  _buildDivider(),
                  _buildPreferenceItem(
                    context,
                    icon: Icons.lock_outline,
                    title: 'Alterar Senha',
                    subtitle: '••••••••',
                    onTap: () => _showEditPasswordDialog(context, authService),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Seção de Informações
              _buildSection(
                context,
                title: 'Sobre',
                children: [
                  _buildInfoItem(
                    context,
                    icon: Icons.info_outline,
                    title: 'Versão do App',
                    subtitle: '1.0.0',
                  ),
                  _buildDivider(),
                  _buildInfoItem(
                    context,
                    icon: Icons.description_outlined,
                    title: 'Termos de Uso',
                    subtitle: 'Políticas e privacidade',
                    onTap: () {
                      // TODO: Implementar tela de termos
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Botão de Logout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _handleLogout(context, authService),
                    icon: const Icon(Icons.logout),
                    label: const Text('Sair'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthService authService) {
    final theme = Theme.of(context);
    final user = authService.currentUser;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryTeal,
            AppColors.primaryTeal.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Logo GDVet como foto de perfil
          Container(
            width: 100,
            height: 100,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/gdav_logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback para ícone se a imagem não carregar
                  return Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.primaryTeal,
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Nome do usuário (usando email como fallback)
          Text(
            user?.email.split('@').first.toUpperCase() ?? 'Usuário',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Email
          Text(
            user?.email ?? 'email@exemplo.com',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Role (Admin/User)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user?.role == 'admin' ? 'Administrador' : 'Usuário',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryTeal,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, ThemeProvider themeProvider) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Icon(
        themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: AppColors.primaryTeal,
      ),
      title: Text(
        'Tema Escuro',
        style: theme.textTheme.bodyLarge,
      ),
      trailing: Switch(
        value: themeProvider.isDarkMode,
        onChanged: (value) {
          themeProvider.toggleTheme(value);
        },
        activeColor: AppColors.primaryTeal,
      ),
    );
  }

  Widget _buildNotificationToggle(BuildContext context) {
    final theme = Theme.of(context);
    // TODO: Implementar estado de notificações
    bool notificationsEnabled = true;
    
    return ListTile(
      leading: const Icon(
        Icons.notifications_outlined,
        color: AppColors.primaryTeal,
      ),
      title: Text(
        'Notificações',
        style: theme.textTheme.bodyLarge,
      ),
      trailing: Switch(
        value: notificationsEnabled,
        onChanged: (value) {
          // TODO: Implementar toggle de notificações
        },
        activeColor: AppColors.primaryTeal,
      ),
    );
  }

  Widget _buildPreferenceItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryTeal),
      title: Text(title, style: theme.textTheme.bodyLarge),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryTeal),
      title: Text(title, style: theme.textTheme.bodyLarge),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
        ),
      ),
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 56,
    );
  }

  Future<void> _handleLogout(BuildContext context, AuthService authService) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await authService.logout();
    }
  }

  Future<void> _showEditNameDialog(BuildContext context, AuthService authService) async {
    final TextEditingController controller = TextEditingController(
      text: authService.currentUser?.email.split('@').first ?? '',
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Nome'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nome',
            hintText: 'Digite seu nome',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      // TODO: Implementar atualização de nome no backend
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Funcionalidade de alteração de nome será implementada em breve'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  Future<void> _showEditEmailDialog(BuildContext context, AuthService authService) async {
    final TextEditingController controller = TextEditingController(
      text: authService.currentUser?.email ?? '',
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Email'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'Digite seu email',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      // TODO: Implementar atualização de email no backend
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Funcionalidade de alteração de email será implementada em breve'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  Future<void> _showEditPasswordDialog(BuildContext context, AuthService authService) async {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Senha'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Senha Atual',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'Nova Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirmar Nova Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (newPasswordController.text == confirmPasswordController.text) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('As senhas não coincidem'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Alterar'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      // TODO: Implementar atualização de senha no backend
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Funcionalidade de alteração de senha será implementada em breve'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }
}
