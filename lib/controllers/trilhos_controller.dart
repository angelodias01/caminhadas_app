import '../models/trilho_model.dart';

/// Controlador encarregue de gerir as rotas e percursos pedestres da aplicação.
///
/// Serve de ponte para a listagem, consulta e filtragem de trilhos geográficos
/// e desafios de caminhada associados ao ecossistema da plataforma.
class TrilhosController {

  /// Consulta e filtra a listagem de percursos pedestres e desafios disponíveis.
  ///
  /// Filtra a lista assíncrona de objetos [TrilhoModel] de acordo com o [filtro]
  /// de estado enviado (como 'A decorrer', 'Concluídos' ou 'Expirados').
  Future<List<TrilhoModel>> obterTrilhosPorFiltro(String filtro) async {
    return [];
  }
}