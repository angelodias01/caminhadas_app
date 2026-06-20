/// Modelo de dados que representa o registo de uma atividade física diária realizada pelo utilizador.
///
/// Modela o sumário consolidado de esforço físico, guardando a contagem de passos,
/// a distância traduzida em quilómetros e o respetivo retorno em pontos de recompensa.
class AtividadeModel {

  /// A data e hora em que a atividade foi registada ou finalizada.
  final DateTime data;

  /// O número total de passos contabilizados durante o período da atividade.
  final int passos;

  /// A distância total percorrida expressa em quilómetros.
  final double quilometros;

  /// A quantidade de pontos de mérito atribuídos e ganhos com a realização desta atividade.
  final int pontosGanhos;

  /// Cria uma instância imutável de [AtividadeModel].
  ///
  /// Todos os parâmetros ([data], [passos], [quilometros] e [pontosGanhos])
  /// são de fornecimento obrigatório para a inicialização do objeto.
  AtividadeModel({
    required this.data,
    required this.passos,
    required this.quilometros,
    required this.pontosGanhos,
  });
}