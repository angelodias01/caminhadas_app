/// Modelo de dados que representa o perfil de um utilizador no sistema.
///
/// Agrupa as credenciais básicas de identidade, dados demográficos, informações
/// de contacto e o registo acumulado da pontuação de mérito do utilizador.
class UserModel {

  /// O identificador único (UID) do utilizador gerado pelo sistema de autenticação.
  final String uid;

  /// O nome completo ou alcunha de exibição escolhida pelo utilizador.
  final String nome;

  /// O endereço eletrónico (e-mail) principal associado à conta.
  final String email;

  /// O endereço URL ou caminho local da imagem de avatar do perfil.
  final String fotoUrl;

  /// O saldo acumulado e atual de pontos de mérito disponíveis para troca na loja.
  final int pontos;

  /// A faixa etária ou idade declarada do utilizador.
  final String idade;

  /// O número de contacto telefónico associado à conta.
  final String contacto;

  /// O género biológico ou identidade de género declarada pelo utilizador.
  final String genero;

  /// Cria uma instância imutável de [UserModel].
  ///
  /// Todos os parâmetros de perfil são obrigatórios para garantir a integridade
  /// dos dados do utilizador ao longo do ciclo de vida da aplicação.
  UserModel({
    required this.uid,
    required this.nome,
    required this.email,
    required this.fotoUrl,
    required this.pontos,
    required this.idade,
    required this.contacto,
    required this.genero,
  });
}