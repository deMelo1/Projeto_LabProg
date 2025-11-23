import 'package:flutter/material.dart';
import '../../models/item_estoque.dart';
import '../../services/api_service.dart';
import '../../utils/snackbar_utils.dart';

class InventarioPage extends StatefulWidget {
  const InventarioPage({super.key});

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  List<ItemEstoque> _itens = [];
  List<ItemEstoque> _itensFiltrados = [];
  bool _loading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarItens();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarItens() async {
    setState(() => _loading = true);
    
    try {
      final data = await ApiService.getItensEstoque();
      setState(() {
        _itens = data.map((json) => ItemEstoque.fromJson(json)).toList();
        _itensFiltrados = _itens;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Erro ao carregar inventário');
    }
  }

  void _filtrar(String query) {
    setState(() {
      if (query.isEmpty) {
        _itensFiltrados = _itens;
      } else {
        _itensFiltrados = _itens.where((item) {
          final nome = item.nome.toLowerCase();
          final categoria = (item.categoria ?? '').toLowerCase();
          final busca = query.toLowerCase();
          return nome.contains(busca) || categoria.contains(busca);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventário de Estoque'),
      ),
      body: Column(
        children: [
          // Campo de busca
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar item',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filtrar('');
                        },
                      )
                    : null,
              ),
              onChanged: _filtrar,
            ),
          ),
          
          // Lista de itens
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _itensFiltrados.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? 'Nenhum item no inventário'
                              : 'Nenhum resultado encontrado',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _carregarItens,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _itensFiltrados.length,
                          itemBuilder: (context, index) {
                            final item = _itensFiltrados[index];
                            final estoqueColor = item.quantidadeAtual <= 5
                                ? Colors.red
                                : item.quantidadeAtual <= 10
                                    ? Colors.orange
                                    : Colors.green;
                            
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: estoqueColor.withOpacity(0.2),
                                  child: Text(
                                    '${item.quantidadeAtual}',
                                    style: TextStyle(
                                      color: estoqueColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  item.nome,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (item.categoria != null)
                                      Text('Categoria: ${item.categoria}'),
                                    if (item.descricao != null && item.descricao!.isNotEmpty)
                                      Text(
                                        item.descricao!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                      ),
                                  ],
                                ),
                                trailing: Chip(
                                  label: Text(
                                    'Qtd: ${item.quantidadeAtual}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  backgroundColor: estoqueColor.withOpacity(0.1),
                                  side: BorderSide(color: estoqueColor, width: 1),
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

