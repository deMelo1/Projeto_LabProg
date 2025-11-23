import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import '../../utils/snackbar_utils.dart';

class CadastroSocioPage extends StatefulWidget {
  const CadastroSocioPage({super.key});

  @override
  State<CadastroSocioPage> createState() => _CadastroSocioPageState();
}

class _CadastroSocioPageState extends State<CadastroSocioPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  String _turmaSelecionada = '';
  DateTime? _inicioFiliacao;
  DateTime? _fimFiliacao;

  bool _loading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    super.dispose();
  }

  String _formatarCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'\D'), '');
    if (cpf.length <= 3) return cpf;
    if (cpf.length <= 6) return '${cpf.substring(0, 3)}.${cpf.substring(3)}';
    if (cpf.length <= 9) return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6)}';
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9, 11)}';
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_turmaSelecionada.isEmpty) {
      SnackbarUtils.showError(context, 'Selecione uma turma');
      return;
    }

    if (_inicioFiliacao == null || _fimFiliacao == null) {
      SnackbarUtils.showError(context, 'Selecione as datas de filiação');
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await ApiService.post('/socios', {
        'nome': _nomeController.text.trim(),
        'cpf': _cpfController.text.trim(),
        'turma': _turmaSelecionada,
        'inicioFiliacao': _inicioFiliacao!.toIso8601String().split('T')[0],
        'fimFiliacao': _fimFiliacao!.toIso8601String().split('T')[0],
      });

      if (!mounted) return;

      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        SnackbarUtils.showSuccess(context, 'Sócio cadastrado com sucesso!');
        _limparFormulario();
      } else {
        SnackbarUtils.showError(context, data['message'] ?? 'Erro ao cadastrar');
      }
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Erro: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _limparFormulario() {
    _formKey.currentState?.reset();
    _nomeController.clear();
    _cpfController.clear();
    setState(() {
      _turmaSelecionada = '';
      _inicioFiliacao = null;
      _fimFiliacao = null;
    });
  }

  Future<void> _selecionarData(BuildContext context, bool isInicio) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isInicio) {
          _inicioFiliacao = picked;
        } else {
          _fimFiliacao = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Sócio'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome Completo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nome é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _cpfController,
                  decoration: const InputDecoration(
                    labelText: 'CPF',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                    hintText: '000.000.000-00',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  onChanged: (value) {
                    final formatted = _formatarCPF(value);
                    _cpfController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  },
                  validator: (value) {
                    if (value == null || value.replaceAll(RegExp(r'\D'), '').length != 11) {
                      return 'CPF inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  value: _turmaSelecionada.isEmpty ? null : _turmaSelecionada,
                  decoration: const InputDecoration(
                    labelText: 'Turma',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.school),
                  ),
                  items: ['XXV', 'XXVI', 'XXVII', 'XXVIII', 'XXIX', 'XXX']
                      .map((turma) => DropdownMenuItem(
                            value: turma,
                            child: Text(turma),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _turmaSelecionada = value ?? '');
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecione uma turma';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                ListTile(
                  title: const Text('Início da Filiação'),
                  subtitle: Text(
                    _inicioFiliacao != null
                        ? '${_inicioFiliacao!.day.toString().padLeft(2, '0')}/${_inicioFiliacao!.month.toString().padLeft(2, '0')}/${_inicioFiliacao!.year}'
                        : 'Selecione a data',
                  ),
                  leading: const Icon(Icons.calendar_today),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _selecionarData(context, true),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                const SizedBox(height: 16),
                
                ListTile(
                  title: const Text('Fim da Filiação'),
                  subtitle: Text(
                    _fimFiliacao != null
                        ? '${_fimFiliacao!.day.toString().padLeft(2, '0')}/${_fimFiliacao!.month.toString().padLeft(2, '0')}/${_fimFiliacao!.year}'
                        : 'Selecione a data',
                  ),
                  leading: const Icon(Icons.event),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _selecionarData(context, false),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                const SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: _loading ? null : _cadastrar,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Cadastrar Sócio'),
                ),
                const SizedBox(height: 12),
                
                OutlinedButton(
                  onPressed: _limparFormulario,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Limpar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

