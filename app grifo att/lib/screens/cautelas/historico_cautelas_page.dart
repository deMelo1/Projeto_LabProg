import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/cautela.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/confirm_dialog.dart';
import '../../utils/snackbar_utils.dart';
import '../../globals.dart' as globals;
import 'package:intl/intl.dart';

class HistoricoCautelasPage extends StatefulWidget {
  const HistoricoCautelasPage({super.key});

  @override
  State<HistoricoCautelasPage> createState() => _HistoricoCautelasPageState();
}

class _HistoricoCautelasPageState extends State<HistoricoCautelasPage> {
  List<Cautela> _cautelas = [];
  List<Cautela> _cautelasFiltradas = [];
  bool _loading = true;
  
  final _searchController = TextEditingController();
  String? _statusFiltro;
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
      final data = await ApiService.getCautelas();
      setState(() {
        _cautelas = data.map((json) => Cautela.fromJson(json)).toList();
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
      _cautelasFiltradas = _cautelas.where((c) {
        if (_searchController.text.isNotEmpty) {
          final busca = _searchController.text.toLowerCase();
          if (!c.itemNome.toLowerCase().contains(busca) && !c.paraQuem.toLowerCase().contains(busca)) return false;
        }
        if (_statusFiltro != null && c.status != _statusFiltro) return false;
        if (_dataInicio != null || _dataFim != null) {
          try {
            final data = DateFormat('yyyy-MM-dd').parse(c.dataCautela);
            if (_dataInicio != null && data.isBefore(_dataInicio!)) return false;
            if (_dataFim != null && data.isAfter(_dataFim!.add(const Duration(days: 1)))) return false;
          } catch (e) {}
        }
        return true;
      }).toList();
    });
  }

  void _limparFiltros() {
    setState(() {
      _searchController.clear();
      _statusFiltro = null;
      _dataInicio = null;
      _dataFim = null;
      _aplicarFiltros();
    });
  }

  Future<void> _deletarCautela(Cautela cautela) async {
    final confirmar = await ConfirmDialog.show(
      context,
      title: 'Excluir Cautela',
      message: 'Você tem certeza? Esta exclusão é irreversível.',
      confirmText: 'Excluir',
      isDangerous: true,
    );

    if (!confirmar) return;

    LoadingOverlay.show(context, message: 'Excluindo...');

    try {
      final resultado = await ApiService.deletarCautela(cautela.id);
      
      if (!mounted) return;
      LoadingOverlay.hide(context);

      if (resultado['success'] == true) {
        SnackbarUtils.showSuccess(context, 'Cautela excluída com sucesso');
        _carregarHistorico();
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
      appBar: AppBar(title: const Text('Histórico de Cautelas')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); _aplicarFiltros(); }) : null,
                  ),
                  onChanged: (_) => _aplicarFiltros(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _statusFiltro,
                        decoration: const InputDecoration(labelText: 'Status', isDense: true),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Todos')),
                          DropdownMenuItem(value: 'ATIVA', child: Text('Ativa')),
                          DropdownMenuItem(value: 'DEVOLVIDA', child: Text('Devolvida')),
                        ],
                        onChanged: (v) { setState(() { _statusFiltro = v; _aplicarFiltros(); }); },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton.icon(onPressed: _limparFiltros, icon: const Icon(Icons.clear_all), label: const Text('Limpar Filtros')),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _cautelasFiltradas.isEmpty
                    ? Center(child: Text('Nenhuma cautela encontrada', style: TextStyle(color: Colors.grey[600])))
                    : RefreshIndicator(
                        onRefresh: _carregarHistorico,
                        color: Colors.blue,
                        backgroundColor: Colors.white,
                        strokeWidth: 3.0,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _cautelasFiltradas.length,
                          itemBuilder: (context, index) {
                            final c = _cautelasFiltradas[index];
                            final isAtiva = c.isAtiva;
                            
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isAtiva ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                                  child: Icon(isAtiva ? Icons.access_time : Icons.check, color: isAtiva ? Colors.red : Colors.green),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(c.itemNome, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    ),
                                    if (isAtiva)
                                      Tooltip(
                                        message: 'Cautelas ativas não podem ser excluídas',
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
                                    Text('Responsável: ${c.membro}'),
                                    Text('Para: ${c.paraQuem}'),
                                    Row(
                                      children: [
                                        Text('Qtd: ${c.quantidade} | Status: '),
                                        Text(
                                          c.status,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: isAtiva ? Colors.red[700] : Colors.green[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text('Cautela: ${DateFormat('dd/MM/yyyy').format(DateFormat('yyyy-MM-dd').parse(c.dataCautela))}'),
                                    if (c.dataDevolucao != null) Text('Devolução: ${DateFormat('dd/MM/yyyy').format(DateFormat('yyyy-MM-dd').parse(c.dataDevolucao!))}'),
                                  ],
                                ),
                                isThreeLine: true,
                                trailing: globals.canDelete() 
                                    ? (isAtiva 
                                        ? Tooltip(
                                            message: 'Cautela ativa\nnão pode ser excluída.\nDevolva primeiro.',
                                            child: Icon(Icons.lock, color: Colors.grey[400]),
                                          )
                                        : IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red), 
                                            onPressed: () => _deletarCautela(c),
                                          ))
                                    : null,
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

