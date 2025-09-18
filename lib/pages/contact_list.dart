import 'package:agenda_contatos_flutter/utils/format_phone.dart';
import 'package:agenda_contatos_flutter/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import '../services/contact_service.dart';

class ContactListPage extends StatefulWidget {
  final ContactService contactService;

  ContactListPage({super.key, ContactService? contactService})
      : contactService = contactService ?? ContactService();

  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  List<Map<String, dynamic>> _contacts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await widget.contactService.getContacts();
      if (!mounted) return;
      setState(() {
        _contacts = contacts;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      _showMessage('Erro ao carregar contatos.');
      setState(() => _loading = false);
    }
  }

  void _showMessage(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    });
  }

  Future<void> _deleteContact(String id) async {
    try {
      await widget.contactService.deleteContact(id);
      if (!mounted) return;
      _showMessage('Contato excluído com sucesso!');
      _loadContacts();
    } catch (error) {
      if (!mounted) return;
      _showMessage('Erro ao excluir contato.');
    }
  }

  void _editContact(String id) {
    Navigator.pushNamed(
      context,
      '/editar',
      arguments: id,
    ).then((_) => _loadContacts());
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Contatos')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Contatos')),
      drawer: AppDrawer(),
      // 🔹 FAB para adicionar novo contato
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/novo').then((_) => _loadContacts());
        },
        child: const Icon(Icons.add),
      ),
      body: _contacts.isEmpty
          ? const Center(child: Text('Nenhum contato encontrado.'))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: _contacts.length,
                itemBuilder: (context, index) {
                  final contact = _contacts[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      title: Text(
                        contact['nome'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.email, size: 16),
                              const SizedBox(width: 6),
                              Text(contact['email'] ?? ''),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 16),
                              const SizedBox(width: 6),
                              Text(formatPhone(contact['telefone'])),
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () => _editContact(contact['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteContact(contact['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
