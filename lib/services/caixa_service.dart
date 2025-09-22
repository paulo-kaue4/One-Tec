import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/caixa.dart';

class CaixaService {
  final supabase = Supabase.instance.client;
  final PAYMENT_TYPES = ["PIX", "BOLETO", "CARTÃO", "DINHEIRO"];

  Future<List<Caixa>> carregarDados() async {
    final response = await supabase.from('caixa').select().order('data', ascending: false);
    return (response as List).map((e) => Caixa.fromJson(e)).toList();
  }

  Future<void> adicionarRegistro(Caixa c) async {
    await supabase.from('caixa').insert(c.toJson());
  }

  Future<void> atualizarRegistro(Caixa oldC, Caixa newC) async {
    await supabase.from('caixa').update(newC.toJson()).match({
      'nome': oldC.nome,
      'data': oldC.data.toIso8601String(),
      'tipo_pagamento': oldC.tipoPagamento,
      'valor': oldC.valor,
    });
  }

  Future<void> deletarRegistro(Caixa c) async {
    await supabase.from('caixa').delete().match({
      'nome': c.nome,
      'data': c.data.toIso8601String(),
      'tipo_pagamento': c.tipoPagamento,
      'valor': c.valor,
    });
  }

  // Totais e agregados
  double saldoMensal(List<Caixa> list, {DateTime? refDate}) {
    if (list.isEmpty) return 0.0;
    refDate ??= DateTime.now();
    final mes = refDate.month;
    final ano = refDate.year;
    return list
        .where((c) => c.data.month == mes && c.data.year == ano)
        .fold(0.0, (prev, c) => prev + c.valor);
  }

  Map<String, double> agregadosPorForma(List<Caixa> list) {
    Map<String, double> mapa = {for (var f in PAYMENT_TYPES) f: 0.0};
    for (var c in list) {
      mapa[c.tipoPagamento] = (mapa[c.tipoPagamento] ?? 0) + c.valor;
    }
    return mapa;
  }

  Map<String, int> quantidadePorForma(List<Caixa> list) {
    Map<String, int> mapa = {for (var f in PAYMENT_TYPES) f: 0};
    for (var c in list) {
      mapa[c.tipoPagamento] = (mapa[c.tipoPagamento] ?? 0) + 1;
    }
    return mapa;
  }
}
