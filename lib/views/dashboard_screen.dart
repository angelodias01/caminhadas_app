import 'package:flutter/material.dart';
import '../controllers/atividade_controller.dart';

/// Ecrã principal de resumo de atividade do utilizador (Dashboard).
///
/// Apresenta de forma visual e animada o progresso diário de passos do utilizador,
/// a conversão correspondente em quilómetros e os pontos de mérito acumulados.
class DashboardScreen extends StatefulWidget {
  /// Cria uma instância estável de [DashboardScreen].
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

/// Estado associado ao ecrã [DashboardScreen] que gere os controladores de animação.
///
/// Implementa [SingleTickerProviderStateMixin] para alimentar as transições fluidas
/// de escala e opacidade no carregamento inicial dos dados.
class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  /// Instância do controlador de negócio para calcular pontos e distâncias.
  final AtividadeController _atividadeController = AtividadeController();

  /// Contador temporário de passos registados no dia atual.
  final int _passosAtuais = 0;

  /// Controlador mestre do ciclo de vida das animações do ecrã.
  late AnimationController _animationController;

  /// Animação encarregue de aplicar o efeito de crescimento (escala) no anel central.
  late Animation<double> _scaleAnimation;

  /// Animação encarregue de esbater (fade-in) os elements informativos textuais e cartões.
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    int pontos = _atividadeController.calcularPontos(_passosAtuais);
    double km = _atividadeController.calcularQuilometros(_passosAtuais);

    const corPrincipalAzul = Colors.indigo;
    const corPontosLaranja = Colors.amber;

    return Scaffold(
      backgroundColor: cores.surface,
      appBar: AppBar(
        title: const Text('Passos & Atividade', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        centerTitle: true,
        backgroundColor: cores.surface,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cores.surfaceContainerLow,
                            boxShadow: [
                              BoxShadow(
                                color: corPrincipalAzul.withValues(alpha: 0.15),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              )
                            ],
                            border: Border.all(color: corPrincipalAzul.withValues(alpha: 0.2), width: 12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$_passosAtuais',
                                style: const TextStyle(fontSize: 54, fontWeight: FontWeight.w900, color: corPrincipalAzul, letterSpacing: -1),
                              ),
                              Text(
                                'passos hoje',
                                style: TextStyle(color: cores.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 0,
                            color: cores.surfaceContainerLow,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: corPrincipalAzul.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.directions_walk_rounded, color: corPrincipalAzul, size: 28),
                                  ),
                                  const SizedBox(height: 12),
                                  Text('Distância', style: TextStyle(color: cores.onSurfaceVariant, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 4),
                                  Text('$km km', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: cores.onSurface)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Card(
                            elevation: 0,
                            color: cores.surfaceContainerLow,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: corPontosLaranja.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.stars_rounded, color: corPontosLaranja, size: 28),
                                  ),
                                  const SizedBox(height: 12),
                                  Text('Pontos', style: TextStyle(color: cores.onSurfaceVariant, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 4),
                                  Text('$pontos pts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: cores.onSurface)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}