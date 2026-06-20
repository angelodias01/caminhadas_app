import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'loja_screen.dart';
import 'rotas_screen.dart';
import 'historico_screen.dart';
import 'perfil_screen.dart';

/// Ecrã de navegação principal da aplicação (Host de Navegação).
///
/// Atua como a estrutura base que aloja a barra de navegação inferior
/// e faz a gestão da troca dinâmica entre os ecrãs principais do ecossistema.
class MainNavigationScreen extends StatefulWidget {
  /// Cria uma instância estável de [MainNavigationScreen].
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

/// Estado associado ao ecrã [MainNavigationScreen] que monitoriza a aba ativa.
///
/// Controla o índice da vista atual e aplica uma transição suave animada
/// de troca (fade) sempre que o utilizador seleciona um destino diferente.
class _MainNavigationScreenState extends State<MainNavigationScreen> {
  /// O índice numérico que representa a aba ou ecrã atualmente visível.
  int _currentIndex = 0;

  /// Coleção ordenada das subclasses de [Widget] correspondentes a cada destino.
  final List<Widget> _screens = [
    const DashboardScreen(),
    const RotasScreen(),
    const LojaScreen(),
    const HistoricoScreen(),
    const PerfilScreen(),
  ];

  static const _corPrincipalAzul = Colors.indigo;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        backgroundColor: cores.surface,
        indicatorColor: _corPrincipalAzul.withValues(alpha: 0.15),
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.directions_walk_rounded, color: Colors.grey),
            selectedIcon: Icon(Icons.directions_walk_rounded, color: _corPrincipalAzul),
            label: 'Passos',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.explore, color: _corPrincipalAzul),
            label: 'Trilhos',
          ),
          NavigationDestination(
            icon: Icon(Icons.store_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.store, color: _corPrincipalAzul),
            label: 'Loja',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded, color: Colors.grey),
            selectedIcon: Icon(Icons.history_toggle_off_rounded, color: _corPrincipalAzul),
            label: 'Histórico',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded, color: Colors.grey),
            selectedIcon: Icon(Icons.person_rounded, color: _corPrincipalAzul),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}