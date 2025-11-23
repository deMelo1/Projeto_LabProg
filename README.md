# Central de Controle do Grifo

Sistema completo de gestão para atlética universitária, desenvolvido para gerenciar estoque, cautelas, sócios e usuários de forma integrada e eficiente.

## Índice

- [Sobre o Projeto](#sobre-o-projeto)
- [Arquitetura](#arquitetura)
- [Funcionalidades](#funcionalidades)
- [Tecnologias](#tecnologias)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Pré-requisitos](#pré-requisitos)
- [Configuração e Instalação](#configuração-e-instalação)
- [Executando o Sistema](#executando-o-sistema)
- [Hierarquia de Permissões](#hierarquia-de-permissões)
- [Deploy](#deploy)
- [Documentação Adicional](#documentação-adicional)

## Sobre o Projeto

O **Central de Controle do Grifo** é uma solução completa desenvolvida para gerenciar as operações de uma atlética universitária, oferecendo:

- **Controle de Estoque**: Gestão completa de itens, entradas, saídas e histórico de movimentações
- **Sistema de Cautelas**: Registro e acompanhamento de itens emprestados aos membros
- **Gestão de Sócios**: Cadastro, renovação e controle de filiações
- **Gestão de Usuários**: Sistema hierárquico de permissões com aprovação de cadastros
- **Log de Atividades**: Auditoria completa de todas as ações realizadas no sistema

O sistema é composto por três interfaces:
- **Backend REST API** (Java/Spring Boot)
- **Frontend Web** (HTML/CSS/JavaScript)
- **Aplicativo Mobile** (Flutter/Dart)

## Arquitetura

```
┌─────────────────┐
│  App Mobile     │
│  (Flutter)      │
└────────┬────────┘
         │
         │ HTTP/REST
         │
┌────────▼────────────────────────┐
│   Backend API                   │
│   (Spring Boot + PostgreSQL)    │
│                                 │
│   ┌──────────────────────────┐  │
│   │  Controllers REST        │  │
│   │  - AuthController        │  │
│   │  - EstoqueController     │  │
│   │  - CautelasController    │  │
│   │  - SocioController       │  │
│   │  - LogAtividadeController│  │
│   └──────────────────────────┘  │
│                                 │
│   ┌──────────────────────────┐  │
│   │  PostgreSQL Database     │  │
│   └──────────────────────────┘  │
└────────┬────────────────────────┘
         │
         │ HTTP/REST
         │
┌────────▼────────┐
│  Frontend Web   │
│  (HTML/JS/CSS)  │
└─────────────────┘
```

## Funcionalidades

### Controle de Estoque

- **Cadastro de Itens**: Adicionar novos itens ao estoque com nome, descrição e quantidade inicial
- **Movimentações**: Registrar entradas e saídas de itens
- **Inventário**: Visualizar quantidade atual de cada item
- **Histórico Completo**: Acompanhar todas as movimentações (apenas ADMIN e MASTER)
- **Exclusão de Registros**: Deletar movimentações do histórico (apenas MASTER)

### Sistema de Cautelas

- **Cadastro de Itens Cauteláveis**: Definir quais itens podem ser emprestados
- **Registro de Cautelas**: Criar novas cautelas informando membro, item, quantidade e observações
- **Minhas Cautelas**: Visualizar e devolver itens cautelados pelo próprio usuário
- **Quem Está Com**: Verificar posse atual de todos os itens cautelados
- **Histórico Completo**: Visualizar todas as cautelas registradas (apenas ADMIN e MASTER)
- **Devolução**: Marcar cautelas como devolvidas (próprias ou de outros, conforme permissão)

### Gestão de Sócios

- **Cadastro de Sócios**: Registrar novos sócios com CPF, nome, turma e período de filiação
- **Renovação**: Renovar filiações de sócios existentes
- **Gestão Completa**: Visualizar todos os sócios, filtrar por status (ATIVO, PRÓXIMO_VENCIMENTO, ATRASADO)
- **Alertas**: Sistema identifica automaticamente sócios com vencimento próximo (30 dias) ou atrasados

### Gestão de Usuários

- **Cadastro com Aprovação**: Novos usuários se cadastram e ficam pendentes de aprovação
- **Aprovação/Rejeição**: MASTER aprova ou rejeita cadastros pendentes
- **Gerenciamento**: Listar, visualizar e excluir usuários do sistema
- **Hierarquia de Permissões**: Sistema de 3 níveis (MASTER, ADMIN, MEMBRO)

### Log de Atividades

- **Auditoria Completa**: Registro de todas as ações realizadas no sistema
- **Filtros**: Buscar por usuário, data, tipo de ação
- **Acesso Exclusivo**: Apenas usuários MASTER podem visualizar logs

## Tecnologias

### Backend
- **Java 21**: Linguagem de programação
- **Spring Boot 3.5.6**: Framework para desenvolvimento de APIs REST
- **Spring Data JPA**: Persistência de dados
- **PostgreSQL**: Banco de dados relacional
- **Spring Session**: Gerenciamento de sessões HTTP

### Frontend Web
- **HTML5**: Estrutura
- **CSS3**: Estilização
- **JavaScript (Vanilla)**: Lógica e interatividade
- **Fetch API**: Comunicação com backend

### Mobile
- **Flutter 3.0+**: Framework multiplataforma
- **Dart**: Linguagem de programação
- **HTTP Package**: Requisições HTTP
- **Hive**: Armazenamento local (cache e sessão)

## Estrutura do Projeto

```
Projeto_LabProg/
│
├── lab-prog-web/                    # Backend (Spring Boot)
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/
│   │   │   │   └── com/example/labprog/onepage/
│   │   │   │       ├── controller/          # Controllers REST
│   │   │   │       ├── entity/              # Entidades JPA
│   │   │   │       ├── repository/          # Repositórios JPA
│   │   │   │       ├── service/             # Lógica de negócio
│   │   │   │       └── config/              # Configurações
│   │   │   └── resources/
│   │   │       ├── static/                  # Frontend Web
│   │   │       │   ├── *.html               # Páginas HTML
│   │   │       │   ├── *.js                 # Scripts JavaScript
│   │   │       │   └── styles.css           # Estilos CSS
│   │   │       └── application.properties   # Configurações do Spring
│   │   └── test/                            # Testes
│   ├── build.gradle                        # Dependências Gradle
│   └── README.md                           # Documentação do backend
│
├── app grifo att/                          # App Mobile (Flutter)
│   ├── lib/
│   │   ├── main.dart                       # Ponto de entrada
│   │   ├── globals.dart                    # Variáveis globais
│   │   ├── models/                         # Modelos de dados
│   │   ├── screens/                        # Telas do app
│   │   │   ├── estoque/                    # Telas de estoque
│   │   │   ├── cautelas/                   # Telas de cautelas
│   │   │   ├── socios/                     # Telas de sócios
│   │   │   ├── gestao/                     # Gestão de usuários
│   │   │   └── log/                        # Log de atividades
│   │   ├── services/                       # Serviços (API)
│   │   ├── widgets/                        # Componentes reutilizáveis
│   │   └── utils/                          # Utilitários
│   ├── pubspec.yaml                        # Dependências Flutter
│   └── README.md                           # Documentação do app
│
└── README.md                               # Este arquivo
```

## Pré-requisitos

### Para o Backend
- **Java 21** ou superior
- **PostgreSQL 12+** instalado e rodando
- **Gradle 7+** (ou usar o wrapper incluído: `gradlew`)

### Para o Frontend Web
- Navegador moderno (Chrome, Firefox, Edge, Safari)
- Backend rodando e acessível

### Para o App Mobile
- **Flutter SDK 3.0+** instalado
- **Android Studio** ou **Xcode** (para desenvolvimento mobile)
- Backend rodando e acessível

## Configuração e Instalação

### 1. Configurar Banco de Dados

Crie um banco de dados PostgreSQL:

```sql
CREATE DATABASE labprog;
```

### 2. Configurar Backend

Edite o arquivo `lab-prog-web/src/main/resources/application.properties`:

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/labprog
spring.datasource.username=seu_usuario
spring.datasource.password=sua_senha
```

### 3. Configurar App Mobile

Edite o arquivo `app grifo att/lib/globals.dart` para apontar para a URL do backend:

```dart
const String baseUrl = 'http://seu-backend:8081';
// ou para produção:
// const String baseUrl = 'https://teste-lab-prog-production.up.railway.app';
```

## Executando o Sistema

### Backend

```bash
cd lab-prog-web
./gradlew bootRun
```

O backend estará disponível em: `http://localhost:8081`

### Frontend Web

Após iniciar o backend, acesse:
- **Login**: `http://localhost:8081/login.html`
- **Usuário padrão**: `grifo` / `grifo1792`

### App Mobile

```bash
cd "app grifo att"
flutter pub get
flutter run
```

Para gerar APK (Android):
```bash
flutter build apk --release
```

## Hierarquia de Permissões

O sistema possui três níveis de permissão:

### MASTER (Presidência)
- Controle total do sistema
- Gestão de usuários (aprovar, rejeitar, deletar)
- Log de atividades
- **ÚNICO que pode EXCLUIR registros** do histórico
- Todas as funcionalidades de ADMIN e MEMBRO

### ADMIN (Diretores)
- Controle completo de estoque e cautelas
- Ver histórico completo de movimentações
- Marcar cautelas de qualquer usuário como devolvidas
- Gestão completa de sócios
- Não pode gerenciar usuários
- Não pode ver log de atividades
- Não pode excluir registros do histórico

### MEMBRO (Membros)
- Registrar entrada/saída de estoque
- Registrar novas cautelas
- Ver "Minhas Cautelas" e devolver próprios itens
- Ver inventário de estoque
- Ver "Quem Está Com" (posse atual)
- Cadastrar novos sócios
- Não pode ver histórico completo de movimentações
- Não pode ver histórico completo de cautelas
- Não pode excluir registros
- Não pode gerenciar usuários/logs
- Não pode marcar cautelas de outros como devolvidas

Para mais detalhes, consulte: [`lab-prog-web/HIERARQUIA_PERMISSOES.md`](lab-prog-web/HIERARQUIA_PERMISSOES.md)

## Deploy

### Backend (Railway)

O backend está configurado para deploy no Railway:
- **URL de Produção**: `https://teste-lab-prog-production.up.railway.app`
- Arquivos de configuração:
  - `railway.json`
  - `nixpacks.toml`
  - `Procfile`


## Documentação Adicional

- [`lab-prog-web/README.md`](lab-prog-web/README.md) - Documentação do backend
- [`lab-prog-web/HIERARQUIA_PERMISSOES.md`](lab-prog-web/HIERARQUIA_PERMISSOES.md) - Detalhes sobre permissões
- [`app grifo att/README.md`](app%20grifo%20att/README.md) - Documentação do app mobile



