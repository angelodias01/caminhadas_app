import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health/health.dart';
import '../models/atividade_model.dart';

/// Controlador responsável pela gestão, filtragem e persistência da contagem de passos.
///
/// Utiliza uma estratégia híbrida: tenta ler o pedómetro nativo do sistema,
/// recorrendo ao Health Connect ou aos acelerómetros (bruto/linear) do dispositivo
/// como mecanismos de contingência adaptável.
class AtividadeController {
  static int _passosIniciaisNoBoot = -1;
  static int _passosPorAcelerometro = 0;
  static bool _passoDetetado = false;
  static int _ultimoPassoTimestamp = 0;

  final double _limiarPasso = 12.5;

  /// Recupera o histórico de passos armazenado localmente no dispositivo.
  Future<int> carregarPassosGuardados() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _passosPorAcelerometro = prefs.getInt('passos_offline_cache') ?? 0;
      return _passosPorAcelerometro;
    } catch (_) {
      return 0;
    }
  }

  /// Persiste a contagem atual de passos em armazenamento local de segurança.
  Future<void> _guardarPassosLocalmente(int passos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('passos_offline_cache', passos);
    } catch (_) {}
  }

  /// Sincroniza e obtém os passos acumulados do dia através da API Health Connect.
  Future<int> sincronizarEObterPassosDoSistema() async {
    try {
      Health health = Health();
      bool suporteDisponivel = false;

      try {
        suporteDisponivel = await health.isHealthConnectAvailable();
      } catch (_) {
        suporteDisponivel = false;
      }

      if (!suporteDisponivel) {
        return await carregarPassosGuardados();
      }

      final tipos = [HealthDataType.STEPS];
      bool? temPermissao = await health.hasPermissions(tipos);
      if (temPermissao == null || !temPermissao) {
        temPermissao = await health.requestAuthorization(tipos);
      }

      if (temPermissao) {
        DateTime agora = DateTime.now();
        DateTime inicioDoDia = DateTime(agora.year, agora.month, agora.day);
        int? passosDoSistema = await health.getTotalStepsInInterval(inicioDoDia, agora);

        if (passosDoSistema != null && passosDoSistema > _passosPorAcelerometro) {
          _passosPorAcelerometro = passosDoSistema;
          await _guardarPassosLocalmente(_passosPorAcelerometro);
          return _passosPorAcelerometro;
        }
      }
    } catch (e) {
      print('Erro na API de saúde: $e');
    }
    return await carregarPassosGuardados();
  }

  /// Algoritmo de filtragem matemática executado num Isolate secundário.
  ///
  /// Calcula a magnitude do vetor tridimensional e analisa a dominância de forças
  /// nos eixos verticais para isolar passos reais de falsos positivos mecânicos.
  static _ResultadoFiltro _processarFiltroDePassos(_DadosSensor dados) {
    double modulo = sqrt(dados.x * dados.x + dados.y * dados.y + dados.z * dados.z);
    double forcaVertical = dados.y.abs() + dados.z.abs();
    double forcaHorizontal = dados.x.abs();
    bool valido = modulo > dados.limiar && forcaVertical > (forcaHorizontal * 0.8);
    return _ResultadoFiltro(modulo, valido);
  }

  /// Disponibiliza um fluxo contínuo e em tempo real da contagem consolidada de passos.
  Stream<int> get obterFluxoDePassos {
    final controlador = StreamController<int>();
    StreamSubscription? subscricaoNativa;
    StreamSubscription? subscricaoLinear;
    StreamSubscription? subscricaoBruta;

    void ativarAcelerometroBruto() {
      subscricaoBruta = accelerometerEventStream().listen(
            (AccelerometerEvent event) async {
          final agora = DateTime.now().millisecondsSinceEpoch;
          final resultado = await compute(
              _processarFiltroDePassos,
              _DadosSensor(event.x, event.y, event.z, _limiarPasso)
          );

          if (resultado.validoParaPasso && !_passoDetetado) {
            if (agora - _ultimoPassoTimestamp > 180) {
              _passosPorAcelerometro++;
              _ultimoPassoTimestamp = agora;
              _guardarPassosLocalmente(_passosPorAcelerometro);
              controlador.add(_passosPorAcelerometro);
            }
            _passoDetetado = true;
          } else if (resultado.modulo < _limiarPasso - 2.5) {
            _passoDetetado = false;
          }
        },
        onError: (e) => controlador.add(_passosPorAcelerometro),
      );
    }

    void ativarAcelerometroLinear() {
      subscricaoLinear = userAccelerometerEventStream().listen(
            (UserAccelerometerEvent event) async {
          final agora = DateTime.now().millisecondsSinceEpoch;
          final resultado = await compute(
              _processarFiltroDePassos,
              _DadosSensor(event.x, event.y, event.z, 11.5)
          );

          if (resultado.validoParaPasso && !_passoDetetado) {
            if (agora - _ultimoPassoTimestamp > 180) {
              _passosPorAcelerometro++;
              _ultimoPassoTimestamp = agora;
              _guardarPassosLocalmente(_passosPorAcelerometro);
              controlador.add(_passosPorAcelerometro);
            }
            _passoDetetado = true;
          } else if (resultado.modulo < 9.5) {
            _passoDetetado = false;
          }
        },
        onError: (erro) {
          subscricaoLinear?.cancel();
          ativarAcelerometroBruto();
        },
      );

      Timer(const Duration(seconds: 2), () {
        if (_passosPorAcelerometro == 0 && controlador.hasListener && subscricaoBruta == null) {
          subscricaoLinear?.cancel();
          ativarAcelerometroBruto();
        }
      });
    }

    controlador.onListen = () {
      subscricaoNativa = Pedometer.stepCountStream.listen(
            (StepCount event) {
          if (_passosIniciaisNoBoot == -1) {
            _passosIniciaisNoBoot = event.steps;
          }
          final calculados = event.steps - _passosIniciaisNoBoot;
          final totalComCache = calculados + _passosPorAcelerometro;
          _guardarPassosLocalmente(totalComCache);
          controlador.add(totalComCache);
        },
        onError: (erro) {
          subscricaoNativa?.cancel();
          ativarAcelerometroLinear();
        },
        onDone: () => controlador.close(),
      );
    };

    controlador.onCancel = () {
      subscricaoNativa?.cancel();
      subscricaoLinear?.cancel();
      subscricaoBruta?.cancel();
    };

    return controlador.stream;
  }

  /// Converte a métrica de passos em pontuação gamificada dentro do intervalo permitido.
  int calcularPontos(int passos) => (passos < 0 || passos > 50000) ? 0 : (passos / 100).floor();

  /// Converte a métrica de passos em distância estimada percorrida quilómetros.
  double calcularQuilometros(int passos) => passos <= 0 ? 0.0 : double.parse((passos * 0.00075).toStringAsFixed(1));

  /// Recupera o histórico de atividades com base no filtro temporal parametrizado.
  Future<List<AtividadeModel>> obterHistorico(String filtro) async => [];
}

/// Contentor estrutural para transporte de dados brutos de telemetria entre Isolates.
class _DadosSensor {
  final double x; final double y; final double z; final double limiar;
  _DadosSensor(this.x, this.y, this.z, this.limiar);
}

/// Objeto de transferência com a resolução matemática pós-filtragem.
class _ResultadoFiltro {
  final double modulo; final bool validoParaPasso;
  _ResultadoFiltro(this.modulo, this.validoParaPasso);
}