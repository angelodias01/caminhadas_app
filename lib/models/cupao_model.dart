/// Modelo de dados que representa um cupão ou recompensa comercial no sistema.
///
/// Modela os dados de um voucher gerado para troca de pontos, incluindo a sua
/// identificação, o estabelecimento parceiro emissor e o estado atual de usufruto.
class CupaoModel {

  /// O identificador único do cupão na base de dados.
  final String id;

  /// O título descritivo do prémio ou oferta comercial (ex: "Desconto de 10%").
  final String titulo;

  /// O nome ou localização do estabelecimento parceiro onde o cupão pode ser resgatado.
  final String local;

  /// A quantidade de pontos de mérito necessários para adquirir ou trocar por este cupão.
  final int custoPontos;

  /// Indica se o cupão já foi validado e consumido no local de destino (`true`) ou se ainda está ativo (`false`).
  final bool utilizado;

  /// Cria uma instância imutável de [CupaoModel].
  ///
  /// Requer obrigatoriamente a passagem de todos os parâmetros ([id], [titulo],
  /// [local], [custoPontos] e [utilizado]) para a validação da estrutura.
  CupaoModel({
    required this.id,
    required this.titulo,
    required this.local,
    required this.custoPontos,
    required this.utilizado,
  });
}