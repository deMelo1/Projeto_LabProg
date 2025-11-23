import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../globals.dart' as globals;
import '../services/api_service.dart';
import '../widgets/loading_overlay.dart';
import '../utils/snackbar_utils.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Controllers para Login
  final _loginUsuarioController = TextEditingController();
  final _loginSenhaController = TextEditingController();
  
  // Controllers para Cadastro
  final _cadastroNomeController = TextEditingController();
  final _cadastroUsuarioController = TextEditingController();
  final _cadastroSenhaController = TextEditingController();
  final _cadastroConfirmaSenhaController = TextEditingController();
  
  String _tipoSelecionado = 'MEMBRO';
  
  final _formKeyLogin = GlobalKey<FormState>();
  final _formKeyCadastro = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginUsuarioController.dispose();
    _loginSenhaController.dispose();
    _cadastroNomeController.dispose();
    _cadastroUsuarioController.dispose();
    _cadastroSenhaController.dispose();
    _cadastroConfirmaSenhaController.dispose();
    super.dispose();
  }

  Future<void> _fazerLogin() async {
    if (!_formKeyLogin.currentState!.validate()) return;

    LoadingOverlay.show(context, message: 'Entrando...');
    
    try {
      final resultado = await ApiService.login(
        _loginUsuarioController.text.trim(),
        _loginSenhaController.text,
      );

      if (!mounted) return;
      LoadingOverlay.hide(context);

      // Verifica se o login foi bem-sucedido
      if (resultado['success'] == true) {
        // Verifica se tem o objeto usuario
        if (resultado['usuario'] == null) {
          SnackbarUtils.showError(context, 'Erro: resposta do servidor incompleta');
          return;
        }

        // Salva os dados do usuário nas variáveis globais
        final usuario = resultado['usuario'];
        
        // Tenta pegar o login de diferentes formas
        String loginUsuario = usuario['login']?.toString() ?? '';
        if (loginUsuario.isEmpty) {
          // Se o login vier vazio, usa o que foi digitado
          loginUsuario = _loginUsuarioController.text.trim();
        }
        
        globals.currentUser = loginUsuario;
        globals.currentNome = usuario['nome']?.toString() ?? '';
        globals.currentTipo = usuario['tipo']?.toString() ?? 'MEMBRO';

        // Valida que pelo menos o nome foi recebido
        if (globals.currentNome.isEmpty) {
          SnackbarUtils.showError(context, 'Erro: dados do usuário incompletos');
          return;
        }
        
        // Se o login ainda estiver vazio, usa o nome
        if (globals.currentUser.isEmpty) {
          globals.currentUser = globals.currentNome;
        }

        // Persiste a sessão no Hive
        try {
          var userBox = Hive.box('userBox');
          await userBox.put('session', {
            'login': globals.currentUser,
            'nome': globals.currentNome,
            'tipo': globals.currentTipo,
            'sessionId': globals.sessionId,
          });
        } catch (e) {
          SnackbarUtils.showError(context, 'Aviso: não foi possível salvar sessão');
          // Continua mesmo assim, os dados estão nas variáveis globais
        }

        // Navega para a home
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        // Login falhou
        final mensagem = resultado['message']?.toString() ?? 'Login ou senha inválidos';
        SnackbarUtils.showError(context, mensagem);
      }
    } catch (e) {
      if (!mounted) return;
      LoadingOverlay.hide(context);
      SnackbarUtils.showError(context, 'Erro ao conectar: ${e.toString()}');
    }
  }

  Future<void> _fazerCadastro() async {
    if (!_formKeyCadastro.currentState!.validate()) return;

    if (_cadastroSenhaController.text != _cadastroConfirmaSenhaController.text) {
      SnackbarUtils.showError(context, 'As senhas não coincidem');
      return;
    }

    LoadingOverlay.show(context, message: 'Cadastrando...');

    try {
      final resultado = await ApiService.cadastro(
        _cadastroNomeController.text.trim(),
        _cadastroUsuarioController.text.trim(),
        _cadastroSenhaController.text,
        _tipoSelecionado,
      );

      if (!mounted) return;
      LoadingOverlay.hide(context);

      if (resultado['success'] == true) {
        SnackbarUtils.showSuccess(context, resultado['message'] ?? 'Cadastro realizado! Aguarde aprovação.');
        
        // Limpa os campos e volta para a aba de login
        _cadastroNomeController.clear();
        _cadastroUsuarioController.clear();
        _cadastroSenhaController.clear();
        _cadastroConfirmaSenhaController.clear();
        _tipoSelecionado = 'MEMBRO';
        
        setState(() {
          _tabController.index = 0;
        });
      } else {
        SnackbarUtils.showError(context, resultado['message'] ?? 'Erro ao realizar cadastro');
      }
    } catch (e) {
      if (!mounted) return;
      LoadingOverlay.hide(context);
      SnackbarUtils.showError(context, 'Erro ao conectar com o servidor');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF750000),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Título
                    const Text(
                      'CENTRAL DE CONTROLE DO GRIFO',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF750000),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sistema de Gestão de Estoque e Cautelas',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // Tabs
                    TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFF750000),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: const Color(0xFF750000),
                      tabs: const [
                        Tab(text: 'Entrar'),
                        Tab(text: 'Cadastrar'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Tab Views
                    SizedBox(
                      height: 320,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildLoginForm(),
                          _buildCadastroForm(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKeyLogin,
      child: Column(
        children: [
          TextFormField(
            controller: _loginUsuarioController,
            decoration: const InputDecoration(
              labelText: 'Login',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe o login';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _loginSenhaController,
            decoration: const InputDecoration(
              labelText: 'Senha',
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe a senha';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _fazerLogin,
              child: const Text('Entrar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCadastroForm() {
    return Form(
      key: _formKeyCadastro,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: _cadastroNomeController,
              decoration: const InputDecoration(
                labelText: 'Nome Completo',
                prefixIcon: Icon(Icons.badge),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe o nome';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cadastroUsuarioController,
              decoration: const InputDecoration(
                labelText: 'Login',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe o login';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cadastroSenhaController,
              decoration: const InputDecoration(
                labelText: 'Senha',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe a senha';
                }
                if (value.length < 4) {
                  return 'Mínimo de 4 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cadastroConfirmaSenhaController,
              decoration: const InputDecoration(
                labelText: 'Repetir Senha',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirme a senha';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _tipoSelecionado,
              decoration: const InputDecoration(
                labelText: 'Função',
                prefixIcon: Icon(Icons.work),
              ),
              items: const [
                DropdownMenuItem(value: 'ADMIN', child: Text('Administrador')),
                DropdownMenuItem(value: 'MEMBRO', child: Text('Membro')),
              ],
              onChanged: (value) {
                setState(() {
                  _tipoSelecionado = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _fazerCadastro,
                child: const Text('Cadastrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

