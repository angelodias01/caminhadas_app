/// Modelo de dados que representa um trilho ou percurso pedestre na aplicação.
///
/// Modela as especificações técnicas de um caminho de caminhada, incluindo a sua
/// extensão, nível de exigência física, recompensas associadas e o estado de progresso.
class TrilhoModel {

  /// O identificador único do trilho na base de dados.
  final String id;

  /// O nome oficial atribuído ao percurso ou desafio pedestre.
  final String nome;

  /// A região, freguesia ou ponto geográfico onde o trilho se localiza ou inicia.
  final String localidade;

  /// A extensão total do percurso medida em quilómetros.
  final double distanciaKm;

  /// A quantidade de pontos extra ou de bónus atribuída ao utilizador após a conclusão do desafio.
  final int bonusPontos;

  /// O nível de exigência física e técnica do percurso (ex: 'Fácil', 'Médio', 'Difícil').
  final String dificuldade;

  /// O estado atual do desafio para o utilizador.
  ///
  /// Deve conter obrigatoriamente um dos seguintes valores: 'A decorrer', 'Concluídos' ou 'Expirados'.
  final String estado;

  /// Cria uma instância imutável de [TrilhoModel].
  ///
  /// Requer a definição obrigatória de todos os parâmetros estruturais do percurso
  /// no momento da sua construção.
  TrilhoModel({
    required this.id,
    required this.nome,
    required this.localidade,
    required this.distanciaKm,
    required this.bonusPontos,
    required this.dificuldade,
    required this.estado,
  });
}