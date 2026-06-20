import '../models/cupao_model.dart';

/// Controlador encarregue de gerir as operações de mercado da loja de recompensas.
///
/// Trata do carregamento de cupões comerciais disponíveis para troca e faz a gestão
/// dos vouchers adquiridos por parte do utilizador, bem como o processo de compra.
class LojaController {

  /// Recupera a listagem completa de prémios e recompensas ativas na plataforma.
  ///
  /// Retorna uma lista assíncrona de objetos [CupaoModel] que se encontram
  /// elegíveis e disponíveis para troca de pontos no momento atual.
  Future<List<CupaoModel>> obterPremiosDisponiveis() async {
    return [];
  }

  /// Obtém os cupões já adquiridos pertencentes ao utilizador autenticado.
  ///
  /// Filtra a lista assíncrona de objetos [CupaoModel] com base no [estado] especificado,
  /// permitindo a separação entre cupões 'Ativos' (prontos a usar) ou 'Utilizados'.
  Future<List<CupaoModel>> obterMeusCupoes(String estado) async {
    return [];
  }

  /// Efetua o processo de aquisição e resgate de um determinado prémio da loja.
  ///
  /// Recebe o [premioId] identificador único da recompensa e deduz os pontos necessários.
  /// Retorna `true` se a transação e a atribuição do novo cupão forem efetuadas com sucesso.
  Future<bool> comprarCupao(String premioId) async {
    return true;
  }
}