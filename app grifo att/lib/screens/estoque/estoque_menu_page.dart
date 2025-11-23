import 'package:flutter/material.dart';
import '../../globals.dart' as globals;
import '../../widgets/menu_card.dart';
import 'cadastro_itens_page.dart';
import 'inventario_page.dart';
import 'movimentacao_page.dart';
import 'historico_page.dart';

class EstoqueMenuPage extends StatelessWidget {
  const EstoqueMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Estoque'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            // Cadastro de Itens - Apenas ADMIN e MASTER
            if (globals.isAdminOrMaster())
              MenuCard(
                title: 'Cadastro de Itens',
                subtitle: 'Cadastre novos itens no estoque',
                icon: Icons.add_box,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CadastroItensEstoquePage()),
                  );
                },
              ),
            
            // Inventário - Todos
            MenuCard(
              title: 'Inventário',
              subtitle: 'Visualize a quantidade atual',
              icon: Icons.list_alt,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InventarioPage()),
                );
              },
            ),
            
            // Entrada/Saída - Todos
            MenuCard(
              title: 'Entrada/Saída',
              subtitle: 'Registre movimentações',
              icon: Icons.swap_horiz,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MovimentacaoEstoquePage()),
                );
              },
            ),
            
            // Histórico - Apenas ADMIN e MASTER
            if (globals.isAdminOrMaster())
              MenuCard(
                title: 'Histórico',
                subtitle: 'Visualize todas as movimentações',
                icon: Icons.history,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoricoEstoquePage()),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

