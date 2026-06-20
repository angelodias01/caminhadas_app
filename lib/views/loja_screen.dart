import 'package:flutter/material.dart';
import '../controllers/loja_controller.dart';
import '../models/cupao_model.dart';

/// Ecrã do mercado ou loja de recompensas da aplicação (Troca de Pontos).
///
/// Divide-se em duas secções: a listagem de prémios e vouchers disponíveis para compra,
/// e a área pessoal contendo a coleção de cupões adquiridos pelo utilizador,
/// divididos entre o estado ativo (pronto a usar via QR Code) e o estado utilizado.
class LojaScreen extends StatefulWidget {
  /// Cria uma instância estável de [LojaScreen].
  const LojaScreen({super.key});

  @override
  State<LojaScreen> createState() => _LojaScreenState();

}


/// Estado associado ao ecrã [LojaScreen] que monitoriza a paginação e filtros de cupões.
///
/// Trata do preenchimento dinâmico das listas através do consumo assíncrono das funções
/// expostas pelo [LojaController].
class _LojaScreenState extends State<LojaScreen> {
  /// Identificador da aba superior ativa na interface ('Comprar' ou 'Os Meus Cupões').
  String _abaAtual = 'Comprar';

  /// Identificador do sub-filtro selecionado para a carteira de cupões ('Ativos' ou 'Utilizados').
  String _filtroMeusCupoes = 'Ativos';

  /// Instância do controlador de negócio da loja de pontos.
  final LojaController _controller = LojaController();

  /// Cache local da lista de recompensas disponíveis para troca imediata.
  List<CupaoModel> _premiosDisponiveis = [];

  /// Cache local da lista de cupões associados à carteira pessoal do utilizador.
  List<CupaoModel> _meusCupoes = [];

  /// Sinalizador visual de carregamento ou transição de dados de rede do controlador.
  bool _carregando = false;

  static const _corPrincipalAzul = Colors.indigo;
  static const _corPontosLaranja = Colors.amber;

  @override
  void initState() {
    super.initState();
    _atualizarDados();
  }

  /// Despoleta a atualização assíncrona dos registos da lista com base na navegação de abas.
  Future<void> _atualizarDados() async {
    setState(() => _carregando = true);
    if (_abaAtual == 'Comprar') {
      _premiosDisponiveis = await _controller.obterPremiosDisponiveis();
    } else {
      _meusCupoes = await _controller.obterMeusCupoes(_filtroMeusCupoes);
    }
    setState(() => _carregando = false);
  }

