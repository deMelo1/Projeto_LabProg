import 'package:flutter/material.dart';
import '../../models/item_estoque.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_overlay.dart';
import '../../utils/snackbar_utils.dart';
import 'package:intl/intl.dart';

class MovimentacaoEstoquePage extends StatefulWidget {
  const MovimentacaoEstoquePage({super.key});

  @override
  State<MovimentacaoEstoquePage> createState() => _MovimentacaoEstoquePageState();
}

class _MovimentacaoEstoquePageState extends State<MovimentacaoEstoquePage> {
  final _formKey = GlobalKey<FormState>();
  
  String _tipo = 'ENTRADA';
  ItemEstoque? _itemSelecionado;
  final _quantidadeController = TextEditingController();
  final _obsController = TextEditingController();
  DateTime _dataSelecionada = DateTime.now();
  
  List<ItemEstoque> _itens = [];
  bool _loadingItens = true;
  int? _estoqueDisponivel;

  @override
  void initState() {
    super.initState();
    _carregarItens();
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _carregarItens() async {
    try {
      final data = await ApiService.getItensEstoque();
      setState(() {
        _itens = data.map((json) => ItemEstoque.fromJson(json)).toList();
        _loadingItens = false;
      });
    } catch (e) {
      setState(() => _loadingItens = false);
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Erro ao carregar itens');
    }
  }

  void _atualizarEstoqueDisponivel() {
    if (_itemSelecionado != null) {
      setState(() {
        _estoqueDisponivel = _itemSelecionado!.quantidadeAtual;
      });
    }
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    
    if (data != null) {
      setState(() {
        _dataSelecionada = data;
      });
    }
  }

  Future<void> _registrarMovimentacao() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_itemSelecionado == null) {
      SnackbarUtils.showError(context, 'Selecione um item');
      return;
    }

    final quantidade = int.parse(_quantidadeController.text);

    // Validação de estoque para saída
    if (_tipo == 'SAIDA' && quantidade > (_estoqueDisponivel ?? 0)) {
      SnackbarUtils.showError(
        context,
        'Quantidade insuficiente em estoque! Disponível: $_estoqueDisponivel',
      );
      return;
    }

    final movimentacao = {
      'itemId': _itemSelecionado!.id,
      'tipo': _tipo,
      'quantidade': quantidade,
      'data': DateFormat('yyyy-MM-dd').format(_dataSelecionada),
      'obs': _obsController.text.trim().isEmpty ? null : _obsController.text.trim(),
    };

    LoadingOverlay.show(context, message: 'Registrando movimentação...');

    try {
      final resultado = await ApiService.registrarMovimentacao(movimentacao);
      
      if (!mounted) return;
      LoadingOverlay.hide(context);

      if (resultado['success'] == true) {
        SnackbarUtils.showSuccess(context, 'Movimentação registrada com sucesso!');
        
        // Limpa os campos
        setState(() {
          _itemSelecionado = null;
          _quantidadeController.clear();
          _obsController.clear();
          _dataSelecionada = DateTime.now();
          _estoqueDisponivel = null;
        });
        
        // Recarrega os itens para atualizar quantidades
        _carregarItens();
      } else {
        SnackbarUtils.showError(context, resultado['message'] ?? 'Erro ao registrar movimentação');
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
        title: const Text('Registrar Movimentação'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tipo de movimentação
              const Text(
                'Tipo de Movimentação',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Entrada'),
                      value: 'ENTRADA',
                      groupValue: _tipo,
                      onChanged: (value) {
                        setState(() {
                          _tipo = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Saída'),
                      value: 'SAIDA',
                      groupValue: _tipo,
                      onChanged: (value) {
                        setState(() {
                          _tipo = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Seleção de item
              DropdownButtonFormField<ItemEstoque>(
                value: _itemSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Item *',
                  hintText: 'Selecione um item',
                ),
                items: _itens.map((item) {
                  return DropdownMenuItem<ItemEstoque>(
                    value: item,
                    child: Text(item.nome),
                  );
                }).toList(),
                onChanged: _loadingItens
                    ? null
                    : (value) {
                        setState(() {
                          _itemSelecionado = value;
                        });
                        _atualizarEstoqueDisponivel();
                      },
                validator: (value) {
                  if (value == null) return 'Selecione um item';
                  return null;
                },
              ),
              
              if (_estoqueDisponivel != null && _tipo == 'SAIDA')
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    'Estoque disponível: $_estoqueDisponivel',
                    style: TextStyle(
                      fontSize: 12,
                      color: _estoqueDisponivel! > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Quantidade
              TextFormField(
                controller: _quantidadeController,
                decoration: const InputDecoration(
                  labelText: 'Quantidade *',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a quantidade';
                  }
                  final quantidade = int.tryParse(value);
                  if (quantidade == null || quantidade <= 0) {
                    return 'Quantidade inválida';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Data
              InkWell(
                onTap: _selecionarData,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(_dataSelecionada),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Observações
              TextFormField(
                controller: _obsController,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  hintText: 'Informações adicionais',
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 24),
              
              // Botão de salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _registrarMovimentacao,
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar Movimentação'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

