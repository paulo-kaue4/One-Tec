import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class CadastroServicosPage extends StatefulWidget {
  final Map<String, dynamic>? servico; // ✅ serviço opcional para edição

  const CadastroServicosPage({Key? key, this.servico}) : super(key: key);

  @override
  State<CadastroServicosPage> createState() => _CadastroServicosPageState();
}

class _CadastroServicosPageState extends State<CadastroServicosPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.servico != null) {
      _descricaoController.text = widget.servico!['descricao_servico'];
      _precoController.text =
          widget.servico!['preco_servico'].toString().replaceAll('.', ',');
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  Future<void> _salvarServico() async {
    if (!_formKey.currentState!.validate()) return;

    final descricao = _descricaoController.text.trim();
    final precoText = _precoController.text.replaceAll('.', '').replaceAll(',', '.');
    final preco = double.tryParse(precoText) ?? 0.0;

    try {
      if (widget.servico == null) {
        // Adicionar novo serviço
        await supabase.from('servico').insert({
          'descricao_servico': descricao,
          'preco_servico': preco,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Serviço cadastrado com sucesso!")),
        );
      } else {
        // Atualizar serviço existente
        await supabase.from('servico').update({
          'descricao_servico': descricao,
          'preco_servico': preco,
        }).eq('id', widget.servico!['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Serviço atualizado com sucesso!")),
        );
      }
      _limparCampos();
      Navigator.pop(context, true); // volta pra lista e atualiza
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e")),
      );
    }
  }

  void _limparCampos() {
    _descricaoController.clear();
    _precoController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final bool editando = widget.servico != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C),
      appBar: AppBar(
        title: Text(editando ? "Editar Serviço" : "Cadastro de Serviço"),
        backgroundColor: const Color(0xFF0A0F2C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F3C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _descricaoController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Descrição",
                    labelStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Informe a descrição";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F3C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _precoController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Preço do Serviço",
                    labelStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _CurrencyPtBrInputFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Informe o preço";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _salvarServico,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: editando ? Colors.orange : Colors.green,
                      ),
                      child: Text(editando ? "Salvar Alterações" : "Adicionar"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _limparCampos,
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
      ),
    );
  }
}

/// Formatter para moeda no padrão brasileiro com vírgula
class _CurrencyPtBrInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter =
      NumberFormat.currency(locale: 'pt_BR', symbol: '', decimalDigits: 2);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final value = double.parse(newValue.text) / 100;
    final newText = _formatter.format(value);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
