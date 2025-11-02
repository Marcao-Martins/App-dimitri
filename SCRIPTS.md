# Scripts de Automação GDAV

Scripts PowerShell para facilitar o desenvolvimento e execução do aplicativo GDAV.

## 📜 Scripts Disponíveis

### 🚀 quick-start.ps1
**Uso rápido**: Inicia backend e frontend automaticamente.

```powershell
.\quick-start.ps1
```

Este é o script mais simples - apenas execute e tudo será configurado automaticamente!

### ⚙️ start.ps1
**Uso avançado**: Script completo com opções de configuração.

```powershell
# Modo padrão (desenvolvimento)
.\start.ps1

# Apenas backend
.\start.ps1 -SkipFrontend

# Apenas frontend
.\start.ps1 -SkipBackend

# Modo produção
.\start.ps1 -ProductionMode

# Porta customizada
.\start.ps1 -BackendPort 3000
```

**Parâmetros**:
- `-SkipBackend`: Não inicia o backend
- `-SkipFrontend`: Não inicia o frontend
- `-ProductionMode`: Compila e executa em modo produção
- `-BackendPort <número>`: Define porta do backend (padrão: 8080)

### 👤 create-admin.ps1
Cria um usuário administrador no sistema.

```powershell
# Usar credenciais padrão
.\create-admin.ps1

# Credenciais customizadas
.\create-admin.ps1 -Email "seu@email.com" -Password "SuaSenha@123"

# Porta customizada
.\create-admin.ps1 -Port 3000
```

**Credenciais padrão**:
- Email: `admin@gdav.com`
- Senha: `Admin@2024!`

**Requisitos de senha**:
- 8-128 caracteres
- Pelo menos 1 letra maiúscula
- Pelo menos 1 letra minúscula
- Pelo menos 1 número
- Pelo menos 1 caractere especial (@$!%*?&)

### 🛑 stop.ps1
Para todos os serviços em execução.

```powershell
.\stop.ps1
```

## 🎯 Fluxo de Trabalho Recomendado

### Primeiro Uso

1. **Iniciar o aplicativo**:
   ```powershell
   .\quick-start.ps1
   ```

2. **Criar administrador** (em outro terminal):
   ```powershell
   .\create-admin.ps1
   ```

3. **Usar o app**: O Flutter iniciará automaticamente. Use as credenciais criadas para login.

### Desenvolvimento Diário

```powershell
# Iniciar (backend + frontend)
.\quick-start.ps1

# Quando terminar
.\stop.ps1
```

### Apenas Backend (para testes de API)

```powershell
.\start.ps1 -SkipFrontend
```

Acesse: http://localhost:8080/api/v1/farmacos

### Apenas Frontend (backend já rodando)

```powershell
.\start.ps1 -SkipBackend
```

## 🔧 Troubleshooting

### Erro: "Dart não encontrado"
Instale o Dart SDK: https://dart.dev/get-dart

### Erro: "Flutter não encontrado"
Instale o Flutter SDK: https://flutter.dev/docs/get-started/install

### Erro: "Porta 8080 já em uso"
```powershell
# Opção 1: Pare o processo
.\stop.ps1

# Opção 2: Use outra porta
.\start.ps1 -BackendPort 3000
```

### Backend não responde
```powershell
# Verificar se está rodando
netstat -ano | findstr :8080

# Verificar logs
Get-Job | Receive-Job
```

### Erro ao criar admin: "Usuário já existe"
O usuário já foi criado anteriormente. Use as credenciais existentes ou:

```powershell
# Criar com outro email
.\create-admin.ps1 -Email "outro@email.com" -Password "Senha@123"
```

## 📊 Monitoramento

### Ver logs em tempo real (modo produção)
```powershell
# Listar jobs
Get-Job

# Ver logs de um job
Get-Job -Id 1 | Receive-Job

# Ver todos os logs
Get-Job | Receive-Job
```

### Testar endpoints manualmente

```powershell
# Listar fármacos
curl http://localhost:8080/api/v1/farmacos

# Buscar fármacos
curl "http://localhost:8080/api/v1/farmacos/search?q=dipirona"

# Login
curl -X POST http://localhost:8080/api/v1/auth/login `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"admin@gdav.com\",\"password\":\"Admin@2024!\"}'
```

## 🎨 Estrutura dos Scripts

```
App-dimitri/
├── quick-start.ps1      # Início rápido
├── start.ps1           # Script principal completo
├── create-admin.ps1    # Criar administrador
├── stop.ps1           # Parar serviços
└── backend/
    ├── data/
    │   ├── farmacos_veterinarios.csv
    │   └── users.json
    └── ...
```

## 💡 Dicas

1. **Hot Reload**: No modo desenvolvimento, o Flutter suporta hot reload. Salve arquivos Dart para ver mudanças instantâneas.

2. **Logs coloridos**: Os scripts usam cores para facilitar a leitura:
   - 🟢 Verde: Sucesso
   - 🔵 Azul: Informação
   - 🟡 Amarelo: Aviso
   - 🔴 Vermelho: Erro

3. **Múltiplos terminais**: Você pode abrir múltiplos terminais para:
   - Terminal 1: Backend rodando
   - Terminal 2: Frontend rodando
   - Terminal 3: Testes e comandos manuais

4. **Produção**: Use `-ProductionMode` apenas para testes de performance. Para desenvolvimento, use o modo padrão.

## 📝 Notas

- Os scripts verificam automaticamente todas as dependências necessárias
- O backend é iniciado primeiro e aguarda estar pronto antes do frontend
- Em modo desenvolvimento, o Flutter roda no terminal atual (para hot reload interativo)
- Em modo produção, ambos rodam em background como jobs
- O arquivo `users.json` é criado automaticamente se não existir
- O CSV de fármacos é copiado automaticamente para `backend/data/`

## 🆘 Suporte

Se encontrar problemas:

1. Execute `.\stop.ps1` para limpar tudo
2. Verifique se todas as dependências estão instaladas
3. Veja os logs com `Get-Job | Receive-Job`
4. Consulte o SETUPGUIDE.md para mais detalhes
