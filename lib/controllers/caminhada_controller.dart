import '../models/atividade_model.dart';
import '../models/trilho_model.dart';

/// Controlador encarregue de processar as métricas de caminhadas diretas.
///
/// Fornece as fórmulas utilitárias necessárias para converter a contagem física de passos
/// em métricas de distância em quilómetros e atribuição de pontuações de mérito.
class CaminhadaController {

  /// Calcula a quantidade de pontos ganhos com base nos passos efetuados.
  ///
  /// O rácio de conversão atribui 1 ponto por cada fração completa de 100 passos.
  /// Retorna `0` se os [passos] forem negativos ou se ultrapassarem o teto diário
  /// de segurança fixado em 50.000 passos.
  int calcularPontos(int passos) {
    if (passos < 0 || passos > 50000) return 0;
    return (passos / 100).floor();
  }

  /// Converte a contagem de passos na distância equivalente em quilómetros.
  ///
  /// A estimativa baseia-se numa passada padrão média de 0.00075 km por passo.
  /// O resultado é formatado e retornado com precisão de uma casa decimal.
  /// Caso o argumento de [passos] seja menor ou igual a zero, devolve `0.0`.
  double calcularQuilometros(int passos) {
    if (passos <= 0) return 0.0;
    return double.parse((passos * 0.00075).toStringAsFixed(1));
  }
}