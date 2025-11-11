# 📸 Imagens do App GDAV - Guia de Configuração

## Imagens Disponíveis

### 1. **Logo GDAV** (`gdav_logo.png`)
A imagem da logo do **GDAV** (Grupo de Desenvolvimento em Anestesiologia Veterinária) com:
- Texto "GDAV" em destaque
- Subtítulo: "grupo de desenvolvimento em anestesiologia veterinária"
- Design limpo e profissional em tons de cinza e laranja

### 2. **Banner LBW VET** (`banner_lbwvet.png`)
Banner promocional com link para o site LBW VET:
- Texto: "A medicina veterinária mudou..."
- Design profissional com foto e texto explicativo
- Clicável, redireciona para: https://lbwvet.com/

## Como Salvar as Imagens

### Logo GDAV

#### Opção 1: Salvar Manualmente
1. Salve a imagem GDAV que você forneceu
2. Renomeie para `gdav_logo.png`
3. Copie para: `assets/images/gdav_logo.png`

#### Opção 2: Usar o Script PowerShell
```powershell
.\save-logo.ps1 -ImagePath "C:\caminho\para\sua\imagem.png"
```

### Banner LBW VET

#### Opção 1: Salvar Manualmente
1. Salve a imagem do banner LBW VET
2. Renomeie para `banner_lbwvet.png`
3. Copie para: `assets/images/banner_lbwvet.png`

#### Opção 2: Usar o Script PowerShell
```powershell
.\save-banner.ps1 -ImagePath "C:\caminho\para\banner.png"
```

## Onde as Imagens são Usadas

### Logo GDAV

1. **Tela de Login** (`login_page.dart`)
   - Exibida no topo da tela
   - Tamanho: 200x200 pixels
   - Centralizada acima do formulário de login
   - Fallback: ícone `Icons.medical_services_outlined` se a imagem não carregar

2. **Página de Perfil** (`profile_page.dart`)
   - Exibida no header do perfil
   - Tamanho: 100x100 pixels (circular)
   - Substitui o ícone de pessoa padrão
   - Fallback: ícone `Icons.person` se a imagem não carregar

### Banner LBW VET

1. **Mural da Página Principal** (`explorer_page.dart`)
   - Exibido na seção "Mural"
   - Banner clicável com efeito visual
   - Abre https://lbwvet.com/ ao clicar
   - Fallback: Card com texto e ícone se a imagem não carregar
   - BorderRadius: 20px para design moderno
   - Shadow e InkWell para feedback visual

## Especificações Técnicas

### Logo GDAV
- **Formato**: PNG (com transparência)
- **Resolução**: Mínimo 400x400 pixels para boa qualidade
- **Proporção**: Quadrada (1:1) ou retangular mantendo legibilidade
- **Tamanho**: Até 500KB para performance otimizada

### Banner LBW VET
- **Formato**: PNG ou JPG
- **Resolução**: Mínimo 800x300 pixels (proporção ~2.67:1)
- **Proporção**: Retangular (recomendado: 16:6 ou similar)
- **Tamanho**: Até 1MB
- **Conteúdo**: Banner com foto, título e descrição

### Alternativas Aceitas
- JPG/JPEG (fundo branco)
- WebP (melhor compressão)

## Arquivos Modificados

1. ✅ **pubspec.yaml**
   - Adicionado `assets/images/` à lista de assets
   - Adicionado `url_launcher: ^6.2.5` para abrir links

2. ✅ **login_page.dart**
   - Substituído `Icon` por `Image.asset`
   - Adicionado `errorBuilder` para fallback

3. ✅ **profile_page.dart**
   - Substituído `Icon` por `Image.asset` com `ClipOval`
   - Adicionado `errorBuilder` para fallback

4. ✅ **explorer_page.dart** (NOVO)
   - Adicionado import `url_launcher`
   - Criada função `_launchWebsite()` para abrir URL
   - Substituído "Mural vazio" por banner clicável
   - InkWell com feedback visual ao toque
   - Fallback com Card estilizado caso imagem não carregue

## Funcionalidades do Banner

### Clique e Redirecionamento
- Usa `url_launcher` para abrir navegador
- Modo: `LaunchMode.externalApplication` (abre navegador externo)
- Tratamento de erros com SnackBar
- Mensagens informativas ao usuário

### Design Responsivo
- `fit: BoxFit.cover` para preencher área
- BorderRadius consistente (20px)
- BoxShadow para profundidade
- InkWell com bordas arredondadas para feedback

### Fallback Elegante
- Card estilizado caso imagem não carregue
- Ícone de link + texto "LBW VET"
- Mantém funcionalidade de clique
- Design consistente com tema do app

## Próximos Passos

1. ✅ Salve a logo GDAV como `assets/images/gdav_logo.png`
2. ✅ Salve o banner LBW VET como `assets/images/banner_lbwvet.png`
3. ⏳ Execute `flutter pub get` para atualizar os assets e dependências
4. ⏳ Execute `flutter run` ou hot reload para ver as imagens

## Solução de Problemas

### Imagens não aparecem
```bash
# 1. Verifique se as imagens existem
ls assets/images/

# 2. Limpe o build
flutter clean

# 3. Instale as dependências
flutter pub get

# 4. Reconstrua
flutter run
```

### Banner não abre o link
- Certifique-se que `url_launcher` foi instalado: `flutter pub get`
- Verifique permissões de internet (já configuradas no projeto)
- Teste em dispositivo real (emuladores podem ter restrições)

### Imagens distorcidas
- **Logo**: Use PNG com transparência, mínimo 400x400
- **Banner**: Use proporção retangular (16:6 recomendado), mínimo 800x300
- As imagens são redimensionadas automaticamente mantendo proporção

## Customização Futura

### Adicionar mais banners:

```dart
// No mural da explorer_page.dart
SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: InkWell(
      onTap: () => _launchCustomUrl('https://exemplo.com'),
      borderRadius: BorderRadius.circular(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset('assets/images/outro_banner.png'),
      ),
    ),
  ),
)
```

### Possíveis adições:
- Múltiplos banners rotativos (carousel)
- Banner dinâmico carregado do servidor
- Analytics de cliques
- Deep links para outras partes do app

---

**Desenvolvido por**: GDAV  
**Última atualização**: Novembro 2025  
**Versão**: 1.1.0 (com banner LBW VET)
