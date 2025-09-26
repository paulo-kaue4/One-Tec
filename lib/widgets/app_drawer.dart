import 'package:caixa_flutter/pages/grafico_page.dart';
import 'package:flutter/material.dart';
import '../pages/lista_cliente_page.dart';
import '../pages/lista_produto_page.dart';
import '../pages/lista_servico_page.dart';
import '../pages/agendamento_page.dart';
import '../pages/movimentacao_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1A1F3C),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text("One Tec"),
            accountEmail: Text("p.kauê.pkk@gmail.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Color(0xFF1A1F3C),
              child: Text(
                "OT",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
          ),

          // Cadastros
          ListTile(
            leading: const Icon(Icons.people, color: Colors.pink),
            title: const Text("Clientes"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ListaClientesPage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.shopping_bag, color: Colors.pink),
            title: const Text("Produtos"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ListaProdutoPage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.build, color: Colors.pink),
            title: const Text("Serviços"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ListaServicoPage()),
              );
            },
          ),

          const Divider(),

          // Vandas
          ListTile(
            leading: const Icon(Icons.calendar_today, color: Colors.pink),
            title: const Text("Agendamentos"),
            onTap: () {
              Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AgendamentoPage())
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.restaurant_menu, color: Colors.pink),
            title: const Text("Comandas"),
            onTap: () {
              // Futuro
            },
          ),

          ListTile(
            leading: const Icon(Icons.assignment_turned_in_rounded, color: Colors.pink),
            title: const Text("Ordem de Serviço"),
            onTap: () {
              // Futuro
            },
          ),

          ListTile(
            leading: const Icon(Icons.point_of_sale, color: Colors.pink),
            title: const Text("Vendas"),
            onTap: () {
              // Futuro
            },
          ),

          const Divider(),

          // Caixa
          ListTile(
            leading: const Icon(Icons.attach_money, color: Colors.pink),
            title: const Text("Caixa"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MovimentacaoPage()),
              );
            },
          ),

          const Divider(),

        // Relatódios
          ListTile(
          leading: const Icon(Icons.bar_chart, color: Colors.pink),
          title: const Text("Relatórios"),
          onTap: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GraficoPage()),
            ); 
            },
          ),

          const Divider(),

        // COnfigurações
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.pink),
            title: const Text("Configurações"),
            onTap: () {
              // Futuro
            },
          ),
        ],
      ),
    );
  }
}
