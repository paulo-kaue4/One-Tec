import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Instância do Supabase
final supabase = Supabase.instance.client;

class CadastroProdutoPage extends StatefulWidget {
  final Map<String, dynamic>? produto; // 👈 recebe o produto quando for editar

  const CadastroProdutoPage({Key? key, this.produto}) : super(key: key);

  @override
  State<CadastroProdutoPage> createState() => _CadastroProdutoPageState();
}

class _CadastroProdutoPageState extends State<CadastroProdutoPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final descricaoController = TextEditingController();
  final precoVendaController = TextEditingController();
  final precoCustoController = TextEditingController();
  final estoqueController = TextEditingController();
  final codigoController = TextEditingController();
  final precoAtacadoController = TextEditingController();
  final precoVarejoController = TextEditingController();

  // Dropdowns
  String? selectedCategoria;
  String? selectedUnidade;

  List<String> categorias = [];
  List<String> unidades = [];
  bool isLoadingCategorias = true;
  bool isLoadingUnidades = true;

  @override
  void initState() {
    super.initState();
    fetchCategorias();
    fetchUnidades();

    // 👇 Se for edição, preencher os campos
    if (widget.produto != null) {
      descricaoController.text = widget.produto!['descricao'] ?? '';
      precoVendaController.text =
          widget.produto!['preco_venda']?.toString() ?? '';
      precoCustoController.text =
          widget.produto!['preco_custo']?.toString() ?? '';
      estoqueController.text =
          widget.produto!['estoque_produto']?.toString() ?? '';
      codigoController.text = widget.produto!['codigo_cean'] ?? '';
      precoAtacadoController.text =
          widget.produto!['preco_atacado']?.toString() ?? '';
      precoVarejoController.text =
          widget.produto!['preco_varejo']?.toString() ?? '';
      selectedCategoria = widget.produto!['categoria'];
      selectedUnidade = widget.produto!['unidade_medida'];
    }
  }

  Future<void> fetchCategorias() async {
    try {
      final data = await supabase.from('categoria').select() as List<dynamic>;
      setState(() {
        categorias = data.map((c) => c['nome'].toString()).toList();
        isLoadingCategorias = false;
      });
    } catch (e) {
      setState(() => isLoadingCategorias = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar categorias: $e')),
      );
    }
  }

  Future<void> fetchUnidades() async {
    try {
      final data =
          await supabase.from('unidade_medida').select() as List<dynamic>;
      setState(() {
        unidades = data.map((u) => u['nome'].toString()).toList();
        isLoadingUnidades = false;
      });
    } catch (e) {
      setState(() => isLoadingUnidades = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar unidades: $e')),
      );
    }
  }

  void limparCampos() {
    _formKey.currentState?.reset();
    descricaoController.clear();
    precoVendaController.clear();
    precoCustoController.clear();
    estoqueController.clear();
    codigoController.clear();
    precoAtacadoController.clear();
    precoVarejoController.clear();
    setState(() {
      selectedCategoria = null;
      selectedUnidade = null;
    });
  }

  Future<void> salvarProduto() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (widget.produto == null) {
          // 👇 Se não tiver produto, é CADASTRO
          await supabase.from('produto').insert({
            'descricao': descricaoController.text,
            'categoria': selectedCategoria,
            'preco_venda': double.tryParse(precoVendaController.text) ?? 0,
            'preco_custo': double.tryParse(precoCustoController.text),
            'estoque_produto': double.tryParse(estoqueController.text),
            'codigo_cean': codigoController.text.isEmpty
                ? 'SEM GTIN'
                : codigoController.text,
            'unidade_medida': selectedUnidade,
            'preco_atacado': double.tryParse(precoAtacadoController.text),
            'preco_varejo': double.tryParse(precoVarejoController.text),
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produto cadastrado com sucesso!')),
          );
        } else {
          // 👇 Se tiver produto, é EDIÇÃO
          await supabase
              .from('produto')
              .update({
                'descricao': descricaoController.text,
                'categoria': selectedCategoria,
                'preco_venda': double.tryParse(precoVendaController.text) ?? 0,
                'preco_custo': double.tryParse(precoCustoController.text),
                'estoque_produto': double.tryParse(estoqueController.text),
                'codigo_cean': codigoController.text.isEmpty
                    ? 'SEM GTIN'
                    : codigoController.text,
                'unidade_medida': selectedUnidade,
                'preco_atacado': double.tryParse(precoAtacadoController.text),
                'preco_varejo': double.tryParse(precoVarejoController.text),
              })
              .eq('id', widget.produto!['id']); // 👈 importante para atualizar certo

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produto atualizado com sucesso!')),
          );
        }

        Navigator.pop(context, true); // 👈 volta para lista e atualiza
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    }
  }

  InputDecoration buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF1A1F3C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.produto != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Produto' : 'Cadastro de Produto'),
        backgroundColor: const Color(0xFF0A0F2C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: descricaoController,
                decoration: buildInputDecoration('Descrição'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe a descrição' : null,
              ),
              const SizedBox(height: 16),
              isLoadingCategorias
                  ? const LinearProgressIndicator()
                  : DropdownButtonFormField<String>(
                      value: selectedCategoria,
                      items: categorias
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) => setState(() => selectedCategoria = val),
                      decoration: buildInputDecoration('Categoria'),
                      validator: (value) =>
                          value == null ? 'Selecione uma categoria' : null,
                    ),
              const SizedBox(height: 16),
              isLoadingUnidades
                  ? const LinearProgressIndicator()
                  : DropdownButtonFormField<String>(
                      value: selectedUnidade,
                      items: unidades
                          .map((u) =>
                              DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (val) => setState(() => selectedUnidade = val),
                      decoration: buildInputDecoration('Unidade de Medida'),
                    ),
              const SizedBox(height: 16),
              TextFormField(
                controller: precoVendaController,
                decoration: buildInputDecoration('Preço de Venda'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Informe o preço de venda'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: precoCustoController,
                decoration: buildInputDecoration('Preço de Custo'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: estoqueController,
                decoration: buildInputDecoration('Estoque'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: codigoController,
                decoration: buildInputDecoration('Código GTIN'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: precoAtacadoController,
                decoration: buildInputDecoration('Preço Atacado'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: precoVarejoController,
                decoration: buildInputDecoration('Preço Varejo'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: salvarProduto,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                    child: Text(isEdit ? 'Atualizar Produto' : 'Salvar Produto'),
                  ),
                  ElevatedButton(
                    onPressed: limparCampos,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: const Text('Limpar Campos'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
