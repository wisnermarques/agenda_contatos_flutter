// services/contact_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ContactService {
  final SupabaseClient client;
  
  ContactService({SupabaseClient? client}) : client = client ?? supabase;

  /// Retorna todos os contatos
  Future<List<Map<String, dynamic>>> getContacts() async {
    final data = await client.from('contatos').select() as List<dynamic>;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Retorna um contato pelo id
  Future<Map<String, dynamic>> getContactById(String id) async {
    final data = await client
        .from('contatos')
        .select()
        .eq('id', id)
        .single();
    return data;
  }

  /// Adiciona um contato
  Future<Map<String, dynamic>> addContact(Map<String, dynamic> contact) async {
    final formattedContact = {
      ...contact,
      'telefone': contact['telefone'].toString().replaceAll(RegExp(r'\D'), ''),
    };

    final data = await client.from('contatos').insert([formattedContact]).select() as List<dynamic>;
    return Map<String, dynamic>.from(data[0]);
  }

  /// Atualiza um contato
  Future<Map<String, dynamic>> updateContact(
    String id, Map<String, dynamic> contact) async {
    final formattedContact = {
      ...contact,
      'telefone': contact['telefone'].toString().replaceAll(RegExp(r'\D'), ''),
    };

    final data = await client
        .from('contatos')
        .update(formattedContact)
        .eq('id', id)
        .select() as List<dynamic>;

    return Map<String, dynamic>.from(data[0]);
  }

  /// Deleta um contato
  Future<void> deleteContact(String id) async {
    await client.from('contatos').delete().eq('id', id);
  }
}