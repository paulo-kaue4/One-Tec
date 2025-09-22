import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'CadastroClientePage.dart';
import '/widgets/app_drawer.dart';
import 'tela_inicial.dart';

class ListaClientesPage extends StatefulWidget {
  const ListaClientesPage({super.key});

  @override
  State<ListaClientesPage> createState() => _ListaClientesPageState();
}

class _ListaClientesPageState extends State<ListaClientesPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> clientes = [];
  List<dynamic> clientesFiltrados = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarClientes();
  }

  Future<void> carregarClientes() async {
    final response = await supabase.from('cliente').select().order('id');
    setState(() {
      clientes = response;
      clientesFiltrados = response;
    });
  }

  void filtrarClientes(String query) {
    setState(() {
      clientesFiltrados = clientes
          .where((c) =>
              (c['nome'] as String).toLowerCase().contains(query.toLowerCase()) ||
              (c['nome_fantasia'] as String).toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> excluirCliente(int id) async {
    await supabase.from('cliente').delete().eq('id', id);
    carregarClientes();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Cliente excluído com sucesso",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> abrirCadastro({Map<String, dynamic>? cliente}) async {
    final bool? result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CadastroClientePage(cliente: cliente),
      ),
    );

    if (result == true) {
      carregarClientes();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cliente == null
                ? "Cliente cadastrado com sucesso"
                : "Cliente atualizado com sucesso",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0F2C),
        elevation: 0,

      leading: IconButton( // Parte de retorno para a tela anterior
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pushAndRemoveUntil(
        context,
      MaterialPageRoute(builder: (_) => const TelaInicial()),
        (route) => false, // remove todas as telas anteriores
        ),
      ),// Final do retorno

        title: const Text(
          "Clientes",
          style: TextStyle(color: Colors.white),
        ),
      ),
      drawer: const AppDrawer(), // drawer funcional com swipe
      body: Column(
        children: [
          // Campo de busca
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: filtrarClientes,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Pesquisar",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: const Color(0xFF1A1F3C),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Lista de clientes
          Expanded(
            child: ListView.builder(
              itemCount: clientesFiltrados.length,
              itemBuilder: (context, index) {
                final cliente = clientesFiltrados[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1F3C),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      cliente['nome'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      cliente['nome_fantasia'] ?? '',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () => abrirCadastro(cliente: cliente),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => excluirCliente(cliente['id']),
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
            padding: const EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Total: ${clientesFiltrados.length}",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),

      // Botão flutuante
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () => abrirCadastro(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
