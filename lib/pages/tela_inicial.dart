import 'package:flutter/material.dart';
import '/widgets/app_drawer.dart';
import '/widgets/custom_app_bar.dart';

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: const CustomAppBar(title: "Home", isHome: true),
      drawer: const AppDrawer(),
      
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
            
          ],
        ),
      ),
    );
  }
}
