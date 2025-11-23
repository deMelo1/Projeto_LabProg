import 'package:flutter/material.dart';
import '../../models/item_cautela.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_overlay.dart';
import '../../utils/snackbar_utils.dart';
import 'package:intl/intl.dart';

class NovaCautelaPage extends StatefulWidget {
  const NovaCautelaPage({super.key});

  @override
  State<NovaCautelaPage> createState() => _NovaCautelaPageState();
}

class _NovaCautelaPageState extends State<NovaCautelaPage> {
  final _formKey = GlobalKey<FormState>();
  
  ItemCautela? _itemSelecionado;
  final _quantidadeController = TextEditingController(text: '1');
  final _paraQuemController = TextEditingController();
  final _obsController = TextEditingController();
  DateTime _dataSelecionada = DateTime.now();
  
  List<ItemCautela> _itens = [];
  bool _loadingItens = true;
  int? _disponiveis;

  @override
  void initState() {
    super.initState();
    _carregarItens();
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    _paraQuemController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _carregarItens() async {
    try {
      final data = await ApiService.getItensCautela();
      setState(() {
        _itens = data.map((json) => ItemCautela.fromJson(json)).toList();
        _loadingItens = false;
      });
    } catch (e) {
      setState(() => _loadingItens = false);
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Erro ao carregar itens');
    }
  }

  Future<void> _atualizarDisponiveis() async {
    if (_itemSelecionado != null) {
      try {
        final cautelada = await ApiService.getQuantidadeCautelada(_itemSelecionado!.id);
        setState(() {
          _disponiveis = _itemSelecionado!.quantidadeTotal - cautelada;
        });
      } catch (e) {
        setState(() => _disponiveis = null);
      }
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
      setState(() => _dataSelecionada = data);
    }
  }

  Future<void> _registrarCautela() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_itemSelecionado == null) {
      SnackbarUtils.showError(context, 'Selecione um item');
      return;
    }

    final quantidade = int.parse(_quantidadeController.text);
    if (quantidade > (_disponiveis ?? 0)) {
      SnackbarUtils.showError(context, 'Quantidade insuficiente! Disponível: $_disponiveis');
      return;
    }

    final cautela = {
      'itemId': _itemSelecionado!.id,
      'quantidade': quantidade,
      'data': DateFormat('yyyy-MM-dd').format(_dataSelecionada),
      'paraQuem': _paraQuemController.text.trim(),
      'obs': _obsController.text.trim().isEmpty ? null : _obsController.text.trim(),
    };

    LoadingOverlay.show(context, message: 'Registrando cautela...');

    try {
      final resultado = await ApiService.registrarCautela(cautela);
      
      if (!mounted) return;
      LoadingOverlay.hide(context);

      if (resultado['success'] == true) {
        SnackbarUtils.showSuccess(context, 'Cautela registrada com sucesso!');
        
        setState(() {
          _itemSelecionado = null;
          _quantidadeController.text = '1';
          _paraQuemController.clear();
          _obsController.clear();
          _dataSelecionada = DateTime.now();
          _disponiveis = null;
        });
        
        _carregarItens();
      } else {
        SnackbarUtils.showError(context, resultado['message'] ?? 'Erro ao registrar cautela');
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
      appBar: AppBar(title: const Text('Registrar Nova Cautela')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<ItemCautela>(
                value: _itemSelecionado,
                decoration: const InputDecoration(labelText: 'Item *'),
                items: _itens.map((item) => DropdownMenuItem<ItemCautela>(value: item, child: Text(item.nome))).toList(),
                onChanged: _loadingItens ? null : (value) {
                  setState(() => _itemSelecionado = value);
                  _atualizarDisponiveis();
                },
                validator: (v) => v == null ? 'Selecione um item' : null,
              ),
              if (_disponiveis != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Disponível: $_disponiveis', style: TextStyle(fontSize: 12, color: _disponiveis! > 0 ? Colors.green : Colors.red)),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantidadeController,
                      decoration: const InputDecoration(labelText: 'Quantidade *'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Informe';
                        final q = int.tryParse(v);
                        if (q == null || q <= 0) return 'Inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _paraQuemController,
                      decoration: const InputDecoration(labelText: 'Para Quem *'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Informe' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selecionarData,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Data da Cautela', suffixIcon: Icon(Icons.calendar_today)),
                  child: Text(DateFormat('dd/MM/yyyy').format(_dataSelecionada)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _obsController,
                decoration: const InputDecoration(labelText: 'Observações'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _registrarCautela,
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar Cautela'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

