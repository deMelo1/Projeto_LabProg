import 'package:flutter/material.dart';
import '../../globals.dart' as globals;
import '../../widgets/menu_card.dart';
import 'cadastro_socio_page.dart';
import 'gestao_socios_page.dart';
import 'renovacao_socio_page.dart';

class SociosMenuPage extends StatelessWidget {
  const SociosMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GESTÃO DE SÓCIOS'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Gerencie sócios da atlética',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
                children: [
                  MenuCard(
                    title: 'CADASTRAR NOVO SÓCIO',
                    subtitle: 'Registre novos sócios',
                    icon: Icons.person_add,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CadastroSocioPage()),
                      );
                    },
                  ),
                  
                  if (globals.isAdminOrMaster())
                    MenuCard(
                      title: 'GERENCIAR SÓCIOS',
                      subtitle: 'Visualize e exclua registros',
                      icon: Icons.manage_accounts,
                      color: Colors.orange[700],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const GestaoSociosPage()),
                        );
                      },
                    ),
                  
                  MenuCard(
                    title: 'RENOVAR FILIAÇÃO',
                    subtitle: 'Renove sócios existentes',
                    icon: Icons.refresh,
                    color: Colors.teal[700],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RenovacaoSocioPage()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

