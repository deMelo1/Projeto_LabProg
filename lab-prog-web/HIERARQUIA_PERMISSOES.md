# 📊 Hierarquia de Permissões - Central de Controle do Grifo

## 🔴 MASTER (Diretoria - Exclusivo)
**Usuário padrão:** `grifo` / `grifo1792`

### Permissões:
- ✅ **Controle Total do Sistema**
- ✅ **Gestão de Usuários** (Aprovar, Rejeitar, Deletar usuários)
- ✅ **Log de Atividades** (Visualizar todas as ações do sistema)
- ✅ **ÚNICO que pode EXCLUIR registros** do histórico (Estoque e Cautelas)
- ✅ Controle de Estoque (Cadastro, Entrada/Saída, Histórico completo)
- ✅ Controle de Cautelas (Cadastro, Registro, Histórico completo)
- ✅ Ver Inventário e Posse Atual de Itens

### Páginas Exclusivas:
- **Gestão de Usuários** (`gestao-geral.html`) - Aprovação de cadastros + gerenciamento
- **Log de Atividades** (`log-atividades.html`)

---

## 🟠 ADMIN (Liderança)
**Função:** Membros de liderança com amplos poderes, mas sem gestão de pessoas

### Permissões:
- ✅ Controle de Estoque (Cadastro, Entrada/Saída, **Histórico completo**)
- ✅ Controle de Cautelas (Cadastro, Registro, **Histórico completo**)
- ✅ Ver Inventário e Posse Atual de Itens
- ✅ Marcar cautelas como devolvidas (de qualquer usuário)
- ❌ Gestão de Usuários
- ❌ Log de Atividades
- ❌ **Excluir registros do histórico**

### Diferença do MASTER:
- Não pode excluir registros
- Não pode gerenciar usuários
- Não pode ver logs do sistema

---

## 🟢 MEMBRO (Base)
**Função:** Usuários comuns com permissões básicas de operação

### Permissões:
- ✅ Registrar **Entrada/Saída de Estoque**
- ✅ Registrar **Nova Cautela**
- ✅ Ver **"Minhas Cautelas"** e devolver seus próprios itens
- ✅ Ver **Inventário** de estoque
- ✅ Ver **"Quem Está Com"** (posse atual de itens cautelados)
- ❌ **Ver Histórico Completo** de movimentações de estoque
- ❌ **Ver Histórico Completo** de cautelas
- ❌ Excluir registros
- ❌ Gestão de usuários/logs
- ❌ Marcar cautelas de outros como devolvidas

### Restrições:
- **Não vê** o card "Histórico de Movimentações" na página de Estoque
- **Não vê** o card "Histórico Completo" na página de Cautelas
- Pode apenas gerenciar suas próprias cautelas ativas

---

## 📝 Fluxo de Cadastro

1. **Novo usuário** acessa `login.html` e clica em "Fazer Cadastro"
2. Preenche: Nome, Login, Senha (com confirmação), Função (ADMIN/MEMBRO)
3. Cadastro fica **PENDENTE** de aprovação
4. **MASTER** acessa "Gestão de Usuários" → "Aprovação de Cadastros"
5. **MASTER** aprova ou rejeita o cadastro
6. Se aprovado, usuário pode fazer login

---

## 🛡️ Segurança

### Validações Backend:
- ✅ Exclusão de registros: apenas `TipoUsuario.MASTER`
- ✅ Gestão de usuários: apenas `TipoUsuario.MASTER`
- ✅ Log de atividades: apenas `TipoUsuario.MASTER`
- ✅ Todas as operações validam sessão

### Validações Frontend:
- ✅ Cards ocultos conforme permissões
- ✅ Históricos ocultos para MEMBRO
- ✅ Botões de exclusão aparecem apenas para MASTER

---

## 📂 Arquivos Importantes

### Páginas Unificadas (Novas):
- `gestao-geral.html` / `gestao-geral.js` - Gestão de Usuários (antes eram 2 páginas separadas)

### Controle de Permissões:
- `estoque.js` - Oculta histórico para MEMBRO
- `cautelas.js` - Oculta histórico para MEMBRO
- `index.js` - Mostra cards apenas para MASTER
- `estoque-historico.js` - Botão excluir apenas para MASTER
- `cautelas-historico.js` - Botão excluir apenas para MASTER

### Backend:
- `AuthController.java` - Validação de permissões de usuário
- `EstoqueController.java` - Validação TipoUsuario.MASTER/ADMIN
- `CautelasController.java` - Validação TipoUsuario.MASTER/ADMIN
- `LogAtividadeController.java` - Apenas TipoUsuario.MASTER

---

## 🎯 Resumo Rápido

| Funcionalidade | MASTER | ADMIN | MEMBRO |
|---|:---:|:---:|:---:|
| Registrar Estoque (Entrada/Saída) | ✅ | ✅ | ✅ |
| Ver Histórico de Estoque | ✅ | ✅ | ❌ |
| Excluir Movimentação de Estoque | ✅ | ❌ | ❌ |
| Registrar Cautela | ✅ | ✅ | ✅ |
| Ver Histórico de Cautelas | ✅ | ✅ | ❌ |
| Ver "Minhas Cautelas" | ✅ | ✅ | ✅ |
| Devolver Cautela (própria) | ✅ | ✅ | ✅ |
| Devolver Cautela (de outro) | ✅ | ✅ | ❌ |
| Excluir Cautela do Histórico | ✅ | ❌ | ❌ |
| Gestão de Usuários | ✅ | ❌ | ❌ |
| Log de Atividades | ✅ | ❌ | ❌ |

---

**Última atualização:** Sistema implementado com hierarquia clara e controle total de permissões.

