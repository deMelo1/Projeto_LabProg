import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/movimentacao_estoque.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/confirm_dialog.dart';
import '../../utils/snackbar_utils.dart';
import '../../globals.dart' as globals;
import 'package:intl/intl.dart';

class HistoricoEstoquePage extends StatefulWidget {
  const HistoricoEstoquePage({super.key});

  @override
  State<HistoricoEstoquePage> createState() => _HistoricoEstoquePageState();
}

class _HistoricoEstoquePageState extends State<HistoricoEstoquePage> {
  List<MovimentacaoEstoque> _movimentacoes = [];
  List<MovimentacaoEstoque> _movimentacoesFiltradas = [];
  bool _loading = true;
  
  final _searchController = TextEditingController();
  String? _tipoFiltro;
  DateTime? _dataInicio;
  DateTime? _dataFim;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
    _startAutoRefresh();
  }
  
  Timer? _autoRefreshTimer;
  
  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted) {
        _carregarHistorico(silencioso: true);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _carregarHistorico({bool silencioso = false}) async {
    if (!silencioso) {
      setState(() => _loading = true);
    }
    
    try {
      final data = await ApiService.getMovimentacoesEstoque();
      setState(() {
        _movimentacoes = data.map((json) => MovimentacaoEstoque.fromJson(json)).toList();
        _aplicarFiltros();
        _loading = false;
      });
      
      if (silencioso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Dados atualizados'),
              ],
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8),
          ),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      if (!silencioso) {
        SnackbarUtils.showError(context, 'Erro ao carregar histórico');
      }
    }
  }

  void _aplicarFiltros() {
    setState(() {
      _movimentacoesFiltradas = _movimentacoes.where((mov) {
        // Filtro de busca
        if (_searchController.text.isNotEmpty) {
          final busca = _searchController.text.toLowerCase();
          final item = mov.itemNome.toLowerCase();
          final membro = mov.membro.toLowerCase();
          if (!item.contains(busca) && !membro.contains(busca)) {
            return false;
          }
        }
        
        // Filtro de tipo
        if (_tipoFiltro != null && mov.tipo != _tipoFiltro) {
          return false;
        }
        
        // Filtro de data
        if (_dataInicio != null || _dataFim != null) {
          try {
            final dataMovimentacao = DateFormat('yyyy-MM-dd').parse(mov.data);
            if (_dataInicio != null && dataMovimentacao.isBefore(_dataInicio!)) {
              return false;
            }
            if (_dataFim != null && dataMovimentacao.isAfter(_dataFim!.add(const Duration(days: 1)))) {
              return false;
            }
          } catch (e) {
            // Ignora erro de parsing
          }
        }
        
        return true;
      }).toList();
    });
  }

  void _limparFiltros() {
    setState(() {
      _searchController.clear();
      _tipoFiltro = null;
      _dataInicio = null;
      _dataFim = null;
      _aplicarFiltros();
    });
  }

  Future<void> _selecionarDataInicio() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataInicio ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    
    if (data != null) {
      setState(() {
        _dataInicio = data;
        _aplicarFiltros();
      });
    }
  }

  Future<void> _selecionarDataFim() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataFim ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    
    if (data != null) {
      setState(() {
        _dataFim = data;
        _aplicarFiltros();
      });
    }
  }

  Future<void> _deletarMovimentacao(MovimentacaoEstoque mov) async {
    final confirmar = await ConfirmDialog.show(
      context,
      title: 'Excluir Movimentação',
      message: 'Você tem certeza que deseja excluir esta movimentação? Esta exclusão é irreversível e reverterá o estoque.',
      confirmText: 'Excluir',
      isDangerous: true,
    );

    if (!confirmar) return;

    LoadingOverlay.show(context, message: 'Excluindo...');

    try {
      final resultado = await ApiService.deletarMovimentacao(mov.id);
      
      if (!mounted) return;
      LoadingOverlay.hide(context);

      if (resultado['success'] == true) {
        if (resultado['warning'] == true) {
          SnackbarUtils.showInfo(context, resultado['message'] ?? 'Movimentação excluída');
        } else {
          SnackbarUtils.showSuccess(context, 'Movimentação excluída com sucesso');
        }
        _carregarHistorico();
      } else {
        SnackbarUtils.showError(context, resultado['message'] ?? 'Erro ao excluir movimentação');
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
        title: const Text('Histórico de Movimentações'),
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
                    hintText: 'Item, membro...',
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
                
                // Filtros de tipo e datas
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _tipoFiltro,
                        decoration: const InputDecoration(
                          labelText: 'Tipo',
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Todos')),
                          DropdownMenuItem(value: 'ENTRADA', child: Text('Entrada')),
                          DropdownMenuItem(value: 'SAIDA', child: Text('Saída')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _tipoFiltro = value;
                            _aplicarFiltros();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: _selecionarDataInicio,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'De',
                            isDense: true,
                          ),
                          child: Text(
                            _dataInicio != null
                                ? DateFormat('dd/MM/yy').format(_dataInicio!)
                                : '-',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: _selecionarDataFim,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Até',
                            isDense: true,
                          ),
                          child: Text(
                            _dataFim != null
                                ? DateFormat('dd/MM/yy').format(_dataFim!)
                                : '-',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
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
          
          // Lista de movimentações
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _movimentacoesFiltradas.isEmpty
                    ? Center(
                        child: Text(
                          'Nenhuma movimentação encontrada',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _carregarHistorico,
                        color: Colors.blue,
                        backgroundColor: Colors.white,
                        strokeWidth: 3.0,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _movimentacoesFiltradas.length,
                          itemBuilder: (context, index) {
                            final mov = _movimentacoesFiltradas[index];
                            final isEntrada = mov.isEntrada;
                            
                            final isCadastroInicial = mov.obs == 'Cadastro inicial do item';
                            
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isEntrada
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.red.withOpacity(0.2),
                                  child: Icon(
                                    isEntrada ? Icons.arrow_downward : Icons.arrow_upward,
                                    color: isEntrada ? Colors.green : Colors.red,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        mov.itemNome,
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    if (isCadastroInicial)
                                      Tooltip(
                                        message: 'Cadastro inicial não pode ser excluído',
                                        child: Icon(
                                          Icons.lock,
                                          size: 16,
                                          color: Colors.orange[700],
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Responsável: ${mov.membro}'),
                                    Text('Quantidade: ${mov.quantidade}'),
                                    Text('Data: ${DateFormat('dd/MM/yyyy').format(DateFormat('yyyy-MM-dd').parse(mov.data))}'),
                                    if (mov.obs != null && mov.obs!.isNotEmpty)
                                      Text(
                                        'Obs: ${mov.obs}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isCadastroInicial ? Colors.orange[700] : Colors.grey[600],
                                          fontWeight: isCadastroInicial ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                  ],
                                ),
                                isThreeLine: true,
                                trailing: globals.canDelete()
                                    ? (isCadastroInicial
                                        ? Tooltip(
                                            message: 'Cadastro inicial\nnão pode ser excluído',
                                            child: Icon(Icons.lock, color: Colors.grey[400]),
                                          )
                                        : IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _deletarMovimentacao(mov),
                                          ))
                                    : Chip(
                                        label: Text(
                                          isEntrada ? 'ENTRADA' : 'SAÍDA',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        backgroundColor: isEntrada
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
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

