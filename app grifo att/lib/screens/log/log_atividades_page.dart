import 'package:flutter/material.dart';
import '../../models/log_atividade.dart';
import '../../services/api_service.dart';
import '../../utils/snackbar_utils.dart';

class LogAtividadesPage extends StatefulWidget {
  const LogAtividadesPage({super.key});

  @override
  State<LogAtividadesPage> createState() => _LogAtividadesPageState();
}

class _LogAtividadesPageState extends State<LogAtividadesPage> {
  List<LogAtividade> _logs = [];
  List<LogAtividade> _logsFiltrados = [];
  bool _loading = true;
  
  final _searchController = TextEditingController();
  String? _tipoFiltro;

  @override
  void initState() {
    super.initState();
    _carregarLogs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarLogs() async {
    setState(() => _loading = true);
    
    try {
      final data = await ApiService.getLogAtividades();
      setState(() {
        _logs = data.map((json) => LogAtividade.fromJson(json)).toList();
        _aplicarFiltros();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Erro ao carregar logs');
    }
  }

  void _aplicarFiltros() {
    setState(() {
      _logsFiltrados = _logs.where((log) {
        // Filtro de busca
        if (_searchController.text.isNotEmpty) {
          final busca = _searchController.text.toLowerCase();
          if (!log.acao.toLowerCase().contains(busca) && 
              !log.usuarioNome.toLowerCase().contains(busca) &&
              !log.detalhes.toLowerCase().contains(busca)) {
            return false;
          }
        }
        
        // Filtro de tipo
        if (_tipoFiltro != null && log.tipoEntidade != _tipoFiltro) {
          return false;
        }
        
        return true;
      }).toList();
    });
  }

  void _limparFiltros() {
    setState(() {
      _searchController.clear();
      _tipoFiltro = null;
      _aplicarFiltros();
    });
  }

  IconData _getIconForTipo(String tipo) {
    switch (tipo) {
      case 'ESTOQUE':
        return Icons.inventory_2;
      case 'CAUTELA':
        return Icons.fact_check;
      case 'USUARIO':
        return Icons.person;
      case 'ITEM':
        return Icons.category;
      default:
        return Icons.circle;
    }
  }

  Color _getColorForTipo(String tipo) {
    switch (tipo) {
      case 'ESTOQUE':
        return Colors.blue;
      case 'CAUTELA':
        return Colors.green;
      case 'USUARIO':
        return Colors.orange;
      case 'ITEM':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log de Atividades do Sistema'),
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Busca
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar',
                    hintText: 'Ação, usuário, detalhes...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _aplicarFiltros();
                            },
                          )
                        : null,
                  ),
                  onChanged: (_) => _aplicarFiltros(),
                ),
                const SizedBox(height: 12),
                
                // Filtro de tipo
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _tipoFiltro,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Entidade',
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Todas')),
                          DropdownMenuItem(value: 'ESTOQUE', child: Text('Estoque')),
                          DropdownMenuItem(value: 'CAUTELA', child: Text('Cautela')),
                          DropdownMenuItem(value: 'USUARIO', child: Text('Usuário')),
                          DropdownMenuItem(value: 'ITEM', child: Text('Item')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _tipoFiltro = value;
                            _aplicarFiltros();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Botão limpar filtros
                TextButton.icon(
                  onPressed: _limparFiltros,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Limpar Filtros'),
                ),
              ],
            ),
          ),
          
          // Lista de logs
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _logsFiltrados.isEmpty
                    ? Center(
                        child: Text(
                          'Nenhum log encontrado',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _carregarLogs,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _logsFiltrados.length,
                          itemBuilder: (context, index) {
                            final log = _logsFiltrados[index];
                            final cor = _getColorForTipo(log.tipoEntidade);
                            
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: cor.withOpacity(0.2),
                                  child: Icon(
                                    _getIconForTipo(log.tipoEntidade),
                                    color: cor,
                                  ),
                                ),
                                title: Text(
                                  log.acao,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Usuário: ${log.usuarioNome}'),
                                    Text('Detalhes: ${log.detalhes}'),
                                    Text(
                                      'Data/Hora: ${log.dataHora}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
                                trailing: Chip(
                                  label: Text(
                                    log.tipoEntidade,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  backgroundColor: cor.withOpacity(0.1),
                                  side: BorderSide(color: cor, width: 1),
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

