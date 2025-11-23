import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/socio.dart';
import '../../services/api_service.dart';
import '../../utils/snackbar_utils.dart';
import '../../widgets/confirm_dialog.dart';

class GestaoSociosPage extends StatefulWidget {
  const GestaoSociosPage({super.key});

  @override
  State<GestaoSociosPage> createState() => _GestaoSociosPageState();
}

class _GestaoSociosPageState extends State<GestaoSociosPage> {
  List<Socio> _socios = [];
  List<Socio> _sociosFiltrados = [];
  bool _loading = true;
  final TextEditingController _buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarSocios();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarSocios() async {
    setState(() => _loading = true);

    try {
      final response = await ApiService.get('/socios');
      final List<dynamic> data = jsonDecode(response.body);
      
      setState(() {
        _socios = data.map((json) => Socio.fromJson(json)).toList();
        _sociosFiltrados = _socios;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        SnackbarUtils.showError(context, 'Erro ao carregar sócios: $e');
      }
    }
  }

  void _filtrarSocios(String query) {
    setState(() {
      if (query.isEmpty) {
        _sociosFiltrados = _socios;
      } else {
        _sociosFiltrados = _socios.where((socio) {
          return socio.nome.toLowerCase().contains(query.toLowerCase()) ||
              socio.cpf.contains(query) ||
              socio.turma.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _deletarSocio(Socio socio) async {
    final confirm = await ConfirmDialog.show(
      context,
      title: 'Excluir Sócio',
      message: 'Tem certeza que deseja excluir "${socio.nome}"?',
      confirmText: 'Excluir',
      cancelText: 'Cancelar',
    );

    if (confirm) {
      try {
        final response = await ApiService.delete('/socios/${socio.id}');
        
        if (!mounted) return;

        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          SnackbarUtils.showSuccess(context, 'Sócio excluído com sucesso');
          _carregarSocios();
        } else {
          SnackbarUtils.showError(context, data['message'] ?? 'Erro ao excluir');
        }
      } catch (e) {
        if (!mounted) return;
        SnackbarUtils.showError(context, 'Erro: $e');
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ATIVO':
        return Colors.green;
      case 'PROXIMO_VENCIMENTO':
        return Colors.orange;
      case 'ATRASADO':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'ATIVO':
        return 'ATIVO';
      case 'PROXIMO_VENCIMENTO':
        return 'PRÓX. VENCER';
      case 'ATRASADO':
        return 'ATRASADO';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Sócios'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _buscaController,
              decoration: InputDecoration(
                hintText: 'Buscar por nome, CPF ou turma...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _buscaController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _buscaController.clear();
                          _filtrarSocios('');
                        },
                      )
                    : null,
              ),
              onChanged: _filtrarSocios,
            ),
          ),
          
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _sociosFiltrados.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum sócio encontrado',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _carregarSocios,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _sociosFiltrados.length,
                          itemBuilder: (context, index) {
                            final socio = _sociosFiltrados[index];
                            final fimFiliacao = DateTime.parse(socio.fimFiliacao);
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(
                                  socio.nome,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text('CPF: ${socio.cpf}'),
                                    Text('Turma: ${socio.turma}'),
                                    Text('Vencimento: ${fimFiliacao.day.toString().padLeft(2, '0')}/${fimFiliacao.month.toString().padLeft(2, '0')}/${fimFiliacao.year}'),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(socio.status),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _getStatusLabel(socio.status),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deletarSocio(socio),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

