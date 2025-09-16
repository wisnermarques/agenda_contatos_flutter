import 'package:agenda_contatos_flutter/pages/edit_contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agenda_contatos_flutter/services/contact_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';


@GenerateMocks([ContactService])
import 'contact_edit_form_test.mocks.dart' as edit_mocks;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late edit_mocks.MockContactService mockContactService;
  const contactId = '1';
  final contactData = {
    'id': contactId,
    'nome': 'Ana',
    'email': 'ana@email.com',
    'telefone': '11999999999',
  };

  setUp(() {
    mockContactService = edit_mocks.MockContactService();
  });

  group('EditContactPage Tests', () {
    testWidgets('Carrega e preenche campos corretamente', (WidgetTester tester) async {
      when(mockContactService.getContactById(contactId))
          .thenAnswer((_) async => contactData);

      await tester.pumpWidget(
        MaterialApp(
          home: EditContactPage(
            contactService: mockContactService,
            contactId: contactId,
          ),
        ),
      );

      // Espera a tela carregar dados assíncronos
      await tester.pumpAndSettle();

      // Verifica se os campos estão preenchidos
      expect(find.widgetWithText(TextFormField, 'Nome'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Telefone'), findsOneWidget);

      // Verifica se o controller tem os valores esperados
      final nomeField = find.byWidgetPredicate(
        (w) => w is TextFormField && w.controller?.text == 'Ana',
      );
      expect(nomeField, findsOneWidget);
    });

    testWidgets('Atualiza contato com sucesso', (WidgetTester tester) async {
      when(mockContactService.getContactById(contactId))
          .thenAnswer((_) async => contactData);

      when(mockContactService.updateContact(contactId, any))
          .thenAnswer((_) async => contactData);

      await tester.pumpWidget(
        MaterialApp(
          home: EditContactPage(
            contactService: mockContactService,
            contactId: contactId,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Altera nome e telefone
      await tester.enterText(find.byType(TextFormField).at(0), 'Ana Maria');
      await tester.enterText(find.byType(TextFormField).at(2), '11988888888');

      // Toca salvar
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // Verifica se updateContact foi chamado corretamente
      verify(mockContactService.updateContact(contactId, any)).called(1);

      // Verifica snackbar de sucesso
      expect(find.text('Contato atualizado com sucesso!'), findsOneWidget);
    });

    testWidgets('Exibe mensagem de erro se falhar ao atualizar', (WidgetTester tester) async {
      when(mockContactService.getContactById(contactId))
          .thenAnswer((_) async => contactData);

      when(mockContactService.updateContact(contactId, any))
          .thenThrow(Exception('Erro de conexão'));

      await tester.pumpWidget(
        MaterialApp(
          home: EditContactPage(
            contactService: mockContactService,
            contactId: contactId,
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Ana Maria');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // Verifica snackbar de erro
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Erro ao salvar contato.'), findsOneWidget);
    });
  });
}
