import 'package:caixa_flutter/pages/cadastro_produto_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tela_inicial.dart';
import '/widgets/app_drawer.dart';

final supabase = Supabase.instance.client;

class ListaProdutoPage extends StatefulWidget {
  const ListaProdutoPage({Key? key}) : super(key: key);

  @override
  State<ListaProdutoPage> createState() => _ListaProdutoPageState();
}

class _ListaProdutoPageState extends State<ListaProdutoPage> {
  List<Map<String, dynamic>> produtos = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProdutos();
  }

  Future<void> fetchProdutos() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase
          .from('produto')
          .select('id, descricao, preco_venda, categoria, unidade_medida')
          .order('descricao', ascending: true);

      final data = response as List<dynamic>;
      setState(() {
        produtos = data.map((e) => e as Map<String, dynamic>).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar produtos: $e')),
      );
    }
  }

  Future<void> deletarProduto(int id) async {
    try {
      await supabase.from('produto').delete().eq('id', id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto excluído com sucesso!')),
      );
      fetchProdutos(); // Atualiza lista
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir produto: $e')),
      );
    }
  }

  void abrirCadastro([Map<String, dynamic>? produto]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CadastroProdutoPage(produto: produto),
      ),
    ).then((_) => fetchProdutos());
  }

  @override
  Widget build(BuildContext context) {
    // Filtra os produtos pelo campo de pesquisa
    final filteredProdutos = produtos.where((produto) {
      final search = searchController.text.toLowerCase();
      final nome = (produto['descricao'] ?? '').toString().toLowerCase();
      return nome.contains(search);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C),
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Produtos'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo de pesquisa com botão de limpar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Pesquisar',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: const Color(0xFF1A1F3C),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: () {
                    searchController.clear();
                    setState(() {});
                  },
                ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Lista de produtos
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredProdutos.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum produto encontrado',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredProdutos.length,
                          itemBuilder: (context, index) {
                            final produto = filteredProdutos[index];
                            return Card(
                              color: const Color(0xFF1A1F3C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title: Text(
                                  produto['descricao'] ?? '',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'R\$ ${(produto['preco_venda'] ?? 0).toStringAsFixed(2)} • ${produto['categoria'] ?? ''} • ${produto['unidade_medida'] ?? ''}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.white),
                                      onPressed: () => abrirCadastro(produto),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        deletarProduto(produto['id'] as int);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            // Total de produtos
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Total: ${filteredProdutos.length}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => abrirCadastro(),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
