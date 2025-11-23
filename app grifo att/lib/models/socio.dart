class Socio {
  final int id;
  final String nome;
  final String cpf;
  final String turma;
  final String inicioFiliacao;
  final String fimFiliacao;
  final String status;
  final bool isAtrasado;
  final int diasParaVencer;
  final String? dataCadastro;
  final String? dataUltimaRenovacao;

  Socio({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.turma,
    required this.inicioFiliacao,
    required this.fimFiliacao,
    required this.status,
    required this.isAtrasado,
    required this.diasParaVencer,
    this.dataCadastro,
    this.dataUltimaRenovacao,
  });

  factory Socio.fromJson(Map<String, dynamic> json) {
    return Socio(
      id: json['id'],
      nome: json['nome'],
      cpf: json['cpf'],
      turma: json['turma'],
      inicioFiliacao: json['inicioFiliacao'],
      fimFiliacao: json['fimFiliacao'],
      status: json['status'] ?? 'ATIVO',
      isAtrasado: json['isAtrasado'] ?? false,
      diasParaVencer: json['diasParaVencer'] ?? 0,
      dataCadastro: json['dataCadastro'],
      dataUltimaRenovacao: json['dataUltimaRenovacao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'cpf': cpf,
      'turma': turma,
      'inicioFiliacao': inicioFiliacao,
      'fimFiliacao': fimFiliacao,
      'status': status,
      'isAtrasado': isAtrasado,
      'diasParaVencer': diasParaVencer,
      'dataCadastro': dataCadastro,
      'dataUltimaRenovacao': dataUltimaRenovacao,
    };
  }
}

