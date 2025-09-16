import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('Gerenciador de Contatos'),
            accountEmail: const Text('wisner.marques@go.senac.br'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.blue),
            ),
            decoration: const BoxDecoration(color: Colors.blue),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Lista de Contatos'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/contatos');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Novo Contato'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/novo');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Sobre'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Gerenciador de Contatos',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 Wisner',
              );
            },
          ),
        ],
      ),
    );
  }
}
