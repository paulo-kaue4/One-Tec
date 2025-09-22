import 'package:caixa_flutter/pages/CadastroClientePage.dart';
import 'package:flutter/material.dart';
import 'movimentacao_page.dart';
import 'grafico_page.dart';
import 'lista_cliente_page.dart';
import '/widgets/app_drawer.dart';
import '/widgets/custom_app_bar.dart';
import 'tela_inicial.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Home", isHome: true),
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFF0A0F2C),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 14),

            // Botão Clientes
            _menuContainer(context, "Clientes", Icons.person, () async {
              // Navegação normal para permitir voltar para a HomePage
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const ListaClientesPage()),
              );

              // Se result == true -> cadastro bem sucedido -> mostra SnackBar
              if (result == true) {
                ScaffoldMessenger.of(context)
                  ..clearSnackBars()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('Cliente cadastrado com sucesso!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
              }
            }),

            const SizedBox(height: 14),

            // Botão Produtos
            _menuContainer(context, "Produtos", Icons.shopping_bag, () {
              // Futuro: navegar para produtos
            }),

            const SizedBox(height: 14),

            // Botão Caixa
            _menuContainer(context, "Caixa", Icons.attach_money, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CaixaApp()),
              );
            }),

            const SizedBox(height: 14),

            // Botão Configurações
            _menuContainer(context, "Configurações", Icons.settings, () {
              // Futuro: navegar para configurações
            }),
          ],
        ),
      ),
    );
  }

  /// Menu container com ícone nativo do Flutter
  Widget _menuContainer(
      BuildContext context, String text, IconData icon, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF023859),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.black.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 30,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tela de Caixa com Abas
class CaixaApp extends StatelessWidget {
  const CaixaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0F2C),
        appBar: AppBar(
          title: const Text("Controle de Caixa"),

        leading: IconButton( // Parte de retorno para a tela anterior
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pushAndRemoveUntil(
        context,
          MaterialPageRoute(builder: (_) => const TelaInicial()),
        (route) => false, // remove todas as telas anteriores
          ),
        ),// Final do retorno




          backgroundColor: const Color(0xFF0A0F2C),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Movimentação"),
              Tab(text: "Gráfico"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MovimentacaoPage(),
            GraficoPage(),
          ],
        ),
      ),
    );
  }
}
