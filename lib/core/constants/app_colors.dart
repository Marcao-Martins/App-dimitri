import 'package:flutter/material.dart';

/// Cores padrão do aplicativo VetAnesthesia Helper
/// Design System moderno e minimalista para profissionais veterinários
class AppColors {
  // ============================================================================
  // COR PRINCIPAL DE ACENTO - Verde-azulado profissional (Teal)
  // ============================================================================
  static const Color primaryTeal = Color(0xFF00ACC1); // Teal brilhante
  static const Color primaryTealDark = Color(0xFF00838F); // Teal escuro
  static const Color primaryTealLight = Color(0xFF4DD0E1); // Teal claro
  
  // ============================================================================
  // CORES CATEGORIAIS - Para ícones de biblioteca e categorias
  // ============================================================================
  static const Color categoryOrange = Color(0xFFFF9800); // Laranja
  static const Color categoryBlue = Color(0xFF2196F3); // Azul
  static const Color categoryPurple = Color(0xFF9C27B0); // Roxo
  static const Color categoryGreen = Color(0xFF4CAF50); // Verde escuro
  static const Color categoryPink = Color(0xFFE91E63); // Rosa
  static const Color categoryIndigo = Color(0xFF3F51B5); // Índigo
  
  // ============================================================================
  // CORES DE STATUS - Para alertas e validações
  // ============================================================================
  static const Color success = Color(0xFF4CAF50); // Verde
  static const Color warning = Color(0xFFFF9800); // Laranja
  static const Color error = Color(0xFFF44336); // Vermelho
  static const Color info = Color(0xFF00ACC1); // Teal
  
  // ============================================================================
  // CORES DE FUNDO - Branco predominante com alto contraste
  // ============================================================================
  static const Color backgroundPrimary = Color(0xFFFFFFFF); // Branco puro
  static const Color backgroundSecondary = Color(0xFFFAFAFA); // Branco levemente off
  static const Color backgroundDark = Color(0xFF121212); // Escuro para modo noturno
  
  // ============================================================================
  // CORES DE SUPERFÍCIE - Para cards e componentes elevados
  // ============================================================================
  static const Color surfaceWhite = Color(0xFFFFFFFF); // Branco puro
  static const Color surfaceGrey = Color(0xFFF5F5F5); // Cinza muito claro
  static const Color surfaceDark = Color(0xFF1E1E1E); // Escuro para modo noturno
  
  // ============================================================================
  // CORES DE TEXTO - Hierarquia clara de informação
  // ============================================================================
  static const Color textPrimary = Color(0xFF212121); // Cinza escuro/preto
  static const Color textSecondary = Color(0xFF757575); // Cinza médio
  static const Color textTertiary = Color(0xFF9E9E9E); // Cinza claro
  static const Color textOnPrimary = Color(0xFFFFFFFF); // Branco (sobre teal)
  static const Color textOnDark = Color(0xFFFFFFFF); // Branco (modo escuro)
  
  // ============================================================================
  // CORES DE FILTROS E CHIPS - Para componentes de seleção
  // ============================================================================
  static const Color chipActive = Color(0xFF212121); // Cinza escuro/preto
  static const Color chipInactive = Color(0xFFE0E0E0); // Cinza claro
  static const Color chipActiveText = Color(0xFFFFFFFF); // Branco
  static const Color chipInactiveText = Color(0xFF757575); // Cinza médio
  
  // ============================================================================
  // CORES DE NAVEGAÇÃO - Para Bottom Navigation Bar
  // ============================================================================
  static const Color navActive = Color(0xFF00ACC1); // Teal (aba ativa)
  static const Color navInactive = Color(0xFF9E9E9E); // Cinza (aba inativa)
  static const Color navBackground = Color(0xFFFFFFFF); // Branco
  
  // ============================================================================
  // CORES FUNCIONAIS - Bordas, divisores e sombras
  // ============================================================================
  static const Color border = Color(0xFFE0E0E0); // Cinza claro
  static const Color divider = Color(0xFFEEEEEE); // Cinza muito claro
  static const Color disabled = Color(0xFFBDBDBD); // Cinza médio
  static const Color shadow = Color(0x1A000000); // Sombra sutil (10% opacidade)
  static const Color overlay = Color(0x14000000); // Overlay (8% opacidade)
  
  // ============================================================================
  // CORES DE TAGS/ETIQUETAS - Para classificação de medicamentos
  // ============================================================================
  static const Color tagVet = Color(0xFF00ACC1); // Teal - Uso veterinário
  static const Color tagHuman = Color(0xFF2196F3); // Azul - Uso humano
  static const Color tagPA = Color(0xFF9C27B0); // Roxo - Princípio Ativo
  static const Color tagControlled = Color(0xFFFF9800); // Laranja - Controlado
  
  // ============================================================================
  // CORES ANTIGAS (Mantidas para compatibilidade - será removido gradualmente)
  // ============================================================================
  @Deprecated('Use primaryTeal instead')
  static const Color primaryBlue = Color(0xFF2196F3);
  @Deprecated('Use primaryTealDark instead')
  static const Color primaryDark = Color(0xFF1976D2);
  @Deprecated('Use primaryTealLight instead')
  static const Color primaryLight = Color(0xFF64B5F6);
  @Deprecated('Use primaryTeal instead')
  static const Color accentTeal = Color(0xFF009688);
  @Deprecated('Use categoryGreen instead')
  static const Color accentGreen = Color(0xFF4CAF50);
}
