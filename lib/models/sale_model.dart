class Sale {
  final int? id;
  final String nome;
  final String pagamento;
  final double valor;
  final DateTime data;

  Sale({
    this.id,
    required this.nome,
    required this.pagamento,
    required this.valor,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'pagamento': pagamento,
      'valor': valor,
      'data': data.millisecondsSinceEpoch,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      nome: map['nome'],
      pagamento: map['pagamento'],
      valor: map['valor'],
      data: DateTime.fromMillisecondsSinceEpoch(map['data']),
    );
  }
}
