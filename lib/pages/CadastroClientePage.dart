import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CadastroClientePage extends StatefulWidget {
  final Map<String, dynamic>? cliente; // recebe cliente para editar (opcional)

  CadastroClientePage({Key? key, this.cliente}) : super(key: key);

  @override
  _CadastroClientePageState createState() => _CadastroClientePageState();
}

class _CadastroClientePageState extends State<CadastroClientePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController nomeFantasiaController = TextEditingController();
  final TextEditingController celularController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cepController = TextEditingController();
  final TextEditingController enderecoController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController complementoController = TextEditingController();

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    // Se vier um cliente (modo edição), preencher os controllers
    if (widget.cliente != null) {
      final c = widget.cliente!;
      nomeController.text = c['nome'] ?? '';
      nomeFantasiaController.text = c['nome_fantasia'] ?? '';
      celularController.text = c['celular'] ?? '';
      emailController.text = c['email'] ?? '';
      cepController.text = c['cep'] ?? '';
      enderecoController.text = c['endereco'] ?? '';
      numeroController.text = c['numero_casa'] != null ? c['numero_casa'].toString() : '';
      complementoController.text = c['complemento_endereco'] ?? '';
    }
  }

  // Função para limpar campos
  void limparCampos() {
    nomeController.clear();
    nomeFantasiaController.clear();
    celularController.clear();
    emailController.clear();
    cepController.clear();
    enderecoController.clear();
    numeroController.clear();
    complementoController.clear();
  }

  // Função para adicionar/atualizar cliente
  Future<void> cadastrarCliente() async {
    // valida somente os campos que têm validator (no seu código só nome tem validator)
    if (!_formKey.currentState!.validate()) return;

    // Monta os dados, enviando null para campos opcionais vazios
    final Map<String, dynamic> dados = {
      'nome': nomeController.text,
      'nome_fantasia': nomeFantasiaController.text.isNotEmpty ? nomeFantasiaController.text : null,
      'celular': celularController.text.isNotEmpty ? celularController.text : null,
      'email': emailController.text.isNotEmpty ? emailController.text : null,
      'cep': cepController.text.isNotEmpty ? cepController.text : null,
      'endereco': enderecoController.text.isNotEmpty ? enderecoController.text : null,
      'numero_casa': numeroController.text.isNotEmpty ? int.tryParse(numeroController.text) : null,
      'complemento_endereco': complementoController.text.isNotEmpty ? complementoController.text : null,
    };

    try {
      if (widget.cliente == null) {
        // Inserção (novo cliente)
        final response = await supabase.from('cliente').insert(dados);

        if (response != null && response.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao cadastrar cliente: ${response.error!.message}')),
          );
          return;
        }

        // Sucesso no insert
        limparCampos();
        Navigator.pop<bool>(context, true);
      } else {
        // Atualização (edição) — usa o id do cliente
        final int id = widget.cliente!['id'];
        final response = await supabase.from('cliente').update(dados).eq('id', id);

        if (response != null && response.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao atualizar cliente: ${response.error!.message}')),
          );
          return;
        }

        // Sucesso no update
        // opcional: não precisa limpar, mas mantemos consistência
        limparCampos();
        Navigator.pop<bool>(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar cliente: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0F2C),
      appBar: AppBar(
        title: Text("Cadastro de Cliente"),
        backgroundColor: Color(0xFF0A0F2C)
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Informações Pessoais
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF14193B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Informações Pessoais", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: nomeController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Nome",
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white30),
                          ),
                        ),
                        validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
                      ),
                      TextFormField(
                        controller: nomeFantasiaController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Nome Fantasia",
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white30),
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: celularController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Celular",
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white30),
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: emailController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "E-mail",
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Endereço
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF14193B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Endereço", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: cepController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "CEP",
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white30),
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: enderecoController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Endereço",
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white30),
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: numeroController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Nº",
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white30),
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: complementoController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Complemento (Opcional)",
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Botões
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: cadastrarCliente,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: Text("Adicionar"),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: limparCampos,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                        child: Text("Limpar"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
