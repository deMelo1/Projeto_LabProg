# 📋 Guia de Instalação - App Grifo

## Pré-requisitos

### 1. Instalar Flutter

#### Windows
```powershell
# Baixe o Flutter SDK de https://flutter.dev/docs/get-started/install/windows
# Extraia para C:\src\flutter
# Adicione ao PATH: C:\src\flutter\bin
```

#### macOS
```bash
brew install flutter
```

#### Linux
```bash
snap install flutter --classic
```

### 2. Verificar Instalação

```bash
flutter doctor
```

Resolva todos os issues apontados pelo `flutter doctor`.

### 3. Configurar IDE

**Android Studio** (Recomendado):
- Instale os plugins: Flutter e Dart
- Configure um emulador Android

**VS Code**:
- Instale a extensão Flutter
- Instale a extensão Dart

## 🚀 Executando o Projeto

### 1. Clone ou Copie o Projeto

Copie a pasta `flutter_app` para um local de sua preferência.

### 2. Entre na Pasta do Projeto

```bash
cd flutter_app
```

### 3. Instale as Dependências

```bash
flutter pub get
```

### 4. Configure o Backend

Edite o arquivo `lib/globals.dart` e ajuste a URL do backend:

```dart
// Para desenvolvimento local
const String baseUrl = 'http://localhost:8081';

// Para emulador Android (aponta para a máquina host)
const String baseUrl = 'http://10.0.2.2:8081';

// Para dispositivo físico na mesma rede
const String baseUrl = 'http://192.168.1.X:8081'; // Substitua pelo IP da sua máquina

// Para produção (Railway, etc.)
const String baseUrl = 'https://seu-app.railway.app';
```

### 5. Execute o App

#### No Emulador

```bash
# Liste os dispositivos disponíveis
flutter devices

# Execute no dispositivo selecionado
flutter run
```

#### Em Dispositivo Físico

1. Ative o modo desenvolvedor no Android
2. Ative a depuração USB
3. Conecte o dispositivo
4. Execute: `flutter run`

### 6. Build de Produção

#### Android APK

```bash
flutter build apk --release
```

O APK estará em: `build/app/outputs/flutter-apk/app-release.apk`

#### Android App Bundle (Para Google Play)

```bash
flutter build appbundle --release
```

## 🔧 Configurações Adicionais

### Hot Reload

Durante o desenvolvimento, use:
- `r` - Hot reload (mantém o estado)
- `R` - Hot restart (reinicia o app)
- `q` - Quit

### Debug

Para debugar, adicione breakpoints no VS Code ou Android Studio e execute em modo debug:

```bash
flutter run --debug
```

### Performance

Para medir performance:

```bash
flutter run --profile
```

## 🐛 Problemas Comuns

### Erro: SDK Flutter não encontrado

```bash
flutter config --android-sdk /caminho/para/android/sdk
```

### Erro: Licenças Android não aceitas

```bash
flutter doctor --android-licenses
```

### Erro: Conexão recusada com o backend

- Verifique se o backend Spring Boot está rodando
- Confirme a URL em `lib/globals.dart`
- No emulador Android, use `10.0.2.2` em vez de `localhost`
- Em dispositivo físico, use o IP da máquina na rede local

### App não conecta no dispositivo físico

1. Certifique-se de que o dispositivo e o computador estão na mesma rede
2. Use o IP local da máquina (não localhost)
3. Verifique o firewall do Windows/macOS
4. O backend deve estar acessível na rede local

### Erro de CORS

Configure o backend para aceitar requisições do app:

```java
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
```

## 📱 Testando no Dispositivo Físico

### Descobrir IP da Máquina

#### Windows
```powershell
ipconfig
# Procure por "Endereço IPv4" na interface de rede ativa
```

#### macOS/Linux
```bash
ifconfig
# ou
ip addr show
```

### Configurar no App

Edite `lib/globals.dart`:

```dart
const String baseUrl = 'http://SEU_IP_LOCAL:8081';
// Exemplo: 'http://192.168.1.100:8081'
```

## ✅ Checklist Final

- [ ] Flutter instalado (`flutter doctor` OK)
- [ ] Dependências instaladas (`flutter pub get`)
- [ ] Backend rodando e acessível
- [ ] URL configurada em `globals.dart`
- [ ] Emulador ou dispositivo conectado
- [ ] App executando sem erros

## 📞 Suporte

Para problemas específicos:
1. Verifique os logs: `flutter logs`
2. Limpe o build: `flutter clean && flutter pub get`
3. Reinicie o IDE
4. Reinicie o emulador/dispositivo

---

**Última atualização**: 2025

