import 'dart:async';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controllers/atividade_controller.dart';

/// Ecrã principal de resumo de atividade do utilizador (Dashboard).
///
/// Apresenta graficamente o progresso diário de passos, pontos acumulados
/// e distância estimada em quilómetros, com animações de entrada.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  final AtividadeController _atividadeController = AtividadeController();
  int _passosAtuais = 0;
  StreamSubscription<int>? _subscricaoPassos;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _verificarEPedirPermissao();

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

  /// Verifica o estado da permissão de atividade física antes de iniciar os fluxos de escuta.
  Future<void> _verificarEPedirPermissao() async {
    try {
      PermissionStatus status = await Permission.activityRecognition.status;
      if (!status.isGranted) {
        status = await Permission.activityRecognition.request();
      }
      _iniciarContagemDePassos();
    } catch (_) {
      _iniciarContagemDePassos();
    }
  }

  /// Inicializa a contagem carregando dados da cache ou do Health Connect e abre a subscrição de streams.
  void _iniciarContagemDePassos() async {
    if (_subscricaoPassos != null) {
      _subscricaoPassos!.cancel();
      _subscricaoPassos = null;
    }

    int passosRecuperados = 0;

    try {
      Health conexaoHealth = Health();
      bool podeSincronizar = await conexaoHealth.isHealthConnectAvailable();

      if (podeSincronizar) {
        passosRecuperados = await _atividadeController.sincronizarEObterPassosDoSistema();
      } else {
        passosRecuperados = await _atividadeController.carregarPassosGuardados();
      }
    } catch (_) {
      passosRecuperados = await _atividadeController.carregarPassosGuardados();
    }

    if (mounted) {
      setState(() {
        _passosAtuais = passosRecuperados;
      });
    }

    _subscricaoPassos = _atividadeController.obterFluxoDePassos.listen(
      _noEventoPassos,
      onError: _noErroPassos,
    );
  }

  /// Callback executado a cada nova leitura validada pelo controlador de passos.
  void _noEventoPassos(int passos) {
    if (mounted) {
      setState(() {
        _passosAtuais = passos;
      });
    }
  }

  /// Fallback de segurança para interrupções abruptas nos sensores de telemetria.
  void _noErroPassos(Object error) {
    if (mounted) {
      setState(() {
        _passosAtuais = 0;
      });
    }
  }

  @override
  void dispose() {
    _subscricaoPassos?.cancel();
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