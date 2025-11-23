import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../globals.dart' as globals;
import '../services/api_service.dart';
import '../widgets/menu_card.dart';
import '../widgets/confirm_dialog.dart';
import 'login_page.dart';
import 'estoque/estoque_menu_page.dart';
import 'cautelas/cautelas_menu_page.dart';
import 'gestao/gestao_usuarios_page.dart';
import 'log/log_atividades_page.dart';
import 'socios/socios_menu_page.dart';
import 'socios/cadastro_socio_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Não faz verificação aqui, assume que o login já setou os dados
  }

  Future<void> _recuperarSessaoOuLogin() async {
    try {
      var userBox = Hive.box('userBox');
      var savedSession = userBox.get('session');
      
      if (savedSession != null && savedSession is Map) {
        setState(() {
          globals.currentUser = savedSession['login']?.toString() ?? '';
          globals.currentNome = savedSession['nome']?.toString() ?? '';
          globals.currentTipo = savedSession['tipo']?.toString() ?? '';
          globals.sessionId = savedSession['sessionId']?.toString() ?? '';
        });
        
        // Se recuperou com sucesso, não faz nada (o build vai renderizar)
        if (globals.currentUser.isNotEmpty) {
          return;
        }
      }
    } catch (e) {
      // Ignora erro
    }
    
    // Se não conseguiu recuperar, vai para login
    _irParaLogin();
  }

  void _irParaLogin() {
    globals.clearUserData();
    var userBox = Hive.box('userBox');
    userBox.delete('session');
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  Future<void> _fazerLogout() async {
    final confirmar = await ConfirmDialog.show(
      context,
      title: 'Sair',
      message: 'Deseja realmente sair do sistema?',
      confirmText: 'Sair',
      cancelText: 'Cancelar',
    );

    if (confirmar) {
      try {
        await ApiService.logout();
      } catch (e) {
        // Ignora erro de logout no servidor
      }
      
      if (!mounted) return;
      _irParaLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se não tem dados do usuário, tenta recuperar da sessão
    if (globals.currentUser.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _recuperarSessaoOuLogin();
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: LayoutBuilder(
          builder: (context, constraints) {
            // Título responsivo
            return Text(
              constraints.maxWidth > 400 
                ? 'CENTRAL DE CONTROLE DO GRIFO'
                : 'GRIFO',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        actions: [
          // Informações do usuário
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Olá, ${globals.currentNome.isNotEmpty ? globals.currentNome : "Usuário"}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    globals.currentTipo.isNotEmpty ? globals.currentTipo : 'Usuário',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Botão de logout
          IconButton(
            icon: const Icon(Icons.logout, size: 22),
            onPressed: _fazerLogout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Subtítulo com melhor espaçamento
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Text(
                  'Sistema de Gestão de Estoque e Cautelas',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              
              // Grid de cards do menu - Responsivo
              LayoutBuilder(
                builder: (context, constraints) {
                  // Calcula o número de colunas baseado na largura
                  int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                  // Proporção ajustada para dar mais altura aos cards
                  double childAspectRatio = constraints.maxWidth > 600 ? 1.0 : 0.85;
                  
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: childAspectRatio,
                    children: [
                // Controle de Estoque - Todos
                MenuCard(
                  title: 'CONTROLE DE ESTOQUE',
                  subtitle: 'Acompanhe entregas e retiradas de artigos',
                  icon: Icons.inventory_2,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EstoqueMenuPage()),
                    );
                  },
                ),
                
                // Controle de Cautelas - Todos
                MenuCard(
                  title: 'CONTROLE DE CAUTELAS',
                  subtitle: 'Registre e monitore as cautelas feitas',
                  icon: Icons.fact_check,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CautelasMenuPage()),
                    );
                  },
                ),
                
                // Gestão de Sócios - Todos (diferentes funcionalidades por tipo)
                MenuCard(
                  title: globals.isMaster() || globals.isAdminOrMaster() 
                      ? 'GESTÃO DE SÓCIOS' 
                      : 'CADASTRO DE SÓCIO',
                  subtitle: globals.isMaster() || globals.isAdminOrMaster()
                      ? 'Gerencie e renove cadastros de sócios'
                      : 'Registre novos sócios',
                  icon: Icons.card_membership,
                  color: Colors.teal[700],
                  onTap: () {
                    if (globals.isAdminOrMaster()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SociosMenuPage()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CadastroSocioPage()),
                      );
                    }
                  },
                ),
                
                // Gestão de Usuários - Apenas MASTER
                if (globals.isMaster())
                  MenuCard(
                    title: 'GESTÃO DE USUÁRIOS',
                    subtitle: 'Aprove cadastros e gerencie usuários',
                    icon: Icons.people,
                    color: Colors.orange[700],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GestaoUsuariosPage()),
                      );
                    },
                  ),
                
                // Log de Atividades - Apenas MASTER
                if (globals.isMaster())
                  MenuCard(
                    title: 'LOG DE ATIVIDADES',
                    subtitle: 'Visualize todas as ações realizadas',
                    icon: Icons.history,
                    color: Colors.purple[700],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LogAtividadesPage()),
                      );
                    },
                  ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

