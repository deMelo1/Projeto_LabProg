import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'globals.dart' as globals;
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'utils/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Hive para armazenamento local
  await Hive.initFlutter();
  await Hive.openBox('userBox');
  await Hive.openBox('cacheBox');

  // Tenta recuperar sessão salva
  var userBox = Hive.box('userBox');
  var savedSession = userBox.get('session');
  
  if (savedSession != null && savedSession is Map) {
    globals.currentUser = savedSession['login'] ?? '';
    globals.currentNome = savedSession['nome'] ?? '';
    globals.currentTipo = savedSession['tipo'] ?? '';
    globals.sessionId = savedSession['sessionId'] ?? '';
  }

  runApp(const GrifoApp());
}

class GrifoApp extends StatelessWidget {
  const GrifoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Central de Controle do Grifo',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      // Se há sessão salva, vai direto para home, senão vai para login
      home: globals.currentUser.isNotEmpty 
          ? const HomePage() 
          : const LoginPage(),
    );
  }
}

