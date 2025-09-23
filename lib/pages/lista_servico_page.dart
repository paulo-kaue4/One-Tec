import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tela_inicial.dart';
import '../widgets/app_drawer.dart';
import 'cadastro_servico_page.dart';

final supabase = Supabase.instance.client;

class ListaServicoPage extends StatefulWidget {
  const ListaServicoPage({Key? key}) : super(key: key);

  @override
  State<ListaServicoPage> createState() => _ListaServicoPageState();
}

class _ListaServicoPageState extends State<ListaServicoPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _servicos = [];
  bool _loading = true;
  String _filtro = "";

  @override
  void initState() {
    super.initState();
    _buscarServicos();
  }

  Future<void> _buscarServicos() async {
    setState(() => _loading = true);
    final response = await supabase
        .from('servico')
        .select()
        .order('created_at', ascending: false);
    setState(() {
      _servicos = response;
      _loading = false;
    });
  }

  Future<void> _excluirServico(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir este serviço?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir')),
        ],
      ),
    );

    if (confirm != true) return;

    await supabase.from('servico').delete().eq('id', id);
    _buscarServicos();
  }

  @override
  Widget build(BuildContext context) {
    final servicosFiltrados = _servicos.where((s) {
      return s['descricao_servico']
          .toString()
          .toLowerCase()
          .contains(_filtro.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C),
      appBar: AppBar(
        title: const Text("Serviços"),
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
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Campo de pesquisa
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _filtro = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Pesquisar",
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _filtro = "");
                  },
                ),
                filled: true,
                fillColor: const Color(0xFF1A1F3C),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : servicosFiltrados.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum serviço encontrado',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: servicosFiltrados.length,
                        itemBuilder: (context, index) {
                          final servico = servicosFiltrados[index];
                          return Card(
                            color: const Color(0xFF1A1F3C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: ListTile(
                              title: Text(
                                servico['descricao_servico'],
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                "R\$ ${servico['preco_servico']}",
                                style: const TextStyle(color: Colors.white70),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.white),
                                    onPressed: () async {
                                      final atualizado = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              CadastroServicosPage(
                                                  servico: servico),
                                        ),
                                      );
                                      if (atualizado == true) {
                                        _buscarServicos();
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _excluirServico(servico['id']),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Rodapé com total
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Total: ${servicosFiltrados.length}",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),

      // Botão flutuante para adicionar serviço
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final novoServico = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CadastroServicosPage(),
            ),
          );
          if (novoServico == true) {
            _buscarServicos();
          }
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
