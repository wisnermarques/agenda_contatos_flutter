import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agenda_contatos_flutter/pages/contact_form.dart';
import 'package:agenda_contatos_flutter/services/contact_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Gera o arquivo de mocks
@GenerateMocks([ContactService])
import 'contact_form_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockContactService mockContactService;

  Future<void> pumpContactForm(WidgetTester tester, {String? contactId}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ContactFormPage(
          contactId: contactId,
          contactService: mockContactService, // seu mock do serviço
        ),
      ),
    );

    // Permite que widgets assíncronos no initState sejam processados
    await tester.pump();
  }

  setUp(() {
    mockContactService = MockContactService();
  });

  group('ContactFormPage Tests', () {
    testWidgets('Renderiza campos de Nome, Email e Telefone', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContactFormPage(contactService: mockContactService),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.widgetWithText(TextFormField, 'Nome'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Telefone'), findsOneWidget);
    });

    testWidgets('Exibe validação se campos não preenchidos', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContactFormPage(contactService: mockContactService),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // apenas um pump é suficiente para validação

      expect(find.text('Informe o nome'), findsOneWidget);
      expect(find.text('Informe o email'), findsOneWidget);
      expect(find.text('Informe o telefone'), findsOneWidget);
    });

    testWidgets('Salva contato corretamente', (WidgetTester tester) async {
      when(mockContactService.addContact(any)).thenAnswer(
        (_) async => {
          'id': '1',
          'nome': 'Ana',
          'email': 'ana@email.com',
          'telefone': '11999999999',
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContactFormPage(contactService: mockContactService),
          ),
        ),
      );

      await tester.enterText(find.widgetWithText(TextFormField, 'Nome'), 'Ana');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'ana@email.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Telefone'),
        '(11) 9 9999-9999',
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(
        const Duration(seconds: 1),
      ); // aguarda SnackBar aparecer

      verify(mockContactService.addContact(any)).called(1);
      expect(find.text('Contato cadastrado com sucesso!'), findsOneWidget);
    });

    testWidgets('Exibe mensagem de erro se falhar ao salvar', (
      WidgetTester tester,
    ) async {
      when(
        mockContactService.addContact(any),
      ).thenThrow(Exception('Erro de conexão'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContactFormPage(contactService: mockContactService),
          ),
        ),
      );

      await tester.enterText(find.widgetWithText(TextFormField, 'Nome'), 'Ana');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'ana@email.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Telefone'),
        '(11) 9 9999-9999',
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(
        const Duration(seconds: 1),
      ); // aguarda SnackBar aparecer

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Erro ao salvar contato'), findsOneWidget);
    });

    testWidgets('Carrega contato existente para edição', (
      WidgetTester tester,
    ) async {
      when(mockContactService.getContactById('123')).thenAnswer(
        (_) async => {
          'nome': 'Fulano',
          'email': 'fulano@email.com',
          'telefone': '11988887777',
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContactFormPage(
              contactService: mockContactService,
              contactId: '123',
            ),
          ),
        ),
      );

      await tester.pump(
        const Duration(seconds: 1),
      ); // espera o Future do _loadContact

      expect(find.widgetWithText(TextFormField, 'Fulano'), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, 'fulano@email.com'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextFormField, '(11) 98888-7777'),
        findsOneWidget,
      );
    });

    testWidgets('Exibe erro ao carregar contato', (tester) async {
      when(
        () => mockContactService.getContactById('123'),
      ).thenThrow(Exception('Erro'));

      await pumpContactForm(tester, contactId: '123');

      // Espera o build inicial
      await tester.pump();

      // Espera o _loadContact terminar e o SnackBar ser mostrado
      await tester.pump(const Duration(milliseconds: 100));

      // Agora o SnackBar já deve existir
      expect(find.text('Erro ao carregar contato.'), findsOneWidget);
    });
  });
}
