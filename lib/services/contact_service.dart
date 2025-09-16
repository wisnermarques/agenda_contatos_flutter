import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ContactService {
  /// Retorna todos os contatos
  static Future<List<Map<String, dynamic>>> getContacts() async {
    final data = await supabase.from('contatos').select() as List<dynamic>;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Retorna um contato pelo id
  static Future<Map<String, dynamic>> getContactById(String id) async {
  final data = await supabase
      .from('contatos')
      .select()
      .eq('id', id)
      .single();
  return data;
}

  /// Adiciona um contato
  static Future<Map<String, dynamic>> addContact(
      Map<String, dynamic> contact) async {
    final formattedContact = {
      ...contact,
      'telefone': contact['telefone'].toString().replaceAll(RegExp(r'\D'), ''),
    };

    final data = await supabase.from('contatos').insert([formattedContact]).select() as List<dynamic>;
    return Map<String, dynamic>.from(data[0]);
  }

  /// Atualiza um contato
  static Future<Map<String, dynamic>> updateContact(
    String id, Map<String, dynamic> contact) async {
  final formattedContact = {
    ...contact,
    'telefone': contact['telefone'].toString().replaceAll(RegExp(r'\D'), ''),
  };

  final data = await supabase
      .from('contatos')
      .update(formattedContact)
      .eq('id', id)
      .select() as List<dynamic>;

  return Map<String, dynamic>.from(data[0]);
}

  /// Deleta um contato
  static Future<void> deleteContact(String id) async {
    await supabase.from('contatos').delete().eq('id', id);
  }
}