  /// Exibe uma folha modal inferior ([BottomSheet]) contendo o QR Code de validação do prémio.
  ///
  /// Recebe o [cupaoId] para mapear e gerar a chave única legível pelo leitor do parceiro local.
  void _mostrarQRCodeCupao(BuildContext context, String cupaoId) {
    final cores = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      backgroundColor: cores.surface,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: cores.onSurfaceVariant.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text('Validar Recompensa', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            const SizedBox(height: 8),
            Text('Apresente este código no local para desativar o cupão.',
                textAlign: TextAlign.center,
                style: TextStyle(color: cores.onSurfaceVariant, fontSize: 14)
            ),
            const SizedBox(height: 24),
            Container(
              width: 200,
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _corPrincipalAzul.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: const Icon(Icons.qr_code_2_rounded, size: 160, color: _corPrincipalAzul),
            ),
            const SizedBox(height: 24),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: _corPrincipalAzul),
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cores.surface,
      appBar: AppBar(
        title: const Text('Troca de Pontos', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        centerTitle: true,
        backgroundColor: cores.surface,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['Comprar', 'Os Meus Cupões'].map((aba) {
                final ativo = _abaAtual == aba;
                return ChoiceChip(
                  label: Text(aba),
                  selected: ativo,
                  showCheckmark: false,
                  selectedColor: _corPrincipalAzul,
                  backgroundColor: cores.surfaceContainerLow,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: BorderSide.none,
                  labelStyle: TextStyle(
                    color: ativo ? Colors.white : cores.onSurfaceVariant,
                    fontWeight: ativo ? FontWeight.bold : FontWeight.w500,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _abaAtual = aba);
                      _atualizarDados();
                    }
                  },
                );
              }).toList(),
            ),
          ),
          if (_abaAtual == 'Os Meus Cupões')
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ['Ativos', 'Utilizados'].map((subFiltro) {
                  final ativo = _filtroMeusCupoes == subFiltro;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ChoiceChip(
                      label: Text(subFiltro, style: const TextStyle(fontSize: 13)),
                      selected: ativo,
                      showCheckmark: false,
                      selectedColor: _corPrincipalAzul.withValues(alpha: 0.15),
                      backgroundColor: cores.surfaceContainerLow,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide.none,
                      labelStyle: TextStyle(
                        color: ativo ? _corPrincipalAzul : cores.onSurfaceVariant,
                        fontWeight: ativo ? FontWeight.bold : FontWeight.w500,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _filtroMeusCupoes = subFiltro);
                          _atualizarDados();
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _carregando
                  ? const Center(child: CircularProgressIndicator(color: _corPrincipalAzul))
                  : _abaAtual == 'Comprar'
                  ? _buildListaPremios(cores)
                  : _buildListaMeusCupoes(cores),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói a lista visual de cartões para os produtos e ofertas disponíveis para compra.
  Widget _buildListaPremios(ColorScheme cores) {
    if (_premiosDisponiveis.isEmpty) {
      return _buildCardVazio(
        Icons.storefront_rounded,
        'Nenhuma recompensa disponível',
        'De momento não existem cupões listados para troca.',
        cores,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      itemCount: _premiosDisponiveis.length,
      itemBuilder: (context, index) {
        final premio = _premiosDisponiveis[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cores.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _corPrincipalAzul.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_offer_rounded, color: _corPrincipalAzul, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      premio.titulo,
                      style: TextStyle(fontWeight: FontWeight.bold, color: cores.onSurface, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 14, color: cores.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            premio.local,
                            style: TextStyle(color: cores.onSurfaceVariant, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${premio.custoPontos} pts',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: _corPontosLaranja, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _corPrincipalAzul,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      // Lógica de troca futura associada ao teu controller
                    },
                    child: const Text('Trocar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Constrói a lista de cartões utilitários correspondentes à carteira comprada pelo utilizador.
  Widget _buildListaMeusCupoes(ColorScheme cores) {
    if (_meusCupoes.isEmpty) {
      return _buildCardVazio(
        Icons.local_activity_outlined,
        'Sem cupões nesta categoria',
        'Não encontrámos nenhum cupão no estado de $_filtroMeusCupoes.',
        cores,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      itemCount: _meusCupoes.length,
      itemBuilder: (context, index) {
        final cupao = _meusCupoes[index];
        final eAtivo = _filtroMeusCupoes == 'Ativos';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cores.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
            border: eAtivo ? Border.all(color: _corPrincipalAzul.withValues(alpha: 0.15), width: 1.5) : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (eAtivo ? _corPrincipalAzul : cores.onSurfaceVariant).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  eAtivo ? Icons.qr_code_rounded : Icons.check_circle_outline_rounded,
                  color: eAtivo ? _corPrincipalAzul : cores.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cupao.titulo,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: eAtivo ? cores.onSurface : cores.onSurfaceVariant,
                        fontSize: 16,
                        decoration: eAtivo ? null : TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      eAtivo ? cupao.local : 'Utilizado no local',
                      style: TextStyle(color: cores.onSurfaceVariant, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (eAtivo) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: _corPrincipalAzul),
                  onPressed: () => _mostrarQRCodeCupao(context, cupao.id),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Componente centralizado em formato de caixa para ilustrar cenários de ausência de dados.
  Widget _buildCardVazio(IconData icone, String titulo, String subtitulo, ColorScheme cores) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: cores.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _corPrincipalAzul.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icone, size: 40, color: _corPrincipalAzul),
              ),
              const SizedBox(height: 20),
              Text(
                titulo,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cores.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                subtitulo,
                textAlign: TextAlign.center,
                style: TextStyle(color: cores.onSurfaceVariant, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}