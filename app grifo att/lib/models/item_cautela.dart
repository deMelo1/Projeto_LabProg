class ItemCautela {
  final int id;
  final String nome;
  final int quantidadeTotal;
  final String? categoria;
  final String? descricao;

  ItemCautela({
    required this.id,
    required this.nome,
    required this.quantidadeTotal,
    this.categoria,
    this.descricao,
  });

  factory ItemCautela.fromJson(Map<String, dynamic> json) {
    return ItemCautela(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      quantidadeTotal: json['quantidadeTotal'] ?? 1,
      categoria: json['categoria'],
      descricao: json['descricao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'quantidadeTotal': quantidadeTotal,
      'categoria': categoria,
      'descricao': descricao,
    };
  }
}

