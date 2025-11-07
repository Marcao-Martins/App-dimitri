# 📖 Guia de Uso - Painel de Gerenciamento de Parâmetros

## 🚀 Como Acessar

### 1. Login como Administrador
```
- Acesse a página de login do GDAV
- Use credenciais de admin
- Clique em "Entrar"
```

### 2. Navegar para Painel Admin
```
- Clique no menu (⋮) no canto superior direito
- Será exibido opção "Gerenciar Parâmetros"
- Clique para abrir o painel
```

---

## 📋 Dashboard de Parâmetros

### Visualizar Lista
- **Busca**: Campo de busca por nome do parâmetro
- **Estatísticas**: Mostra total de parâmetros (51)
- **Cards**: Cada parâmetro exibe:
  - Nome do parâmetro
  - Valores para Cão, Gato e Cavalo (resumo)
  - Botões de ação (editar/deletar)

### Exemplo:
```
┌─────────────────────────────────────────┐
│ 💓 Frequência Cardíaca (FC)             │
│ Cão: 70-220 bpm                         │
│ Gato: 120-240 bpm                       │
│ Cavalo: 28-40 bpm                       │
│ [✏️]  [🗑️]                              │
└─────────────────────────────────────────┘
```

---

## ➕ Adicionar Novo Parâmetro

### Passo 1: Abrir Formulário
```
- Clique no botão "+" flutuante (canto inferior direito)
- Abrirá página "Adicionar Parâmetro"
```

### Passo 2: Preencher Campos

#### Seção: Informações Básicas
- **Nome** ⭐ (obrigatório)
  - Exemplo: "Temperatura Corporal"
  - Máximo: sem limite de caracteres

#### Seção: Valores por Espécie
- **Valores - Cão** ⭐ (obrigatório)
  - Exemplo: "37-39°C"
  
- **Valores - Gato** (opcional)
  - Exemplo: "38-39.2°C"
  
- **Valores - Cavalo** (opcional)
  - Exemplo: "37-38.5°C"

#### Seção: Informações Adicionais
- **Comentários** (opcional)
  - Observações clínicas importantes
  
- **Referências** (opcional)
  - Fonte bibliográfica

### Passo 3: Preview (Opcional)
```
- Clique no botão "Preview"
- Veja como ficará exibido
- Clique "Editar" para voltar aos campos
```

### Passo 4: Salvar
```
- Clique no botão "✓" (flutuante)
- Aparecerá mensagem de sucesso/erro
- Será redirecionado ao dashboard
```

---

## ✏️ Editar Parâmetro

### Passo 1: Localizar Parâmetro
```
- Na lista do dashboard
- Use a busca se necessário
```

### Passo 2: Abrir Editor
```
- Clique no botão "✏️" (editar) no card
- Abrirá página de edição pré-preenchida
```

### Passo 3: Modificar Campos
```
- O nome fica em somente leitura (para referência)
- Modifique os valores conforme necessário
- Use preview antes de salvar
```

### Passo 4: Salvar Alterações
```
- Clique no botão "✓" (flutuante)
- Confirme na mensagem de sucesso
```

---

## 🗑️ Deletar Parâmetro

### Passo 1: Localizar Parâmetro
```
- Na lista do dashboard
```

### Passo 2: Confirmar Deleção
```
- Clique no botão "🗑️" (deletar)
- Dialog de confirmação aparecerá
- Clique "Excluir" para confirmar
- Clique "Cancelar" para abortar
```

### Passo 3: Confirmação
```
- Mensagem de sucesso aparecerá
- Parâmetro será removido da lista
```

---

## 🔍 Usar Busca

### Como Funciona
```
- Digite parte do nome do parâmetro
- A lista filtra automaticamente em tempo real
- Clique "X" para limpar busca
```

### Exemplo de Buscas
```
Busca: "freq"
Resultado: Frequência Cardíaca, Frequência Respiratória

Busca: "pressão"
Resultado: Pressão Arterial Sistólica, Pressão Arterial Média, etc.

Busca: "gato"
Resultado: Mostra todos os parâmetros que contêm "gato"
```

---

## 💡 Dicas Úteis

### Formato de Valores
```
✓ Intervalo: "70-220 bpm"
✓ Com unidade: "37-39°C"
✓ Múltiplas linhas: 
  "70-220 bpm (cães)
   70-180 bpm (raças toy)"
✓ Com observações: "100-160 mmHg (repouso)"
```

### Boas Práticas
```
1. Sempre preencha o valor para Cão (obrigatório)
2. Adicione Gato e Cavalo quando disponível
3. Use comentários para informações clínicas importantes
4. Inclua referências quando possível
5. Use preview antes de salvar
6. Revise dados antes de deletar
```

### Limitações Atuais
```
⏳ Dados salvos apenas na memória (reinício perde)
⏳ Sem sincronização com banco de dados
⏳ Sem histórico de alterações
⏳ Sem desfazer/refazer
```

---

## ⚠️ Mensagens de Erro

| Mensagem | Causa | Solução |
|----------|-------|---------|
| "Campo obrigatório" | Nome ou Cão vazios | Preencha os campos marcados com * |
| "Funcionalidade em breve" | Persistência ainda não implementada | Aguarde atualização |
| "Erro ao excluir" | Problema técnico | Recarregue a página |
| "Acesso negado" | Não é administrador | Faça login com conta admin |

---

## 🔐 Controle de Acesso

```
✅ ADMIN: Acesso total a tudo
❌ USUÁRIO: Sem acesso (aba oculta)
❌ GUEST: Sem acesso (aba oculta)
```

---

## 📞 Suporte

Para problemas ou dúvidas:
1. Verifique se está logado como admin
2. Recarregue a página (F5)
3. Verifique o console (F12) para erros
4. Contacte o desenvolvedor

