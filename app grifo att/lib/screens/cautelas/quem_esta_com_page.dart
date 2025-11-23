import 'package:flutter/material.dart';
import '../../models/cautela.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/confirm_dialog.dart';
import '../../utils/snackbar_utils.dart';
import '../../globals.dart' as globals;
import 'package:intl/intl.dart';

class QuemEstaComPage extends StatefulWidget {
  const QuemEstaComPage({super.key});

  @override
  State<QuemEstaComPage> createState() => _QuemEstaComPageState();
}

class _QuemEstaComPageState extends State<QuemEstaComPage> {
  List<Cautela> _cautelas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregarCautelas();
  }

  Future<void> _carregarCautelas() async {
    setState(() => _loading = true);
    
    try {
      final data = await ApiService.getCautelasAtivas();
      setState(() {
        _cautelas = data.map((json) => Cautela.fromJson(json)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Erro ao carregar cautelas');
    }
  }

  Future<void> _devolverCautela(Cautela cautela) async {
    final confirmar = await ConfirmDialog.show(
      context,
      title: 'Devolver Cautela',
      message: 'Confirmar devolução de "${cautela.itemNome}" (${cautela.quantidade} unidade(s)) de ${cautela.paraQuem}?',
      confirmText: 'Devolver',
    );

    if (!confirmar) return;

    LoadingOverlay.show(context, message: 'Devolvendo...');

    try {
      final resultado = await ApiService.devolverCautela(cautela.id);
      
      if (!mounted) return;
      LoadingOverlay.hide(context);

      if (resultado['success'] == true) {
        SnackbarUtils.showSuccess(context, 'Cautela devolvida com sucesso');
        _carregarCautelas();
      } else {
        SnackbarUtils.showError(context, resultado['message'] ?? 'Erro ao devolver');
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
        title: const Text('Cautelas Ativas'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _cautelas.isEmpty
              ? Center(child: Text('Nenhuma cautela ativa', style: TextStyle(color: Colors.grey[600])))
              : RefreshIndicator(
                  onRefresh: _carregarCautelas,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cautelas.length,
                    itemBuilder: (context, index) {
                      final cautela = _cautelas[index];
                      
                      return Card(
                        child: ListTile(
                          title: Text(cautela.itemNome, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Responsável: ${cautela.membro}'),
                              Text('Está com: ${cautela.paraQuem}'),
                              Text('Quantidade: ${cautela.quantidade}'),
                              Text('Data: ${DateFormat('dd/MM/yyyy').format(DateFormat('yyyy-MM-dd').parse(cautela.dataCautela))}'),
                              if (cautela.obs != null && cautela.obs!.isNotEmpty) Text('Obs: ${cautela.obs}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: globals.isAdminOrMaster()
                              ? ElevatedButton(
                                  onPressed: () => _devolverCautela(cautela),
                                  child: const Text('Devolver'),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

