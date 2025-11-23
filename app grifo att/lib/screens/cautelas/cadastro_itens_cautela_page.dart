import 'package:flutter/material.dart';
import '../../models/item_cautela.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/confirm_dialog.dart';
import '../../utils/snackbar_utils.dart';
import '../../globals.dart' as globals;

class CadastroItensCautelaPage extends StatefulWidget {
  const CadastroItensCautelaPage({super.key});

  @override
  State<CadastroItensCautelaPage> createState() => _CadastroItensCautelaPageState();
}

class _CadastroItensCautelaPageState extends State<CadastroItensCautelaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController(text: '1');
  final _categoriaController = TextEditingController();
  final _descricaoController = TextEditingController();

  List<ItemCautela> _itens = [];
  Map<int, int> _quantidadesCauteladas = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregarItens();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeController.dispose();
    _categoriaController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _carregarItens() async {
    setState(() => _loading = true);
    
    try {
      final data = await ApiService.getItensCautela();
      final itens = data.map((json) => ItemCautela.fromJson(json)).toList();
      
      // Carregar quantidades cauteladas
      final Map<int, int> quantidades = {};
      for (var item in itens) {
        try {
          final qtd = await ApiService.getQuantidadeCautelada(item.id);
          quantidades[item.id] = qtd;
        } catch (e) {
          quantidades[item.id] = 0;
        }
      }
      
      setState(() {
        _itens = itens;
        _quantidadesCauteladas = quantidades;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Erro ao carregar itens');
    }
  }

  Future<void> _cadastrarItem() async {
    if (!_formKey.currentState!.validate()) return;

    final item = {
      'nome': _nomeController.text.trim(),
      'quantidadeTotal': int.parse(_quantidadeController.text),
      'categoria': _categoriaController.text.trim().isEmpty ? null : _categoriaController.text.trim(),
      'descricao': _descricaoController.text.trim().isEmpty ? null : _descricaoController.text.trim(),
    };

    LoadingOverlay.show(context, message: 'Cadastrando item...');

    try {
      final resultado = await ApiService.cadastrarItemCautela(item);
      
      if (!mounted) return;
      LoadingOverlay.hide(context);

      if (resultado['success'] == true) {
        SnackbarUtils.showSuccess(context, 'Item cadastrado com sucesso!');
        
        _nomeController.clear();
        _quantidadeController.text = '1';
        _categoriaController.clear();
        _descricaoController.clear();
        
        _carregarItens();
      } else {
        SnackbarUtils.showError(context, resultado['message'] ?? 'Erro ao cadastrar item');
      }
    } catch (e) {
      if (!mounted) return;
      LoadingOverlay.hide(context);
      SnackbarUtils.showError(context, 'Erro ao conectar com o servidor');
    }
  }

  Future<void> _deletarItem(ItemCautela item) async {
    final confirmar = await ConfirmDialog.show(
      context,
      title: 'Excluir Item',
      message: 'Você tem certeza que deseja excluir "${item.nome}"? Esta exclusão é irreversível.',
      confirmText: 'Excluir',
      isDangerous: true,
    );

    if (!confirmar) return;

    LoadingOverlay.show(context, message: 'Excluindo...');

    try {
      final resultado = await ApiService.deletarItemCautela(item.id);
      
      if (!mounted) return;
      LoadingOverlay.hide(context);

      if (resultado['success'] == true) {
        SnackbarUtils.showSuccess(context, 'Item excluído com sucesso');
        _carregarItens();
      } else {
        SnackbarUtils.showError(context, resultado['message'] ?? 'Erro ao excluir item');
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
        title: const Text('Cadastro de Itens Cauteláveis'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Novo Item', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(labelText: 'Nome do Item *', hintText: 'Ex: Violão, Bola de Futsal'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Informe o nome' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _quantidadeController,
                              decoration: const InputDecoration(labelText: 'Quantidade Total'),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Informe';
                                if (int.tryParse(v) == null || int.parse(v) < 1) return 'Mínimo 1';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _categoriaController,
                              decoration: const InputDecoration(labelText: 'Categoria', hintText: 'Ex: Instrumentos'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descricaoController,
                        decoration: const InputDecoration(labelText: 'Descrição'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _cadastrarItem,
                          icon: const Icon(Icons.add),
                          label: const Text('Cadastrar Item'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            const Text('Itens Cadastrados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            if (_loading)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else if (_itens.isEmpty)
              const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Nenhum item cadastrado'))))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _itens.length,
                itemBuilder: (context, index) {
                  final item = _itens[index];
                  final cautelada = _quantidadesCauteladas[item.id] ?? 0;
                  final disponivel = item.quantidadeTotal - cautelada;
                  
                  return Card(
                    child: ListTile(
                      title: Text(item.nome, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total: ${item.quantidadeTotal} | Cautelada: $cautelada | Disponível: $disponivel'),
                          if (item.categoria != null) Text('Categoria: ${item.categoria}'),
                        ],
                      ),
                      trailing: globals.canDelete()
                          ? IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deletarItem(item))
                          : null,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

