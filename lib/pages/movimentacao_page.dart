import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/caixa_service.dart';
import '../models/caixa.dart';

class MovimentacaoPage extends StatefulWidget {
  @override
  State<MovimentacaoPage> createState() => _MovimentacaoPageState();
}

class _MovimentacaoPageState extends State<MovimentacaoPage> {
  final CaixaService service = CaixaService();
  final DateFormat df = DateFormat('dd/MM/yyyy');

  List<Caixa> lista = [];
  List<Caixa> listaFiltrada = [];

  final _nomeController = TextEditingController();
  final _valorController = TextEditingController();
  final _dataController = TextEditingController();
  String tipoSelecionado = "PIX";

  DateTime? dataIni;
  DateTime? dataFim;

  @override
  void initState() {
    super.initState();
    _dataController.text = df.format(DateTime.now());
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
    try {
      listaFiltrada = lista
          .where((c) =>
              c.data.isAfter(dataIni!.subtract(const Duration(days: 1))) &&
              c.data.isBefore(dataFim!.add(const Duration(days: 1))))
          .toList();
    } catch (_) {
      listaFiltrada = List.from(lista);
    }
    setState(() {});
  }

  String capitalizarNome(String nome) {
    if (nome.isEmpty) return '';
    return nome.split(' ').map((str) {
      if (str.isEmpty) return '';
      return str[0].toUpperCase() + str.substring(1).toLowerCase();
    }).join(' ');
  }

  String formatarValor(String valor) {
    try {
      double numero = double.parse(valor.replaceAll(',', '.'));
      return numero.toStringAsFixed(2);
    } catch (e) {
      return valor;
    }
  }

  Future<void> adicionar() async {
    if (_nomeController.text.trim().isEmpty ||
        _valorController.text.trim().isEmpty) {
      mostrarErro("Preencha nome e valor");
      return;
    }

    try {
      final c = Caixa(
        nome: capitalizarNome(_nomeController.text.trim()),
        data: df.parse(_dataController.text),
        tipoPagamento: tipoSelecionado,
        valor: double.parse(formatarValor(_valorController.text.trim())),
      );

      await service.adicionarRegistro(c);
      await carregarDados();

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lançamento registrado com sucesso!'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.green,
        ),
      );

      limparCampos();
    } catch (e) {
      mostrarErro("Erro ao adicionar: $e");
    }
  }

  void limparCampos() {
    _nomeController.clear();
    _valorController.clear();
    _dataController.text = df.format(DateTime.now());
    tipoSelecionado = "PIX";
    setState(() {});
  }

  Future<void> deletar(Caixa c) async {
    await service.deletarRegistro(c);
    await carregarDados();
  }

  void mostrarErro(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  void abrirModalAdicionar() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF1A1F3C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Lançamento de Caixa",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: _nomeController,
                  decoration: InputDecoration(
                    labelText: "Nome",
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green)),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _valorController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Valor R\$",
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green)),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: tipoSelecionado,
                  dropdownColor: Colors.black,
                  items: service.PAYMENT_TYPES
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e,
                                style: const TextStyle(color: Colors.white)),
                          ))
                      .toList(),
                  decoration: InputDecoration(
                    labelText: "Forma de Pagamento",
                    labelStyle: const TextStyle(color: Colors.white),
                    suffixIcon:
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                  ),
                  onChanged: (v) => setState(() => tipoSelecionado = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _dataController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Data",
                    labelStyle: const TextStyle(color: Colors.white),
                    suffixIcon:
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      _dataController.text = df.format(picked);
                    }
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          onPressed: adicionar,
                          child: const Text("Adicionar")),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey),
                          onPressed: limparCampos,
                          child: const Text("Limpar")),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 Caixa padrão para filtro de datas
  Widget _buildDateBox(String label, DateTime? date, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0F2C),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date != null ? df.format(date) : label,
                style: const TextStyle(color: Colors.white),
              ),
              const Icon(Icons.calendar_today,
                  size: 18, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildDateBox("Data Inicial", dataIni, () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: dataIni ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => dataIni = picked);
                  }
                }),
                const SizedBox(width: 12),
                _buildDateBox("Data Final", dataFim, () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: dataFim ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => dataFim = picked);
                  }
                }),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: aplicarFiltro,
                  icon: const Icon(Icons.filter_alt,
                      color: Color(0xFF4FB0E1), size: 30),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: listaFiltrada.length,
              itemBuilder: (_, i) {
                final c = listaFiltrada[i];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  color: const Color(0xFF1A1F3C),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text("${c.nome} - ${c.tipoPagamento}",
                        style: const TextStyle(
                            color: Color(0xE0FFFFFF),
                            fontWeight: FontWeight.bold)),
                    subtitle: Text(df.format(c.data)),
                    trailing: Text(
                      "R\$ ${c.valor.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00BF50)),
                    ),
                    onLongPress: () => deletar(c),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Saldo: R\$ ${listaFiltrada.fold<double>(0, (soma, c) => soma + c.valor).toStringAsFixed(2)}",
        style: const TextStyle(color: Colors.white),
                ),
                Text(
                  "Total: ${listaFiltrada.length}",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: abrirModalAdicionar,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
    );
  }
}
