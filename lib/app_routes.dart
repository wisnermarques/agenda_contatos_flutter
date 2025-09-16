import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/contact_list.dart';
import 'pages/contact_form.dart';
import 'pages/edit_contact.dart';

class AppRoutes {
  // Função que gera rotas dinamicamente
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomePage());

      case '/contatos':
        return MaterialPageRoute(builder: (_) => ContactListPage());

      case '/novo':
        return MaterialPageRoute(builder: (_) => ContactFormPage());

      case '/editar':
        // Pega o argumento passado pelo Navigator
        final args = settings.arguments;
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => EditContactPage(contactId: args),
          );
        }
        // Se não passou argumento, lança erro
        throw Exception('contactId é obrigatório para /editar');

      default:
        // rota desconhecida
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Rota desconhecida: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
