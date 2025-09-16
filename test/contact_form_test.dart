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

  setUp(() {
    mockContactService = MockContactService();
  });

  group('ContactFormPage Tests', () {
    testWidgets('Renderiza campos de Nome, Email e Telefone',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ContactFormPage(contactService: mockContactService),
        ),
      );

      // Deve ter 3 campos de texto
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.widgetWithText(TextFormField, 'Nome'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Telefone'), findsOneWidget);
    });

    testWidgets('Exibe validação se campos não preenchidos',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ContactFormPage(contactService: mockContactService),
        ),
      );

      // Tenta salvar sem preencher
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Atualiza estado

      expect(find.text('Informe o nome'), findsOneWidget);
      expect(find.text('Informe o email'), findsOneWidget);
      expect(find.text('Informe o telefone'), findsOneWidget);
    });

    testWidgets('Salva contato corretamente', (WidgetTester tester) async {
      // Configura o mock para retornar sucesso
      when(mockContactService.addContact(any))
          .thenAnswer((_) async => {'id': '1', 'nome': 'Ana', 'email': 'ana@email.com', 'telefone': '11999999999'});

      await tester.pumpWidget(
        MaterialApp(
          home: ContactFormPage(contactService: mockContactService),
        ),
      );

      // Preenche campos
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Nome'), 'Ana');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), 'ana@email.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Telefone'), '(11) 9 9999-9999');

      // Toca no botão salvar
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Atualiza frame
      await tester.pump(const Duration(milliseconds: 150)); // espera SnackBar

      // Verifica se o método addContact foi chamado
      verify(mockContactService.addContact(any)).called(1);
      
      // Verifica snackbar
      expect(find.text('Contato cadastrado com sucesso!'), findsOneWidget);
    });

    testWidgets('Exibe mensagem de erro se falhar ao salvar',
        (WidgetTester tester) async {
      // Configura o mock para lançar uma exceção
      when(mockContactService.addContact(any))
          .thenThrow(Exception('Erro de conexão'));

      await tester.pumpWidget(
        MaterialApp(
          home: ContactFormPage(contactService: mockContactService),
        ),
      );

      // Preenche campos
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Nome'), 'Ana');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), 'ana@email.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Telefone'), '(11) 9 9999-9999');

      // Toca no botão salvar
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Atualiza frame
      await tester.pump(const Duration(milliseconds: 150)); // espera SnackBar

      // Verifica mensagem de erro de forma mais flexível
      // Opção 1: Verifica se qualquer SnackBar está visível
      expect(find.byType(SnackBar), findsOneWidget);
      
      // Opção 2: Verifica se contém parte do texto de erro
      expect(find.textContaining('Erro ao salvar contato'), findsOneWidget);
      
      // Opção 3: Verifica se o texto contém "Erro" (mais genérico)
      expect(find.textContaining('Erro'), findsOneWidget);
    });
  });
}