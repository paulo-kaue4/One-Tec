import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tela_inicial.dart';
import 'agendamento_page.dart';

final supabase = Supabase.instance.client;

class ListaAgendamentoPage extends StatefulWidget {
  const ListaAgendamentoPage({Key? key}) : super(key: key);

  @override
  State<ListaAgendamentoPage> createState() => _ListaAgendamentoPageState();
}

class _ListaAgendamentoPageState extends State<ListaAgendamentoPage> {
  DateTime _dataSelecionada = DateTime.now();
  List<Map<String, dynamic>> _agendamentosDoDia = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarAgendamentos();
  }

  Future<void> _carregarAgendamentos() async {
    setState(() => _carregando = true);

    // Formato compatível com Postgres (yyyy-MM-dd)
    final dataStr = DateFormat("yyyy-MM-dd").format(_dataSelecionada);

    final response = await supabase
        .from("agendamento")
        .select()
        .eq("dd_mm_aa", dataStr)
        .order("id", ascending: true);

    setState(() {
      _agendamentosDoDia = List<Map<String, dynamic>>.from(response);
      _carregando = false;
    });
  }

  Future<void> _abrirCalendario() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
      locale: const Locale("pt", "BR"),
    );
        if (picked != null && picked != _dataSelecionada) {
      setState(() {
        _dataSelecionada = picked;
      });
      await _carregarAgendamentos();();
    }
  }

  Future<void> _excluirAgendamento(int id) async {
    await supabase.from("agendamento").delete().eq("id", id);
    _carregarAgendamentos();
  }

  @override
  Widget build(BuildContext context) {
    final semana = List.generate(30, (i) {
      return DateTime(_dataSelecionada.year, _dataSelecionada.month,
          _dataSelecionada.day - _dataSelecionada.weekday + 1 + i);
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0F2C),
        elevation: 0,
        title: Text(
          DateFormat("MMMM yyyy", "pt_BR")
          .format(_dataSelecionada)
          .replaceFirstMapped(RegExp(r'^\w'), (m) => m.group(0)!.toUpperCase()),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold),    
          ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const TelaInicial()),
            (route) => false,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _abrirCalendario,
          )
        ],
      ),
      body: Column(
        children: [           
          //// Semana em carrossel
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: semana.length,
                itemBuilder: (context, index) {
                  final dia = semana[index];
                  final selecionado = dia.day == _dataSelecionada.day &&
                      dia.month == _dataSelecionada.month &&
                      dia.year == _dataSelecionada.year;
                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        _dataSelecionada = dia;
                      });
                      _carregarAgendamentos();
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selecionado
                            ? Colors.blueAccent
                            : const Color(0xFF1A1F3C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sab"]
                                [dia.weekday % 7],
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            "${dia.day}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selecionado
                                  ? Colors.white
                                  : Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          // Lista de agendamentos
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _agendamentosDoDia.isEmpty
                    ? const Center(
                        child: Text(
                          "Nenhum agendamento para esta data.",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _agendamentosDoDia.length,
                        itemBuilder: (context, index) {
                          final agendamento = _agendamentosDoDia[index];
                          return Card(
                            color: const Color(0xFF1A1F3C),
                            child: ListTile(
                              title: Text(
                                // Formata a data do banco
                                DateFormat("dd/MM/yyyy").format(
                                  DateTime.parse(agendamento["dd_mm_aa"]),
                                ),
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                agendamento["descricao"] ?? "",
                                style:
                                    const TextStyle(color: Colors.white70),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.white70),
                                    onPressed: () {
                                      // TODO: chamar tela de edição passando o agendamento
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      _excluirAgendamento(agendamento["id"]);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Total no rodapé
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Total: ${_agendamentosDoDia.length}",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),

      // Botão flutuante
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AgendamentoPage())
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
