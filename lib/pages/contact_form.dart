import 'package:agenda_contatos_flutter/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import '../services/contact_service.dart';
import '../utils/format_phone.dart';

class ContactFormPage extends StatefulWidget {
  final String? contactId; // Se nulo, é novo contato; se preenchido, edição
  final ContactService contactService;

  ContactFormPage({super.key, ContactService? contactService, this.contactId})
      : contactService = contactService ?? ContactService();

  @override
  State<ContactFormPage> createState() => _ContactFormPageState();
}

class _ContactFormPageState extends State<ContactFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();

  bool _loading = false;
  bool _loadingData = true; // Para carregar dados do contato

  @override
  void initState() {
    super.initState();
    if (widget.contactId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadContact(widget.contactId!);
      });
    } else {
      _loadingData = false;
    }
  }

  Future<void> _loadContact(String id) async {
    try {
      final contact = await widget.contactService.getContactById(id);
      if (!mounted) return;

      _nomeController.text = contact['nome'] ?? '';
      _emailController.text = contact['email'] ?? '';
      _telefoneController.text = formatPhone(contact['telefone'] ?? '');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar contato.')),
      );
    } finally {
      if (mounted) {
        setState(() => _loadingData = false); // <<< IMPORTANTE
      }
    }
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final contactData = {
      'nome': _nomeController.text.trim(),
      'email': _emailController.text.trim(),
      'telefone': _telefoneController.text.replaceAll(RegExp(r'\D'), ''),
    };

    try {
      if (widget.contactId == null) {
        await widget.contactService.addContact(contactData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contato cadastrado com sucesso!')),
        );
      } else {
        await widget.contactService.updateContact(
          widget.contactId!,
          contactData,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contato atualizado com sucesso!')),
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar contato: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.contactId == null ? 'Novo Contato' : 'Editar Contato',
        ),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    widget.contactId == null
                        ? 'Cadastro de Contato'
                        : 'Editar Contato',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Nome
                  TextFormField(
                    controller: _nomeController,
                    key: const Key('nomeField'),
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Informe o nome' : null,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    key: const Key('emailField'),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Informe o email';
                      final regex =
                          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!regex.hasMatch(val)) return 'Email inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Telefone
                  TextFormField(
                    controller: _telefoneController,
                    key: const Key('telefoneField'),
                    decoration: const InputDecoration(
                      labelText: 'Telefone',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    maxLength: 15,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Informe o telefone' : null,
                    onChanged: (val) {
                      final formatted = formatPhone(val);
                      _telefoneController.value = _telefoneController.value
                          .copyWith(
                        text: formatted,
                        selection: TextSelection.collapsed(
                          offset: formatted.length,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      key: const Key('saveButton'),
                      onPressed: _loading ? null : _saveContact,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Salvar',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
