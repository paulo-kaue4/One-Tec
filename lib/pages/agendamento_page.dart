import 'package:caixa_flutter/pages/tela_inicial.dart';
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class AgendamentoPage extends StatefulWidget {
  const AgendamentoPage({Key? key}) : super(key: key);

  @override
  State<AgendamentoPage> createState() => _AgendamentoPageState();
}

class _AgendamentoPageState extends State<AgendamentoPage> {
  DateTime _dataSelecionada = DateTime.now();
  String? _horarioSelecionado;

  // Lista de horários fixos
  final List<String> horarios = [
    "08:00", "08:30", "09:00",
    "09:30", "10:00", "10:30",
    "11:00", "11:30", "13:30",
    "14:00", "14:30", "15:00",
    "15:30", "16:00", "16:30",
    "17:00", "17:30", "18:00",
  ];

  // Abre o calendário mensal
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
    }
  }

  // Gera a semana atual (7 dias a partir do domingo/segunda)
  List<DateTime> _diasDaSemana(DateTime date) {
    final inicioSemana = date.subtract(Duration(days: date.weekday % 7));
    return List.generate(7, (i) => inicioSemana.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final diasSemana = _diasDaSemana(_dataSelecionada);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text("Agendamentos"),
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
          ),
        ],
        backgroundColor: const Color(0xFF1A1F3C),
      ),
      body: Container(
        color: const Color(0xFF0E1330),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Semana em carrossel
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: diasSemana.length,
                itemBuilder: (context, index) {
                  final dia = diasSemana[index];
                  final selecionado = dia.day == _dataSelecionada.day &&
                      dia.month == _dataSelecionada.month &&
                      dia.year == _dataSelecionada.year;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _dataSelecionada = dia;
                      });
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

            const SizedBox(height: 20),
            const Text(
              "Horários disponíveis",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 10),

            // Grid de horários
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: horarios.length,
                itemBuilder: (context, index) {
                  final hora = horarios[index];
                  final selecionado = hora == _horarioSelecionado;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _horarioSelecionado = hora;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selecionado
                            ? Colors.green
                            : Colors.blueAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        hora,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Botões
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _horarioSelecionado == null
                        ? null
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Agendado ${_horarioSelecionado!} em ${_dataSelecionada.day}/${_dataSelecionada.month}",
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text("Agendar"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _horarioSelecionado = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text("Limpar"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
