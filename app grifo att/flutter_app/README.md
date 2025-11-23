# Central de Controle do Grifo - App Mobile 📱

Aplicativo Flutter completo para o sistema de gestão de estoque e cautelas do Grifo.

## 🎯 Funcionalidades

### 🔐 Autenticação
- Login e cadastro de usuários
- Três níveis de permissão: **MASTER**, **ADMIN** e **MEMBRO**
- Sistema de aprovação de cadastros (apenas MASTER)
- Sessão persistente com Hive

### 📦 Controle de Estoque
- **Cadastro de Itens** (ADMIN/MASTER)
- **Inventário** - Visualização de quantidades disponíveis
- **Entrada/Saída** - Registro de movimentações
- **Histórico** - Com filtros e busca (ADMIN/MASTER)
- Validação de estoque disponível
- Alertas de estoque baixo

### 📋 Controle de Cautelas
- **Cadastro de Itens Cauteláveis** (ADMIN/MASTER)
- **Minhas Cautelas** - Visualização e devolução das próprias cautelas
- **Quem Está Com** - Visão geral de posse (ADMIN/MASTER)
- **Nova Cautela** - Registro de empréstimos
- **Histórico Completo** (ADMIN/MASTER)
- Controle de disponibilidade em tempo real

### 👥 Gestão de Usuários (MASTER)
- Aprovação e rejeição de cadastros pendentes
- Listagem de todos os usuários
- Exclusão de usuários

### 📊 Log de Atividades (MASTER)
- Registro completo de todas as ações no sistema
- Filtros por tipo de entidade
- Busca por usuário, ação ou detalhes

## 🛠️ Tecnologias

- **Flutter** 3.x
- **Dart** 3.x
- **Hive** - Storage local
- **HTTP** - Comunicação com API REST
- **Material Design 3**

## 🚀 Setup

### 1. Configurar Backend

No arquivo `lib/globals.dart`, configure a URL do backend:

```dart
const String baseUrl = 'http://localhost:8081';
// Para produção, use:
// const String baseUrl = 'https://seu-app.railway.app';
```

### 2. Instalar Dependências

```bash
flutter pub get
```

### 3. Rodar o App

```bash
# Android
flutter run

# iOS
flutter run --no-sound-null-safety

# Web (não recomendado para produção)
flutter run -d chrome
```

## 📱 Estrutura do Projeto

```
lib/
├── main.dart                 # Entry point
├── globals.dart              # Variáveis globais e configurações
│
├── models/                   # Modelos de dados
│   ├── usuario.dart
│   ├── item_estoque.dart
│   ├── movimentacao_estoque.dart
│   ├── item_cautela.dart
│   ├── cautela.dart
│   └── log_atividade.dart
│
├── services/                 # Serviços
│   └── api_service.dart      # Comunicação com backend
│
├── screens/                  # Telas
│   ├── login_page.dart
│   ├── home_page.dart
│   │
│   ├── estoque/              # Módulo de Estoque
│   │   ├── estoque_menu_page.dart
│   │   ├── cadastro_itens_page.dart
│   │   ├── inventario_page.dart
│   │   ├── movimentacao_page.dart
│   │   └── historico_page.dart
│   │
│   ├── cautelas/             # Módulo de Cautelas
│   │   ├── cautelas_menu_page.dart
│   │   ├── cadastro_itens_cautela_page.dart
│   │   ├── minhas_cautelas_page.dart
│   │   ├── quem_esta_com_page.dart
│   │   ├── nova_cautela_page.dart
│   │   └── historico_cautelas_page.dart
│   │
│   ├── gestao/               # Gestão de Usuários (MASTER)
│   │   └── gestao_usuarios_page.dart
│   │
│   └── log/                  # Log de Atividades (MASTER)
│       └── log_atividades_page.dart
│
├── widgets/                  # Widgets reutilizáveis
│   ├── menu_card.dart
│   ├── loading_overlay.dart
│   └── confirm_dialog.dart
│
└── utils/                    # Utilitários
    ├── theme.dart
    └── snackbar_utils.dart
```

## 🔑 Hierarquia de Permissões

### 🔴 MASTER (Diretoria)
- ✅ **Todas** as funcionalidades
- ✅ **Único** que pode excluir registros
- ✅ Aprovar/Rejeitar cadastros
- ✅ Gerenciar usuários
- ✅ Visualizar log completo

### 🟠 ADMIN (Liderança)
- ✅ Estoque completo
- ✅ Cautelas completas
- ✅ Ver históricos
- ❌ Gestão de usuários
- ❌ Log de atividades
- ❌ Excluir registros

### 🟢 MEMBRO (Base)
- ✅ Inventário (visualização)
- ✅ Registrar movimentações
- ✅ Minhas cautelas
- ✅ Nova cautela
- ❌ Cadastro de itens
- ❌ Históricos completos
- ❌ Ver "Quem Está Com"

## 🎨 Design

- **Tema**: Vermelho Grifo (#750000)
- **Estilo**: Material Design 3
- **Responsivo**: Adaptado para smartphones e tablets
- **Dark Mode**: Não implementado (apenas light theme)

## 📝 Credenciais de Teste

### Usuário Master (pré-cadastrado)
- **Login**: grifo
- **Senha**: grifo1792

## 🔧 Configurações Importantes

### CORS
O backend deve estar configurado para aceitar requisições do app:

```java
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
```

### Session Management
O app utiliza cookies de sessão para manter o usuário autenticado.

### Storage Local
Dados armazenados com Hive:
- Sessão do usuário (login, nome, tipo)
- Cache de dados (opcional)

## 📦 Build para Produção

### Android

```bash
flutter build apk --release
# ou
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## 🐛 Troubleshooting

### Erro de conexão com o servidor
- Verifique se o backend está rodando
- Confirme a URL em `globals.dart`
- Para emulador Android: use `10.0.2.2:8081` em vez de `localhost:8081`
- Para dispositivo físico: use o IP da máquina na rede local

### Erro de CORS
- Verifique as configurações de CORS no backend
- Certifique-se de que `allowCredentials = true`

### Sessão expira muito rápido
- Ajuste o timeout de sessão no backend (Spring Boot)

## 📄 Licença

Este projeto é parte do sistema acadêmico do Grifo.

## 👨‍💻 Desenvolvedor

Criado para a instituição Grifo - Sistema de Gestão de Estoque e Cautelas.

