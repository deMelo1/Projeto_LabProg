import 'package:flutter/material.dart';
import '../../models/usuario.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/confirm_dialog.dart';
import '../../utils/snackbar_utils.dart';

class GestaoUsuariosPage extends StatefulWidget {
  const GestaoUsuariosPage({super.key});

  @override
  State<GestaoUsuariosPage> createState() => _GestaoUsuariosPageState();
}

class _GestaoUsuariosPageState extends State<GestaoUsuariosPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<Usuario> _pendentes = [];
  List<Usuario> _usuarios = [];
  bool _loadingPendentes = true;
  bool _loadingUsuarios = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _carregarDados();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    _carregarPendentes();
    _carregarUsuarios();
  }

  Future<void> _carregarPendentes() async {
    setState(() => _loadingPendentes = true);
    
    try {
      final data = await ApiService.getCadastrosPendentes();
      setState(() {
        _pendentes = data.map((json) => Usuario.fromJson(json)).toList();
        _loadingPendentes = false;
      });
    } catch (e) {
      setState(() => _loadingPendentes = false);
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Erro ao carregar cadastros pendentes');
    }
  }

  Future<void> _carregarUsuarios() async {
    setState(() => _loadingUsuarios = true);
    
    try {
      final data = await ApiService.getUsuarios();
      setState(() {
        _usuarios = data.map((json) => Usuario.fromJson(json)).toList();
        _loadingUsuarios = false;
      });
    } catch (e) {
      setState(() => _loadingUsuarios = false);
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Erro ao carregar usuários');
    }
  }

  Future<void> _aprovarCadastro(Usuario usuario) async {
    LoadingOverlay.show(context, message: 'Aprovando...');

    try {
      final resultado = await ApiService.aprovarCadastro(usuario.id);
      
      if (!mounted) return;
      LoadingOverlay.hide(context);

      if (resultado['success'] == true) {
        SnackbarUtils.showSuccess(context, 'Cadastro aprovado com sucesso');
        _carregarDados();
      } else {
        SnackbarUtils.showError(context, resultado['message'] ?? 'Erro ao aprovar');
      }
    } catch (e) {
      if (!mounted) return;
      LoadingOverlay.hide(context);
      SnackbarUtils.showError(context, 'Erro ao conectar com o servidor');
    }
  }

  Future<void> _rejeitarCadastro(Usuario usuario) async {
    final confirmar = await ConfirmDialog.show(
      context,
      title: 'Rejeitar Cadastro',
      message: 'Rejeitar cadastro de ${usuario.nome}?',
      confirmText: 'Rejeitar',
      isDangerous: true,
    );

    if (!confirmar) return;

    LoadingOverlay.show(context, message: 'Rejeitando...');

    try {
      final resultado = await ApiService.rejeitarCadastro(usuario.id);
      
      if (!mounted) return;
      LoadingOverlay.hide(context);

      if (resultado['success'] == true) {
        SnackbarUtils.showSuccess(context, 'Cadastro rejeitado');
        _carregarDados();
      } else {
        SnackbarUtils.showError(context, resultado['message'] ?? 'Erro ao rejeitar');
      }
    } catch (e) {
      if (!mounted) return;
      LoadingOverlay.hide(context);
      SnackbarUtils.showError(context, 'Erro ao conectar com o servidor');
    }
  }

  Future<void> _deletarUsuario(Usuario usuario) async {
    final confirmar = await ConfirmDialog.show(
      context,
      title: 'Excluir Usuário',
      message: 'Você tem certeza que deseja excluir ${usuario.nome}? Esta exclusão é irreversível.',
      confirmText: 'Excluir',
      isDangerous: true,
    );

    if (!confirmar) return;

    LoadingOverlay.show(context, message: 'Excluindo...');

    try {
      final resultado = await ApiService.deletarUsuario(usuario.id);
      
      if (!mounted) return;
      LoadingOverlay.hide(context);

      if (resultado['success'] == true) {
        SnackbarUtils.showSuccess(context, 'Usuário excluído com sucesso');
        _carregarDados();
      } else {
        SnackbarUtils.showError(context, resultado['message'] ?? 'Erro ao excluir');
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
      appBar: AppBar(
        title: const Text('Gestão de Usuários'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Aprovação de Cadastros'),
            Tab(text: 'Gerenciar Usuários'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAprovacaoTab(),
          _buildGestaoTab(),
        ],
      ),
    );
  }

  Widget _buildAprovacaoTab() {
    return _loadingPendentes
        ? const Center(child: CircularProgressIndicator())
        : _pendentes.isEmpty
            ? Center(child: Text('Nenhum cadastro pendente', style: TextStyle(color: Colors.grey[600])))
            : RefreshIndicator(
                onRefresh: _carregarPendentes,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendentes.length,
                  itemBuilder: (context, index) {
                    final user = _pendentes[index];
                    
                    return Card(
                      child: ListTile(
                        title: Text(user.nome, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('Login: ${user.login}\nTipo: ${user.tipoFormatado}'),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _aprovarCadastro(user),
                              tooltip: 'Aprovar',
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _rejeitarCadastro(user),
                              tooltip: 'Rejeitar',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
  }

  Widget _buildGestaoTab() {
    return _loadingUsuarios
        ? const Center(child: CircularProgressIndicator())
        : _usuarios.isEmpty
            ? Center(child: Text('Nenhum usuário cadastrado', style: TextStyle(color: Colors.grey[600])))
            : RefreshIndicator(
                onRefresh: _carregarUsuarios,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _usuarios.length,
                  itemBuilder: (context, index) {
                    final user = _usuarios[index];
                    
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(user.nome.substring(0, 1).toUpperCase()),
                        ),
                        title: Text(user.nome, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('Login: ${user.login}\nTipo: ${user.tipoFormatado}\nStatus: ${user.aprovado ? "Aprovado" : "Pendente"}'),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deletarUsuario(user),
                        ),
                      ),
                    );
                  },
                ),
              );
  }
}

