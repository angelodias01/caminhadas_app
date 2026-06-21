import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'views/login_screen.dart';
import 'controllers/atividade_controller.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

/// Ponto de entrada principal da aplicação.
///
/// Inicializa as ligações nativas, dispara o serviço em segundo plano
/// e recupera a preferência guardada do tema do sistema.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await inicializarServicoBackground();

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

/// Inicializa o subsistema de execução perpétua em segundo plano.
///
/// Configura os parâmetros nativos necessários para manter o rastreio
/// ativo em plataformas Android (Foreground Service) e iOS.
Future<void> inicializarServicoBackground() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: noStartDoServico,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'passos_channel',
      initialNotificationTitle: 'Caminhadas Odemira',
      initialNotificationContent: 'A acompanhar a tua atividade...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onBackground: (service) => false,
    ),
  );
}

/// Ponto de entrada isolado executado pelo processo nativo do serviço.
///
/// Liga o controlador de telemetria à cache local do disco e atualiza
/// a barra de notificações do sistema operacional em tempo real.
@pragma('vm:entry-point')
void noStartDoServico(ServiceInstance service) async {
  final controlador = AtividadeController();

  controlador.obterFluxoDePassos.listen((passos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('passos_offline_cache', passos);

    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
          title: "Caminhadas Odemira",
          content: "Passos atuais: $passos",
        );
      }
    }
  });
}

/// Elemento mestre da aplicação que define as configurações globais de estilo e navegação.
class CaminhadasApp extends StatefulWidget {
  final ThemeMode temaInicial;

  const CaminhadasApp({super.key, required this.temaInicial});

  @override
  State<CaminhadasApp> createState() => _CaminhadasAppState();

  static _CaminhadasAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_CaminhadasAppState>();
  }
}

/// Estado associado ao elemento mestre [CaminhadasApp].
class _CaminhadasAppState extends State<CaminhadasApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.temaInicial;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarEPedirPermissao();
    });
  }

  /// Solicita de forma sequencial as permissões críticas da aplicação.
  ///
  /// Introduz um intervalo de tolerância para sincronização do fluxo visual
  /// nativo de diálogos do sistema.
  Future<void> _verificarEPedirPermissao() async {
    var statusAtividade = await Permission.activityRecognition.status;
    if (!statusAtividade.isGranted) {
      statusAtividade = await Permission.activityRecognition.request();
    }

    await Future.delayed(const Duration(milliseconds: 300));

    var statusNotificacao = await Permission.notification.status;
    if (!statusNotificacao.isGranted) {
      await Permission.notification.request();
    }

    if (statusAtividade.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  /// Retorna o modo de tema atual configurado na aplicação.
  ThemeMode get themeMode => _themeMode;

  /// Determina dinamicamente se a aplicação está a rodar em modo escuro.
  bool get isDarkMode => _themeMode == ThemeMode.system
      ? View.of(context).platformDispatcher.platformBrightness == Brightness.dark
      : _themeMode == ThemeMode.dark;

  /// Alterna o estado visual entre os perfis de luminosidade disponíveis.
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