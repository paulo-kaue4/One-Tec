import 'dart:async';
import 'package:caixa_flutter/pages/tela_inicial.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_drawer.dart';

final supabase = Supabase.instance.client;

class AgendamentoPage extends StatefulWidget {
  const AgendamentoPage({Key? key}) : super(key: key);

  @override
  State<AgendamentoPage> createState() => _AgendamentoPageState();
}

class _AgendamentoPageState extends State<AgendamentoPage> {
  DateTime _dataSelecionada = DateTime.now();
  String? _horarioSelecionado;
  final TextEditingController _descricaoController = TextEditingController();

  List<String> _horario = []; // Agora será carregado do banco
  Map<String, String> _horariosOcupados = {};

  @override
  void initState() {
    super.initState();
    _carregarHorarios();
    _carregarHorariosOcupados();
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  // Formatar data para YYYY-MM-DD
  String _formatarData(DateTime dt) {
    return "${dt.year.toString().padLeft(4, '0')}-"
           "${dt.month.toString().padLeft(2, '0')}-"
           "${dt.day.toString().padLeft(2, '0')}";
  }

  // Formatar hora HH:MM:SS -> HH:MM
  String _formatarHora(String hora) {
    final partes = hora.split(":");
    final hh = partes[0].padLeft(2, '0');
    final mm = partes[1].padLeft(2, '0');
    return "$hh:$mm";
  }

  // Carregar horários da tabela "horario"
  Future<void> _carregarHorarios() async {
    try {
      final response = await supabase.from('horario').select('hora');
      final List dataList = response as List;
      setState(() {
        _horario = [for (var e in dataList) e['hora'] as String];
      });
    } catch (e) {
      setState(() {
        _horario = [];
      });
    }
  }

  // Carregar horários ocupados da tabela "agendamento"
  Future<void> _carregarHorariosOcupados() async {
    final dataStr = _formatarData(_dataSelecionada);
    try {
      final response = await supabase
          .from('agendamento')
          .select('hh_mm, descricao')
          .eq('dd_mm_aa', dataStr);

      final List dataList = response as List;
      setState(() {
        _horariosOcupados = {
          for (var e in dataList) e['hh_mm'] as String: e['descricao'] as String
        };
        // Limpa seleção somente se o horário já estiver ocupado
        if (_horarioSelecionado != null &&
            _horariosOcupados.containsKey(_horarioSelecionado)) {
          _horarioSelecionado = null;
        }
      });
    } catch (e) {
      setState(() {
        _horariosOcupados = {};
      });
    }
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
      await _carregarHorariosOcupados();
    }
  }

  List<DateTime> _diasDaSemana(DateTime date) {
    final inicioSemana = date.subtract(Duration(days: date.weekday % 7));
    return List.generate(30, (i) => inicioSemana.add(Duration(days: i)));
  }

  Future<void> _salvarAgendamento() async {
    if (_horarioSelecionado == null || _descricaoController.text.isEmpty) return;

    try {
      await supabase.from('agendamento').insert({
        'dd_mm_aa': _formatarData(_dataSelecionada),
        'hh_mm': _horarioSelecionado,
        'descricao': _descricaoController.text,
      });

      setState(() {
        _horariosOcupados[_horarioSelecionado!] = _descricaoController.text;
        _horarioSelecionado = null;
        _descricaoController.clear();
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Agendamento salvo com sucesso!")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao salvar: $e")),
      );
    }
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
                    onTap: () async {
                      setState(() {
                        _dataSelecionada = dia;
                        _horarioSelecionado = null;
                      });
                      await _carregarHorariosOcupados();
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

            TextField(
              controller: _descricaoController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Descrição",
                labelStyle: const TextStyle(color: Colors.white),
                filled: true,
                fillColor: const Color(0xFF1A1F3C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Horários disponíveis",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _horario.length,
                itemBuilder: (context, index) {
                  final hora = _horario[index];
                  final descricao = _horariosOcupados[hora];
                  final ocupada = descricao != null;
                  final selecionado = hora == _horarioSelecionado;

                  Widget botao = Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ocupada
                          ? Colors.grey
                          : (selecionado ? Colors.green : Colors.blueAccent),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatarHora(hora), // <-- Aqui aplicamos HH:MM
                      style: const TextStyle(color: Colors.white),
                    ),
                  );

                  if (ocupada) {
                    botao = Tooltip(message: descricao, child: botao);
                  }

                  return GestureDetector(
                    onTap: ocupada
                        ? null
                        : () {
                            setState(() {
                              _horarioSelecionado = hora;
                            });
                          },
                    child: botao,
                  );
                },
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _horarioSelecionado == null ||
                            _descricaoController.text.isEmpty
                        ? null
                        : _salvarAgendamento,
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
                        _descricaoController.clear();
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
