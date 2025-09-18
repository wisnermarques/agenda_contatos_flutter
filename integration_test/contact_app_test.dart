// integration_test/contact_app_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:agenda_contatos_flutter/main.dart';
import 'package:agenda_contatos_flutter/services/contact_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ContactService contactService;
  late String contactId;

  setUpAll(() async {
    // Inicializa Supabase
    await Supabase.initialize(
      url: 'https://buthvwkrystyweaphqoj.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ1dGh2d2tyeXN0eXdlYXBocW9qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MDA4MzAsImV4cCI6MjA2OTk3NjgzMH0.rSHiqkKKoHe6eHh4w6_SVXI1u1G24rn8arIuSx3ayjk',
    );

    contactService = ContactService();
  });

  testWidgets('Integração: adiciona, edita e exclui contato',
      (WidgetTester tester) async {
    // Inicializa app
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 1️⃣ Adicionar contato
    final newContact = {
      'nome': 'Teste Flutter',
      'email': 'teste@flutter.com',
      'telefone': '11999999999',
    };

    final addedContact = await contactService.addContact(newContact);
    contactId = addedContact['id'] as String; // garante que temos o ID

    expect(addedContact['nome'], 'Teste Flutter');

    // 2️⃣ Editar contato
    final updatedContact = {
      'nome': 'Teste Flutter Editado',
      'email': 'teste@flutter.com',
      'telefone': '11999999999',
    };

    await contactService.updateContact(contactId, updatedContact);

    final fetchedContacts = await contactService.getContacts();
    final edited = fetchedContacts.firstWhere(
        (c) => c['id'] == contactId,
        orElse: () => {});

    expect(edited['nome'], 'Teste Flutter Editado');

    // 3️⃣ Excluir contato
    await contactService.deleteContact(contactId);

    final afterDelete = await contactService.getContacts();
    final deleted = afterDelete.any((c) => c['id'] == contactId);

    expect(deleted, false);
  });
}
