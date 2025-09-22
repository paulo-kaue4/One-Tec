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
