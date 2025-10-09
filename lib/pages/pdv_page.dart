import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PdvPage extends StatefulWidget {
  const PdvPage({super.key});

  @override
  State<PdvPage> createState() => _PdvPageState();
}

class _PdvPageState extends State<PdvPage> {
  final supabase = Supabase.instance.client;

  List<dynamic> produtos = []; // produtos retornados pela pesquisa (grid direito)
  List<Map<String, dynamic>> selecionados = []; // produtos adicionados ao PDV (grid esquerdo)
  bool carregando = false;
  final TextEditingController _pesquisaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarProdutos(); // carrega tudo inicialmente
  }

  // Carrega produtos do Supabase. Se filtro vazio => todos; caso contrário, busca por similaridade.
  Future<void> _carregarProdutos({String filtro = ''}) async {
    setState(() => carregando = true);

    try {
      dynamic response;

      if (filtro.isEmpty) {
        // Carrega todos os produtos (ou limite se preferir)
        response = await supabase
            .from('produto')
            .select('id, descricao, preco_venda, imagem_produto, codigo_cean')
            .order('descricao');
      } else {
        // Busca parecida em descricao e codigo_cean
        final descricao = await supabase
            .from('produto')
            .select('id, descricao, preco_venda, imagem_produto, codigo_cean')
            .ilike('descricao', '%$filtro%');

        final codigo = await supabase
            .from('produto')
            .select('id, descricao, preco_venda, imagem_produto, codigo_cean')
            .ilike('codigo_cean', '%$filtro%');

        // Se o filtro for número, tenta buscar pelo id exato
        final idNum = int.tryParse(filtro);
        List<dynamic> id = [];
        if (idNum != null) {
          id = await supabase
              .from('produto')
              .select('id, descricao, preco_venda, imagem_produto, codigo_cean')
              .eq('id', idNum);
        }

        // Junta e remove duplicados
        final todos = [...descricao, ...codigo, ...id];
        final vistos = <dynamic>{};
        response = todos.where((p) => vistos.add(p['id'])).toList();
      }

      setState(() {
        produtos = response ?? [];
      });
    } catch (e) {
      debugPrint('Erro ao carregar produtos: $e');
      setState(() {
        produtos = [];
      });
    } finally {
      setState(() => carregando = false);
    }
  }

  // Adiciona produto aos selecionados (ou incrementa quantidade se já existir)
  void _adicionarSelecionado(Map<String, dynamic> produto) {
    final id = produto['id'];
    final idx = selecionados.indexWhere((p) => p['id'] == id);
    final preco = (produto['preco_venda'] != null)
        ? double.tryParse(produto['preco_venda'].toString()) ?? 0.0
        : 0.0;
    final imagem = produto['imagem_produto']?.toString() ?? '';
    final descricao = produto['descricao']?.toString() ?? 'Sem nome';

    setState(() {
      if (idx != -1) {
        selecionados[idx]['qty'] = (selecionados[idx]['qty'] as int) + 1;
      } else {
        selecionados.add({
          'id': id,
          'descricao': descricao,
          'preco_venda': preco,
          'imagem_produto': imagem,
          'qty': 1,
        });
      }
    });
  }

  // Altera quantidade do item selecionado; se qty <= 0 remove o item
  void _alterarQuantidadeSelecionado(int index, int delta) {
    setState(() {
      final current = selecionados[index];
      final novo = (current['qty'] as int) + delta;
      if (novo <= 0) {
        selecionados.removeAt(index);
      } else {
        selecionados[index]['qty'] = novo;
      }
    });
  }

  double _calcularTotal() {
    double total = 0.0;
    for (final item in selecionados) {
      final preco = (item['preco_venda'] != null)
          ? double.tryParse(item['preco_venda'].toString()) ?? 0.0
          : 0.0;
      final qty = item['qty'] as int? ?? 1;
      total += preco * qty;
    }
    return total;
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEF1), //0xFFEEEEF1
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWide = constraints.maxWidth > 900;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Painel esquerdo (selecionados e campos)
                Expanded(
                  flex: isWide ? 4 : 10,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Campo de busca (liga com a pesquisa)
                        TextField(
                          controller: _pesquisaController,
                          onChanged: (valor) {
                            _carregarProdutos(filtro: valor.trim());
                          },
                          decoration: InputDecoration(
                            hintText: 'Pesquise produto por código, nome ou ID',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Itens de Vendas',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1A1F3C),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Lista de produtos selecionados (painel esquerdo)
                        Expanded(
                          child: selecionados.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Nenhum item selecionado',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: selecionados.length,
                                  itemBuilder: (context, index) {
                                    final item = selecionados[index];
                                    final nome =
                                        item['descricao']?.toString() ?? '';
                                    final preco = (item['preco_venda'] != null)
                                        ? double.tryParse(
                                                item['preco_venda'].toString()) ??
                                            0.0
                                        : 0.0;
                                    final qty = item['qty'] as int? ?? 1;
                                    final imagem =
                                        item['imagem_produto']?.toString() ?? '';

                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 6.0),
                                      padding: const EdgeInsets.all(6.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFFFFFFF),
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // Imagem do produto
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              imagem.isNotEmpty
                                                  ? imagem
                                                  : 'https://via.placeholder.com/50x50.png?text=Sem+Img',
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Image.network(
                                                  'https://via.placeholder.com/50x50.png?text=Erro',
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 10),

                                          // Nome e preço
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  nome,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color.fromARGB(
                                                        255, 0, 0, 0),
                                                  ),
                                                ),
                                                Text(
                                                  'R\$ ${preco.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                        221, 177, 177, 177),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Controle de quantidade
                                          Row(
                                            children: [
                                              _buildQtyButton(
                                                Icons.remove,
                                                () => _alterarQuantidadeSelecionado(
                                                    index, -1),
                                              ),
                                              Container(
                                                width: 35,
                                                height: 35,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color:
                                                        Colors.grey.shade400,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color: Colors.white,
                                                ),
                                                child: Text(
                                                  qty.toString(),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              _buildQtyButton(
                                                Icons.add,
                                                () => _alterarQuantidadeSelecionado(
                                                    index, 1),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),

                        const SizedBox(height: 8),

                        // Campos inferiores (mantidos)
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Desconto (R\$)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Acréscimo (R\$)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Cliente',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Vendedor',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A1F3C),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: () {
                            // Aqui você pode implementar a finalização da venda
                          },
                          child: Text(
                            'Finalizar R\$ ${_calcularTotal().toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 18, color: Color(0xFFFFFFFF)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Grade de produtos (lado direito) — mostra resultados da pesquisa
                if (isWide)
                  Expanded(
                    flex: 6, //6
                    child: Container(
                      color: const Color(0xFFEEEEF1),
                      padding: const EdgeInsets.all(16),
                      child: carregando
                          ? const Center(child: CircularProgressIndicator())
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3, //3 quantidade de itens na lista
                                mainAxisSpacing: 12, // 12
                                crossAxisSpacing: 12, // 12
                                childAspectRatio: 0.7, // altura do card
                              ),
                              itemCount: produtos.length,
                              itemBuilder: (context, index) {
                                final produto =
                                    Map<String, dynamic>.from(produtos[index]);
                                final imagem =
                                    produto['imagem_produto']?.toString() ?? '';
                                final nome =
                                    produto['descricao']?.toString() ?? 'Sem nome';
                                final preco = (produto['preco_venda'] != null)
                                    ? double.tryParse(
                                            produto['preco_venda'].toString()) ??
                                        0.0
                                    : 0.0;

                                return Card(
                                  color: const Color(0xFFFFFFFF),
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: InkWell(
                                    onTap: () => _adicionarSelecionado(produto),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(0.0), //12
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              imagem.isNotEmpty
                                                  ? imagem
                                                  : 'https://via.placeholder.com/100x100.png?text=Sem+Imagem',
                                              width: 200,
                                              height: 200,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                  stackTrace) {
                                                return Image.network(
                                                  'https://via.placeholder.com/100x100.png?text=Erro+Imagem',
                                                  width: 200,
                                                  height: 2000,
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            nome,
                                            textAlign: TextAlign.center,
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            'R\$ ${preco.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1A1F3C),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Botões + / - (mantive aparência — agora com onTap)
  static Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, size: 18, color: Colors.black87),
        ),
      ),
    );
  }
}
