class ItemEstoque {
  final int id;
  final String nome;
  final int quantidadeAtual;
  final String? categoria;
  final String? descricao;

  ItemEstoque({
    required this.id,
    required this.nome,
    required this.quantidadeAtual,
    this.categoria,
    this.descricao,
  });

  factory ItemEstoque.fromJson(Map<String, dynamic> json) {
    return ItemEstoque(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      quantidadeAtual: json['quantidadeAtual'] ?? 0,
      categoria: json['categoria'],
      descricao: json['descricao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'quantidadeAtual': quantidadeAtual,
      'categoria': categoria,
      'descricao': descricao,
    };
  }
}

