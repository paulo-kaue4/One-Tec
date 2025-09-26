import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/caixa_service.dart';
import '../models/caixa.dart';
import 'tela_inicial.dart';

class GraficoPage extends StatefulWidget {
  @override
  State<GraficoPage> createState() => _GraficoPageState();
}

class _GraficoPageState extends State<GraficoPage> {
  final CaixaService service = CaixaService();
  final DateFormat df = DateFormat('dd/MM/yyyy');
  final NumberFormat currency =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  List<Caixa> lista = [];
  List<Caixa> listaFiltrada = [];

  DateTime? dataIni;
  DateTime? dataFim;

  @override
  void initState() {
    super.initState();
    final hoje = DateTime.now();
    dataIni = DateTime(hoje.year, hoje.month, 1);
    dataFim = DateTime(hoje.year, hoje.month + 1, 0);
    carregarDados();
  }

  Future<void> carregarDados() async {
    lista = await service.carregarDados();
    aplicarFiltro();
  }

  void aplicarFiltro() {
    if (dataIni == null || dataFim == null) {
      listaFiltrada = List.from(lista);
    } else {
      listaFiltrada = lista
          .where((c) =>
              c.data.isAfter(dataIni!.subtract(const Duration(days: 1))) &&
              c.data.isBefore(dataFim!.add(const Duration(days: 1))))
          .toList();
    }
    setState(() {});
  }

  Future<void> _pickDate(bool isInicial) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isInicial ? dataIni! : dataFim!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      setState(() {
        if (isInicial) {
          dataIni = picked;
        } else {
          dataFim = picked;
        }
      });
      aplicarFiltro();
    }
  }

  Color _colorForKey(String key) {
    switch (key.toUpperCase()) {
      case 'BOLETO':
        return Color.fromARGB(255, 60, 187, 219);
      case 'CARTÃO':
      case 'CARTAO':
        return Color.fromARGB(255, 50, 153, 167);
      case 'DINHEIRO':
        return Color(0xFF2F8FC3);
      case 'PIX':
        return Color(0xFF3A5270);
      default:
        return Color(0xFF9AA8B2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dados = service.agregadosPorForma(listaFiltrada);
    final ordem = ['PIX', 'BOLETO', 'CARTÃO', 'CARTAO', 'DINHEIRO'];
    final keysOrdered = <String>[];
    for (final o in ordem) {
      if (dados.keys.any((k) => k.toUpperCase() == o)) {
        final realKey = dados.keys.firstWhere((k) => k.toUpperCase() == o);
        if (!keysOrdered.contains(realKey)) keysOrdered.add(realKey);
      }
    }
    for (final k in dados.keys) {
      if (!keysOrdered.contains(k)) keysOrdered.add(k);
    }

    final total = dados.values.fold<double>(0.0, (s, v) => s + v.toDouble());

    final sections = <PieChartSectionData>[];
    for (int i = 0; i < keysOrdered.length; i++) {
      final k = keysOrdered[i];
      final value = dados[k]!.toDouble();
      final percent = total > 0 ? (value / total) * 100 : 0.0;
      final color = _colorForKey(k);
      sections.add(
        PieChartSectionData(
          value: value,
          color: color,
          title: '${percent.toStringAsFixed(1)}%',
          radius: 90,
          titleStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titlePositionPercentageOffset: 0.95,
          showTitle: true,
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C),
      appBar: AppBar(
        title: const Text("Relatório"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const TelaInicial()),
            (route) => false,
          ),
        ),
        backgroundColor: const Color(0xFF0A0F2C),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// 🔹 Filtros de data no mesmo estilo da aba Movimentação
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickDate(true),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Color(0xFF0D1230),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dataIni != null
                                  ? df.format(dataIni!)
                                  : 'Data Inicial',
                              style: TextStyle(color: Colors.white),
                            ),
                            Icon(Icons.calendar_today,
                                size: 18, color: Colors.white70),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickDate(false),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Color(0xFF0D1230),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dataFim != null
                                  ? df.format(dataFim!)
                                  : 'Data Final',
                              style: TextStyle(color: Colors.white),
                            ),
                            Icon(Icons.calendar_today,
                                size: 18, color: Colors.white70),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  IconButton(
                    onPressed: aplicarFiltro,
                    icon: Icon(Icons.filter_alt,
                        color: Color(0xFF4FB0E1), size: 30),
                  ),
                ],
              ),
            ),

            /// 🔹 Título Resumo Mensal
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Resumo Mensal',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),

            /// 🔹 Gráfico central
            SizedBox(
              height: 320,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 70,
                      sectionsSpace: 6,
                      startDegreeOffset: -90,
                      pieTouchData: PieTouchData(enabled: false),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 6),
                      Text(
                        currency.format(total),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            /// 🔹 Legenda (base da tela, vertical)
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF0D1230),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Legenda',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: keysOrdered.map((k) {
                            final v = dados[k] ?? 0.0;
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 6.0),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Color(0xFF0A0F2C),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: _colorForKey(k),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        k,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                    ),
                                    Text(
                                      currency.format(v),
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
