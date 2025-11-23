import 'package:flutter/material.dart';
import '../../globals.dart' as globals;
import '../../widgets/menu_card.dart';
import 'cadastro_itens_cautela_page.dart';
import 'minhas_cautelas_page.dart';
import 'quem_esta_com_page.dart';
import 'nova_cautela_page.dart';
import 'historico_cautelas_page.dart';

class CautelasMenuPage extends StatelessWidget {
  const CautelasMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Cautelas'),
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
                subtitle: 'Cadastre itens cauteláveis',
                icon: Icons.add_box,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CadastroItensCautelaPage()),
                  );
                },
              ),
            
            // Minhas Cautelas - Todos
            MenuCard(
              title: 'Minhas Cautelas',
              subtitle: 'Veja e devolva suas cautelas',
              icon: Icons.assignment_ind,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MinhasCautelasPage()),
                );
              },
            ),
            
            // Quem Está Com - Apenas ADMIN e MASTER
            if (globals.isAdminOrMaster())
              MenuCard(
                title: 'Quem Está Com',
                subtitle: 'Veja a posse atual dos itens',
                icon: Icons.person_search,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QuemEstaComPage()),
                  );
                },
              ),
            
            // Nova Cautela - Todos
            MenuCard(
              title: 'Nova Cautela',
              subtitle: 'Registre um novo empréstimo',
              icon: Icons.library_add,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NovaCautelaPage()),
                );
              },
            ),
            
            // Histórico Completo - Apenas ADMIN e MASTER
            if (globals.isAdminOrMaster())
              MenuCard(
                title: 'Histórico Completo',
                subtitle: 'Visualize todas as cautelas',
                icon: Icons.history,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoricoCautelasPage()),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

