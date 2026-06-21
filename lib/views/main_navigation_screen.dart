import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'loja_screen.dart';
import 'rotas_screen.dart';
import 'historico_screen.dart';
import 'perfil_screen.dart';

/// Contentor estrutural de navegação principal da aplicação (Shell).
///
/// Organiza e faz a gestão dos cinco ecrãs base através de um [PageView]
/// sincronizado com uma barra de navegação inferior [NavigationBar].
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _indiceAtual = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _indiceAtual);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Altera a página ativa através de uma animação suave ao tocar nos itens da barra.
  void _aoMudarDeAba(int indice) {
    setState(() {
      _indiceAtual = indice;
    });
    _pageController.animateToPage(
      indice,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Sincroniza o índice de seleção da barra inferior ao detetar o deslizar de ecrã (swipe).
  void _aoDeslizarEcra(int indice) {
    setState(() {
      _indiceAtual = indice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _aoDeslizarEcra,
        physics: const ClampingScrollPhysics(),
        children: const [
          DashboardScreen(),
          RotasScreen(),
          LojaScreen(),
          HistoricoScreen(),
          PerfilScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceAtual,
        onDestinationSelected: _aoMudarDeAba,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.directions_walk_rounded),
            label: 'Atividade',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_rounded),
            label: 'Rotas',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_rounded),
            label: 'Loja',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            label: 'Histórico',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}