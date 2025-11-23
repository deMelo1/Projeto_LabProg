class Cautela {
  final int id;
  final String membro;
  final String itemNome;
  final int quantidade;
  final String dataCautela;
  final String? dataDevolucao;
  final String status; // ATIVA ou DEVOLVIDA
  final String paraQuem;
  final String? obs;

  Cautela({
    required this.id,
    required this.membro,
    required this.itemNome,
    required this.quantidade,
    required this.dataCautela,
    this.dataDevolucao,
    required this.status,
    required this.paraQuem,
    this.obs,
  });

  factory Cautela.fromJson(Map<String, dynamic> json) {
    return Cautela(
      id: json['id'] ?? 0,
      membro: json['membro'] ?? '',
      itemNome: json['itemNome'] ?? '',
      quantidade: json['quantidade'] ?? 1,
      dataCautela: json['dataCautela'] ?? '',
      dataDevolucao: json['dataDevolucao'],
      status: json['status'] ?? 'ATIVA',
      paraQuem: json['paraQuem'] ?? '',
      obs: json['obs'],
    );
  }

  bool get isAtiva => status == 'ATIVA';
}

