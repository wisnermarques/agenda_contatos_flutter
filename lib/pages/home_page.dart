import 'package:agenda_contatos_flutter/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _buildCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 48),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cards = [
      _buildCard(
        icon: Icons.people,
        iconColor: Colors.blue,
        title: 'Lista de Contatos',
        description: 'Visualize todos os seus contatos cadastrados',
        onTap: () => Navigator.pushNamed(context, '/contatos'),
      ),
      _buildCard(
        icon: Icons.person_add,
        iconColor: Colors.green,
        title: 'Novo Contato',
        description: 'Adicione novos contatos à sua agenda',
        onTap: () => Navigator.pushNamed(context, '/novo'),
      ),
      _buildCard(
        icon: Icons.edit,
        iconColor: Colors.orange,
        title: 'Edição Fácil',
        description: 'Atualize informações dos seus contatos',
        onTap: () => Navigator.pushNamed(context, '/contatos'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciador de Contatos'),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Bem-vindo ao Gerenciador de Contatos',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Recursos Disponíveis',
              style: TextStyle(fontSize: 18, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3, // 3 cards por linha em telas grandes
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
                children: cards,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
