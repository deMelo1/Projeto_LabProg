import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/socio.dart';
import '../../services/api_service.dart';
import '../../utils/snackbar_utils.dart';

class RenovacaoSocioPage extends StatefulWidget {
  const RenovacaoSocioPage({super.key});

  @override
  State<RenovacaoSocioPage> createState() => _RenovacaoSocioPageState();
}

class _RenovacaoSocioPageState extends State<RenovacaoSocioPage> {
  final TextEditingController _buscaController = TextEditingController();
  Socio? _socioSelecionado;
  DateTime? _novaDataFim;
  bool _loading = false;
  List<Socio> _sugestoes = [];
  bool _mostrandoSugestoes = false;

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _buscarSocios(String query) async {
    if (query.length < 2) {
      setState(() {
        _sugestoes = [];
        _mostrandoSugestoes = false;
      });
      return;
    }

    try {
      final response = await ApiService.get('/socios/autocomplete?query=$query');
      final List<dynamic> data = jsonDecode(response.body);
      
      setState(() {
        _sugestoes = data.map((json) => Socio.fromJson(json)).toList();
        _mostrandoSugestoes = true;
      });
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Erro ao buscar sócios: $e');
      }
    }
  }

  Future<void> _selecionarSocio(Socio socio) async {
    try {
      final response = await ApiService.get('/socios/${socio.id}');
      final data = jsonDecode(response.body);
      
      setState(() {
        _socioSelecionado = Socio.fromJson(data);
        _buscaController.text = _socioSelecionado!.nome;
        _mostrandoSugestoes = false;
        _sugestoes = [];
      });
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Erro ao carregar sócio: $e');
      }
    }
  }

  Future<void> _selecionarNovaData() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _socioSelecionado != null 
          ? DateTime.parse(_socioSelecionado!.fimFiliacao).add(const Duration(days: 1))
          : DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() => _novaDataFim = picked);
    }
  }

  Future<void> _renovarFiliacao() async {
    if (_socioSelecionado == null) {
      SnackbarUtils.showError(context, 'Selecione um sócio');
      return;
    }

    if (_novaDataFim == null) {
      SnackbarUtils.showError(context, 'Selecione a nova data de vencimento');
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await ApiService.post(
        '/socios/${_socioSelecionado!.id}/renovar',
        {
          'novaDataFim': _novaDataFim!.toIso8601String().split('T')[0],
        },
      );

      if (!mounted) return;

      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        SnackbarUtils.showSuccess(context, 'Filiação renovada com sucesso!');
        _limparFormulario();
      } else {
        SnackbarUtils.showError(context, data['message'] ?? 'Erro ao renovar');
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
    setState(() {
      _buscaController.clear();
      _socioSelecionado = null;
      _novaDataFim = null;
      _sugestoes = [];
      _mostrandoSugestoes = false;
    });
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
        return 'PRÓXIMO AO VENCIMENTO';
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
        title: const Text('Renovação de Filiação'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _buscaController,
                decoration: const InputDecoration(
                  labelText: 'Buscar Sócio',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Digite o nome do sócio...',
                ),
                onChanged: (value) {
                  _buscarSocios(value);
                  if (_socioSelecionado != null) {
                    setState(() => _socioSelecionado = null);
                  }
                },
              ),
              
              if (_mostrandoSugestoes && _sugestoes.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _sugestoes.length,
                    itemBuilder: (context, index) {
                      final socio = _sugestoes[index];
                      return ListTile(
                        title: Text(socio.nome),
                        subtitle: Text('${socio.cpf} (${socio.turma})'),
                        onTap: () => _selecionarSocio(socio),
                      );
                    },
                  ),
                ),
              
              if (_socioSelecionado != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informações do Sócio',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfo('Nome', _socioSelecionado!.nome),
                      _buildInfo('CPF', _socioSelecionado!.cpf),
                      _buildInfo('Turma', _socioSelecionado!.turma),
                      _buildInfo(
                        'Vencimento Atual',
                        DateTime.parse(_socioSelecionado!.fimFiliacao)
                            .toLocal()
                            .toString()
                            .split(' ')[0]
                            .split('-')
                            .reversed
                            .join('/'),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            'Status: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(_socioSelecionado!.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getStatusLabel(_socioSelecionado!.status),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                ListTile(
                  title: const Text('Nova Data de Vencimento'),
                  subtitle: Text(
                    _novaDataFim != null
                        ? '${_novaDataFim!.day.toString().padLeft(2, '0')}/${_novaDataFim!.month.toString().padLeft(2, '0')}/${_novaDataFim!.year}'
                        : 'Selecione a data',
                  ),
                  leading: const Icon(Icons.event),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _selecionarNovaData,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                const SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: _loading ? null : _renovarFiliacao,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Renovar Filiação'),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

