import '../models/atividade_model.dart';

/// Controlador responsável por gerir as regras de negócio associadas às atividades.
///
/// Contém funções para converter métricas de atividade física (como passos)
/// em recompensas de pontos e distâncias em quilómetros.
class AtividadeController {

  /// Calcula os pontos de recompensa com base no número de passos dados.
  ///
  /// O utilizador ganha 1 ponto por cada 100 passos completados.
  /// Se o número de [passos] for negativo ou ultrapassar o limite diário de 50.000,
  /// o retorno será `0`.
  int calcularPontos(int passos) {
    if (passos < 0 || passos > 50000) return 0;
    return (passos / 100).floor();
  }

  /// Converte o número de passos na distância aproximada em quilómetros.
  ///
  /// Utiliza um comprimento médio de passada estimado em 0.00075 km por passo.
  /// O valor retornado é arredondado para uma casa decimal.
  /// Se o número de [passos] for menor ou igual a zero, retorna `0.0`.
  double calcularQuilometros(int passos) {
    if (passos <= 0) return 0.0;
    return double.parse((passos * 0.00075).toStringAsFixed(1));
  }

  /// Obtém a listagem do histórico de atividades filtrada por um estado ou período.
  ///
  /// Retorna uma lista assíncrona de objetos [AtividadeModel] com base no [filtro] fornecido.
  Future<List<AtividadeModel>> obterHistorico(String filtro) async {
    return [];
  }
}