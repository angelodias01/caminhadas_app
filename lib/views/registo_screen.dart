import 'package:flutter/material.dart';
import 'main_navigation_screen.dart';

/// Ecrã responsável pelo registo e criação de novas contas de utilizador.
///
/// Apresenta o formulário de recolha de dados iniciais (Nome, E-mail e credenciais),
/// aplicando animações sincronizadas de entrada e gerindo os redirecionamentos de
/// navegação segura.
class RegistoScreen extends StatefulWidget {
  /// Cria uma instância estável de [RegistoScreen].
  const RegistoScreen({super.key});

  @override
  State<RegistoScreen> createState() => _RegistoScreenState();
}

/// Estado associado ao ecrã [RegistoScreen] que gere os controladores de texto e o ciclo de vida da animação.
///
/// Rege o comportamento dos campos de texto do formulário e as transições
/// de opacidade e escala acionadas no carregamento inicial da vista.
class _RegistoScreenState extends State<RegistoScreen> with SingleTickerProviderStateMixin {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _passRepetidaController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  static const _corPrincipalAzul = Colors.indigo;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _passRepetidaController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Finaliza o processo de registo e encaminha o utilizador para a área principal da app.
  ///
  /// Utiliza um [PageRouteBuilder] com efeito de esbatimento de 400 milissegundos
  /// e limpa por completo a pilha de ecrãs anterior (`(route) => false`) por motivos de segurança.
  void _registar() {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) => const MainNavigationScreen(),
        transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cores.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _corPrincipalAzul.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.directions_walk_rounded, size: 64, color: _corPrincipalAzul),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Criar Conta',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: _corPrincipalAzul, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _nomeController,
                    decoration: InputDecoration(
                      labelText: 'Nome Completo',
                      filled: true,
                      fillColor: cores.surfaceContainerLow,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: _corPrincipalAzul),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      filled: true,
                      fillColor: cores.surfaceContainerLow,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.mail_outline_rounded, color: _corPrincipalAzul),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Palavra-passe',
                      filled: true,
                      fillColor: cores.surfaceContainerLow,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.lock_open_rounded, color: _corPrincipalAzul),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passRepetidaController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Repetir Palavra-passe',
                      filled: true,
                      fillColor: cores.surfaceContainerLow,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: _corPrincipalAzul),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _corPrincipalAzul,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _registar,
                    child: const Text('Criar Conta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: _corPrincipalAzul),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Já tem conta? Inicie sessão aqui', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}