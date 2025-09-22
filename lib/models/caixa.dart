class Caixa {
  final String nome;
  final DateTime data;
  final String tipoPagamento;
  final double valor;

  Caixa({
    required this.nome,
    required this.data,
    required this.tipoPagamento,
    required this.valor,
  });

  factory Caixa.fromJson(Map<String, dynamic> json) {
    return Caixa(
      nome: json['nome'],
      data: DateTime.parse(json['data']),
      tipoPagamento: json['tipo_pagamento'],
      valor: double.parse(json['valor'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'data': data.toIso8601String(),
        'tipo_pagamento': tipoPagamento,
        'valor': valor,
      };
}
