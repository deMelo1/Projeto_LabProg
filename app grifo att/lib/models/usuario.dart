class Usuario {
  final int id;
  final String login;
  final String nome;
  final String tipo;
  final bool aprovado;

  Usuario({
    required this.id,
    required this.login,
    required this.nome,
    required this.tipo,
    required this.aprovado,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? 0,
      login: json['login'] ?? '',
      nome: json['nome'] ?? '',
      tipo: json['tipo'] ?? 'MEMBRO',
      aprovado: json['aprovado'] ?? false,
    );
  }

  String get tipoFormatado {
    switch (tipo) {
      case 'MASTER':
        return 'Master';
      case 'ADMIN':
        return 'Administrador';
      case 'MEMBRO':
        return 'Membro';
      default:
        return tipo;
    }
  }
}

