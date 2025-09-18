import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agenda_contatos_flutter/pages/contact_form.dart';
import 'package:agenda_contatos_flutter/services/contact_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([ContactService])
import 'contact_form_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockContactService mockContactService;

  // Helper para montar a tela no teste
  Future<void> pumpContactForm(WidgetTester tester, {String? contactId}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ContactFormPage(
          contactId: contactId,
          contactService: mockContactService,
        ),
      ),
    );
    await tester.pump(); // garante primeiro frame
  }

  setUp(() {
    mockContactService = MockContactService();
  });

  group('ContactFormPage Tests', () {
    testWidgets('Renderiza campos de Nome, Email e Telefone', (tester) async {
      await pumpContactForm(tester);

      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.widgetWithText(TextFormField, 'Nome'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Telefone'), findsOneWidget);
    });

    testWidgets('Exibe validação se campos não preenchidos', (tester) async {
      await pumpContactForm(tester);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Informe o nome'), findsOneWidget);
      expect(find.text('Informe o email'), findsOneWidget);
      expect(find.text('Informe o telefone'), findsOneWidget);
    });

    testWidgets('Salva contato corretamente', (tester) async {
      when(mockContactService.addContact(any)).thenAnswer(
        (_) async => {
          'id': '1',
          'nome': 'Ana',
          'email': 'ana@email.com',
          'telefone': '11999999999',
        },
      );

      await pumpContactForm(tester);

      await tester.enterText(find.widgetWithText(TextFormField, 'Nome'), 'Ana');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'ana@email.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Telefone'),
        '11999999999',
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(seconds: 1));

      verify(mockContactService.addContact(any)).called(1);
      expect(find.text('Contato cadastrado com sucesso!'), findsOneWidget);
    });

    testWidgets('Exibe mensagem de erro se falhar ao salvar', (tester) async {
      when(
        mockContactService.addContact(any),
      ).thenThrow(Exception('Erro de conexão'));

      await pumpContactForm(tester);

      await tester.enterText(find.widgetWithText(TextFormField, 'Nome'), 'Ana');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'ana@email.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Telefone'),
        '11999999999',
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Erro ao salvar contato'), findsOneWidget);
    });

    testWidgets('Carrega contato existente para edição', (tester) async {
      when(mockContactService.getContactById('123')).thenAnswer(
        (_) async => {
          'id': '123',
          'nome': 'Fulano',
          'email': 'fulano@email.com',
          'telefone': '11988887777',
        },
      );

      await pumpContactForm(tester, contactId: '123');

      // espera tudo carregar
      await tester.pumpAndSettle();

      // verifica campos preenchidos
      expect(find.byType(TextFormField), findsNWidgets(3));

      final nomeFieldFinder = find.widgetWithText(TextFormField, 'Nome');
      final emailFieldFinder = find.widgetWithText(TextFormField, 'Email');

      expect(
        tester.widget<TextFormField>(nomeFieldFinder).controller?.text,
        'Fulano',
      );
      expect(
        tester.widget<TextFormField>(emailFieldFinder).controller?.text,
        'fulano@email.com',
      );

      verify(mockContactService.getContactById('123')).called(1);
    });

    testWidgets('Exibe erro ao carregar contato', (tester) async {
      when(
        mockContactService.getContactById('123'),
      ).thenThrow(Exception('Erro'));

      await pumpContactForm(tester, contactId: '123');

      // espera tudo carregar/falhar
      await tester.pumpAndSettle();

      // verifica mensagem de erro
      expect(find.text('Erro ao carregar contato.'), findsOneWidget);
    });
  });
}
