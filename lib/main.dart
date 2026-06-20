import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/login_screen.dart';
import 'views/main_navigation_screen.dart';

/// Ponto de entrada principal da aplicação.
///
/// Inicializa as ligações nativas do ecossistema Flutter, efetua o carregamento
/// assíncrono das preferências locais de tema do utilizador em disco e faz o arranque
/// da árvore de widgets da aplicação.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ThemeMode temaInicial = ThemeMode.system;

  try {
    final prefs = await SharedPreferences.getInstance();
    final temaGuardado = prefs.getString('tema_preferido') ?? 'system';

    if (temaGuardado == 'light') {
      temaInicial = ThemeMode.light;
    } else if (temaGuardado == 'dark') {
      temaInicial = ThemeMode.dark;
    }
  } catch (_) {
    temaInicial = ThemeMode.system;
  }

  runApp(CaminhadasApp(temaInicial: temaInicial));
}

/// Elemento mestre da aplicação que define as configurações globais de estilo e navegação.
class CaminhadasApp extends StatefulWidget {
  /// O modo de tema capturado persistentemente durante a rotina de inicialização.
  final ThemeMode temaInicial;

  /// Cria uma instância estável de [CaminhadasApp].
  const CaminhadasApp({super.key, required this.temaInicial});

  @override
  State<CaminhadasApp> createState() => _CaminhadasAppState();

  /// Procura e herda o estado de [_CaminhadasAppState] mais próximo na árvore de contextos.
  ///
  /// Fornece acesso global exposto a widgets filhos para despoletar a troca
  /// dinâmica de temas através do métod público [alternarTema].
  static _CaminhadasAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_CaminhadasAppState>();
  }
}

/// Estado associado ao elemento mestre [CaminhadasApp] responsável por reajustar o tema ativo.
class _CaminhadasAppState extends State<CaminhadasApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.temaInicial;
  }

  /// Expõe o modo de tema atual aplicado na aplicação.
  ThemeMode get themeMode => _themeMode;

  /// Retorna de forma binária (`true` ou `false`) se o utilizador navega sob uma interface escura.
  ///
  /// Caso o [_themeMode] esteja acoplado às definições globais do sistema, consome
  /// diretamente as propriedades nativas de brilho do dispositivo.
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return View.of(context).platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  /// Inverte de forma síncrona o estado do tema e persiste a nova chave no disco local.
  ///
  /// Avalia as dependências de sistema do dispositivo para comutação inteligente
  /// e aciona o métod [setState] para redesenhar imediatamente as janelas da app.
  Future<void> alternarTema() async {
    ThemeMode novoTema;
    String temaString;

    if (_themeMode == ThemeMode.system) {
      final isPlatformDark = View.of(context).platformDispatcher.platformBrightness == Brightness.dark;
      novoTema = isPlatformDark ? ThemeMode.light : ThemeMode.dark;
    } else {
      novoTema = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    }

    if (novoTema == ThemeMode.light) {
      temaString = 'light';
    } else if (novoTema == ThemeMode.dark) {
      temaString = 'dark';
    } else {
      temaString = 'system';
    }

    setState(() {
      _themeMode = novoTema;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tema_preferido', temaString);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Passos & Trilhos',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}