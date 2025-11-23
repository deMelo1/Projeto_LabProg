class MovimentacaoEstoque {
  final int id;
  final String membro;
  final String itemNome;
  final String tipo; // ENTRADA ou SAIDA
  final int quantidade;
  final String data;
  final String? obs;

  MovimentacaoEstoque({
    required this.id,
    required this.membro,
    required this.itemNome,
    required this.tipo,
    required this.quantidade,
    required this.data,
    this.obs,
  });

  factory MovimentacaoEstoque.fromJson(Map<String, dynamic> json) {
    return MovimentacaoEstoque(
      id: json['id'] ?? 0,
      membro: json['membro'] ?? '',
      itemNome: json['itemNome'] ?? '',
      tipo: json['tipo'] ?? 'ENTRADA',
      quantidade: json['quantidade'] ?? 0,
      data: json['data'] ?? '',
      obs: json['obs'],
    );
  }

  bool get isEntrada => tipo == 'ENTRADA';
}

