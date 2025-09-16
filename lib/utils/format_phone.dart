String formatPhone(String phone) {
  // Remove tudo que não for número
  final onlyNums = phone.replaceAll(RegExp(r'\D'), '');

  if (onlyNums.length <= 10) {
    // Telefone fixo (8 dígitos)
    return onlyNums
        .replaceFirstMapped(RegExp(r'^(\d{2})(\d)'), (m) => '(${m[1]}) ${m[2]}')
        .replaceFirstMapped(RegExp(r'(\d{4})(\d)'), (m) => '${m[1]}-${m[2]}');
  } else {
    // Celular (9 dígitos)
    return onlyNums
        .replaceFirstMapped(RegExp(r'^(\d{2})(\d)'), (m) => '(${m[1]}) ${m[2]}')
        .replaceFirstMapped(RegExp(r'^(\(\d{2}\) \d{1})(\d{4})(\d)'), (m) => '${m[1]} ${m[2]}-${m[3]}');
  }
}
