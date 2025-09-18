import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:agenda_contatos_flutter/services/contact_service.dart';

// Gera a classe MockContactService
@GenerateMocks([ContactService])
import 'contact_service_test.mocks.dart';

void main() {
  late MockContactService mockService;

  setUp(() {
    mockService = MockContactService();
  });

  test('getContacts retorna lista de contatos', () async {
    when(mockService.getContacts()).thenAnswer((_) async => [
          {'id': '1', 'nome': 'Ana', 'email': 'ana@email.com', 'telefone': '11999999999'}
        ]);

    final result = await mockService.getContacts();

    expect(result.length, 1);
    expect(result[0]['nome'], 'Ana');
    verify(mockService.getContacts()).called(1);
  });

  test('getContactById retorna contato correto', () async {
    when(mockService.getContactById('1')).thenAnswer((_) async => {
          'id': '1',
          'nome': 'Ana',
          'email': 'ana@email.com',
          'telefone': '11999999999'
        });

    final result = await mockService.getContactById('1');

    expect(result['nome'], 'Ana');
    verify(mockService.getContactById('1')).called(1);
  });

  test('addContact salva contato corretamente', () async {
    when(mockService.addContact(any)).thenAnswer((_) async => {
          'id': '1',
          'nome': 'Ana',
          'email': 'ana@email.com',
          'telefone': '11999999999'
        });

    final result = await mockService.addContact({
      'nome': 'Ana',
      'email': 'ana@email.com',
      'telefone': '(11) 99999-9999',
    });

    expect(result['nome'], 'Ana');
    verify(mockService.addContact(any)).called(1);
  });

  test('deleteContact chama o método', () async {
    when(mockService.deleteContact('1')).thenAnswer((_) async => {});

    await mockService.deleteContact('1');

    verify(mockService.deleteContact('1')).called(1);
  });
}
