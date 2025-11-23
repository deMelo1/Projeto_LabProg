# Hierarquia de Permissões - Central de Controle do Grifo

## MASTER (Presidência)
**Usuário padrão:** `grifo` / `grifo1792`

### Permissões:
- **Controle Total do Sistema**
- **Gestão de Usuários** (Aprovar, Rejeitar, Deletar usuários)
- **Log de Atividades** (Visualizar todas as ações do sistema)
- **ÚNICO que pode EXCLUIR registros** do histórico (Estoque e Cautelas)
- Controle de Estoque (Cadastro, Entrada/Saída, Histórico completo)
- Controle de Cautelas (Cadastro, Registro, Histórico completo)
- Ver Inventário e Posse Atual de Itens
- **Gestão de Sócios** (Cadastrar, Listar, Renovar, Deletar, Ver atrasados e próximos ao vencimento)

### Páginas Exclusivas:
- **Gestão de Usuários** (`gestao-geral.html`) - Aprovação de cadastros + gerenciamento
- **Log de Atividades** (`log-atividades.html`)

---

## ADMIN (Diretoria)
**Função:** Membros de liderança com amplos poderes, mas sem gestão de pessoas

### Permissões:
- Controle de Estoque (Cadastro, Entrada/Saída, **Histórico completo**)
- Controle de Cautelas (Cadastro, Registro, **Histórico completo**)
- Ver Inventário e Posse Atual de Itens
- Marcar cautelas como devolvidas (de qualquer usuário)
- **Gestão de Sócios** (Cadastrar, Listar, Renovar, Deletar, Ver atrasados e próximos ao vencimento)
- Não pode gerenciar usuários
- Não pode ver log de atividades
- Não pode **excluir registros do histórico**

### Diferença do MASTER:
- Não pode excluir registros
- Não pode gerenciar usuários
- Não pode ver logs do sistema

---

## MEMBRO (Membros)
**Função:** Usuários comuns com permissões básicas de operação

### Permissões:
- Registrar **Entrada/Saída de Estoque**
- Registrar **Nova Cautela**
- Ver **"Minhas Cautelas"** e devolver seus próprios itens
- Ver **Inventário** de estoque
- Ver **"Quem Está Com"** (posse atual de itens cautelados)
- **Cadastrar novos sócios**
- Não pode **Renovar filiação de sócios**
- Não pode **ver histórico completo** de movimentações de estoque
- Não pode **ver histórico completo** de cautelas
- Não pode excluir registros
- Não pode gerenciar usuários/logs
- Não pode marcar cautelas de outros como devolvidas
- Não pode **deletar sócios**
- Não pode **ver sócios atrasados ou próximos ao vencimento**
- Não pode **gerenciar sócios** (página de gestão completa)

### Restrições:
- **Não vê** o card "Histórico de Movimentações" na página de Estoque
- **Não vê** o card "Histórico Completo" na página de Cautelas
- Pode apenas gerenciar suas próprias cautelas ativas
- **Não vê** o card "Gerenciar Sócios" no menu de sócios (apenas ADMIN e MASTER)

---

## Fluxo de Cadastro

1. **Novo usuário** acessa `login.html` e clica em "Fazer Cadastro"
2. Preenche: Nome, Login, Senha (com confirmação), Função (ADMIN/MEMBRO)
3. Cadastro fica **PENDENTE** de aprovação
4. **MASTER** acessa "Gestão de Usuários" → "Aprovação de Cadastros"
5. **MASTER** aprova ou rejeita o cadastro
6. Se aprovado, usuário pode fazer login

---

## Segurança

### Validações Backend:
- Exclusão de registros (estoque/cautelas): apenas `TipoUsuario.MASTER`
- Gestão de usuários: apenas `TipoUsuario.MASTER`
- Log de atividades: apenas `TipoUsuario.MASTER`
- Deletar sócio: apenas `TipoUsuario.MASTER` ou `TipoUsuario.ADMIN`
- Ver sócios atrasados/próximos ao vencimento: apenas `TipoUsuario.MASTER` ou `TipoUsuario.ADMIN`
- Cadastrar/Renovar sócio: todos os usuários autenticados
- Todas as operações validam sessão

### Validações Frontend:
- Cards ocultos conforme permissões
- Históricos ocultos para MEMBRO
- Botões de exclusão aparecem apenas para MASTER

---

## Arquivos Importantes

### Páginas Unificadas (Novas):
- `gestao-geral.html` / `gestao-geral.js` - Gestão de Usuários (antes eram 2 páginas separadas)

### Controle de Permissões:
- `estoque.js` - Oculta histórico para MEMBRO
- `cautelas.js` - Oculta histórico para MEMBRO
- `index.js` - Mostra cards apenas para MASTER
- `estoque-historico.js` - Botão excluir apenas para MASTER
- `cautelas-historico.js` - Botão excluir apenas para MASTER
- `socios-menu.js` / `socios_menu_page.dart` - Card "Gerenciar Sócios" apenas para ADMIN e MASTER
- `gestao-socios.js` / `gestao_socios_page.dart` - Acesso apenas para ADMIN e MASTER

### Backend:
- `AuthController.java` - Validação de permissões de usuário
- `EstoqueController.java` - Validação TipoUsuario.MASTER/ADMIN
- `CautelasController.java` - Validação TipoUsuario.MASTER/ADMIN
- `SocioController.java` - Deletar sócio: MASTER/ADMIN | Ver atrasados/próximos/Renovar: MASTER/ADMIN | Cadastrar: Todos autenticados
- `LogAtividadeController.java` - Apenas TipoUsuario.MASTER

---

## Resumo Rápido

| Funcionalidade | MASTER | ADMIN | MEMBRO |
|---|:---:|:---:|:---:|
| Registrar Estoque (Entrada/Saída) | Sim | Sim | Sim |
| Ver Histórico de Estoque | Sim | Sim | Não |
| Excluir Movimentação de Estoque | Sim | Não | Não |
| Registrar Cautela | Sim | Sim | Sim |
| Ver Histórico de Cautelas | Sim | Sim | Não |
| Ver "Minhas Cautelas" | Sim | Sim | Sim |
| Devolver Cautela (própria) | Sim | Sim | Sim |
| Devolver Cautela (de outro) | Sim | Sim | Não |
| Excluir Cautela do Histórico | Sim | Não | Não |
| Gestão de Usuários | Sim | Não | Não |
| Log de Atividades | Sim | Não | Não |
| Cadastrar Sócio | Sim | Sim | Sim |
| Renovar Filiação de Sócio | Sim | Sim | Não |
| Listar Sócios | Sim | Sim | Não |
| Deletar Sócio | Sim | Sim | Não |
| Ver Sócios Atrasados | Sim | Sim | Não |
| Ver Sócios Próximos ao Vencimento | Sim | Sim | Não |
| Gerenciar Sócios (página completa) | Sim | Sim | Não |





