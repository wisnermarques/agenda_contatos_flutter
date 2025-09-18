import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agenda_contatos_flutter/pages/contact_list.dart';
import 'package:agenda_contatos_flutter/services/contact_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([ContactService])
import 'mocks/contact_service_mocks.mocks.dart';

void main() {
  late MockContactService mockContactService;

  Future<void> pumpContactList(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ContactListPage(contactService: mockContactService),
        routes: {
          '/editar': (context) => const Scaffold(body: Text('Editar')) // rota fake
        },
      ),
    );
  }

  setUp(() {
    mockContactService = MockContactService();
  });

  group('ContactListPage', () {
    testWidgets('Exibe loading inicial', (tester) async {
      when(mockContactService.getContacts())
          .thenAnswer((_) async => []);
      await pumpContactList(tester);

      // CircularProgressIndicator aparece antes do Future completar
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('Exibe mensagem quando não há contatos', (tester) async {
      when(mockContactService.getContacts())
          .thenAnswer((_) async => []);
      await pumpContactList(tester);
      await tester.pumpAndSettle();

      expect(find.text('Nenhum contato encontrado.'), findsOneWidget);
    });

    testWidgets('Exibe lista de contatos', (tester) async {
      when(mockContactService.getContacts()).thenAnswer((_) async => [
            {
              'id': '1',
              'nome': 'Ana',
              'email': 'ana@email.com',
              'telefone': '11999999999',
            },
            {
              'id': '2',
              'nome': 'Bruno',
              'email': 'bruno@email.com',
              'telefone': '11988888888',
            },
          ]);

      await pumpContactList(tester);
      await tester.pumpAndSettle();

      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('Bruno'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsNWidgets(2));
      expect(find.byIcon(Icons.delete), findsNWidgets(2));
    });

    testWidgets('Exibe erro ao carregar contatos', (tester) async {
      when(mockContactService.getContacts()).thenThrow(Exception('Erro'));
      await pumpContactList(tester);
      await tester.pumpAndSettle();

      expect(find.text('Erro ao carregar contatos.'), findsOneWidget);
    });

    testWidgets('Ao clicar em excluir chama deleteContact', (tester) async {
      when(mockContactService.getContacts()).thenAnswer((_) async => [
            {'id': '1', 'nome': 'Ana', 'email': 'a@a.com', 'telefone': '11999999999'}
          ]);
      when(mockContactService.deleteContact('1')).thenAnswer((_) async {});

      await pumpContactList(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      verify(mockContactService.deleteContact('1')).called(1);
      expect(find.text('Contato excluído com sucesso!'), findsOneWidget);
    });

    testWidgets('Ao clicar em editar navega para rota /editar', (tester) async {
      when(mockContactService.getContacts()).thenAnswer((_) async => [
            {'id': '1', 'nome': 'Ana', 'email': 'a@a.com', 'telefone': '11999999999'}
          ]);

      await pumpContactList(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      expect(find.text('Editar'), findsOneWidget);
    });
  });
}
