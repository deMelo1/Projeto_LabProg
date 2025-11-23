class LogAtividade {
  final int id;
  final String dataHora;
  final String usuarioNome;
  final String acao;
  final String detalhes;
  final String tipoEntidade;
  final int? entidadeId;

  LogAtividade({
    required this.id,
    required this.dataHora,
    required this.usuarioNome,
    required this.acao,
    required this.detalhes,
    required this.tipoEntidade,
    this.entidadeId,
  });

  factory LogAtividade.fromJson(Map<String, dynamic> json) {
    return LogAtividade(
      id: json['id'] ?? 0,
      dataHora: json['dataHora'] ?? '',
      usuarioNome: json['usuarioNome'] ?? 'Sistema',
      acao: json['acao'] ?? '',
      detalhes: json['detalhes'] ?? '',
      tipoEntidade: json['tipoEntidade'] ?? '',
      entidadeId: json['entidadeId'],
    );
  }
}

