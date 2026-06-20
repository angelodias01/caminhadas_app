import 'package:flutter/material.dart';
import '../controllers/trilhos_controller.dart';
import '../models/trilho_model.dart';

/// Ecrã responsável por listar as rotas, percursos pedestres e desafios de caminhada.
///
/// Permite segmentar os trilhos em três estados distintos ('A decorrer', 'Concluídos'
/// ou 'Expirados') e adapta automaticamente o seu layout entre listas ou grelhas (grid)
/// dependendo do espaço horizontal disponível no dispositivo.
class RotasScreen extends StatefulWidget {
  /// Cria uma instância estável de [RotasScreen].
  const RotasScreen({super.key});

  @override
  State<RotasScreen> createState() => _RotasScreenState();
}

/// Estado associado ao ecrã [RotasScreen] que gere os filtros e os dados de trilhos.
///
/// Consome assíncronamente os percursos geridos pelo [TrilhosController] e reconstrói
/// a interface mediante a alteração dos estados dos chips de seleção.
class _RotasScreenState extends State<RotasScreen> {
  /// O filtro de estado ativamente selecionado na interface.
  String _filtroAtual = 'A decorrer';

  /// Instância do controlador de negócio responsável pela busca de trilhos.
  final TrilhosController _controller = TrilhosController();

  /// Cache local da lista de objetos [TrilhoModel] obtida após a filtragem.
  List<TrilhoModel> _rotas = [];

  /// Sinalizador visual que indica se decorre uma operação de leitura de dados.
  bool _carregando = false;

  static const _corPrincipalAzul = Colors.indigo;

  @override
  void initState() {
    super.initState();
    _carregarTrilhos();
  }

  /// Realiza o pedido assíncrono para atualizar o inventário de trilhos com base no filtro ativo.
  Future<void> _carregarTrilhos() async {
    setState(() => _carregando = true);
    final lista = await _controller.obterTrilhosPorFiltro(_filtroAtual);
    setState(() {
      _rotas = lista;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cores.surface,
      appBar: AppBar(
        title: const Text('Trilhos & Desafios', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
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
              children: ['A decorrer', 'Concluídos', 'Expirados'].map((tipo) {
                final ativo = _filtroAtual == tipo;
                return ChoiceChip(
                  label: Text(tipo),
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
                      setState(() => _filtroAtual = tipo);
                      _carregarTrilhos();
                    }
                  },
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _carregando
                  ? const Center(child: CircularProgressIndicator(color: _corPrincipalAzul))
                  : _rotas.isEmpty
                  ? Padding(
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
                          child: const Icon(Icons.explore_off_rounded, size: 40, color: _corPrincipalAzul),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Sem trilhos disponíveis',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cores.onSurface),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'De momento não foram encontrados trilhos ou desafios no estado de $_filtroAtual.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: cores.onSurfaceVariant, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  : LayoutBuilder(
                builder: (context, constraints) {
                  final usarGrid = constraints.maxWidth > 600;
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: usarGrid ? 2 : 1,
                      mainAxisExtent: 130,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _rotas.length,
                    itemBuilder: (context, index) {
                      final trilho = _rotas[index];

                      final nomeTrilho = trilho.nome;
                      final distanciaTrilho = trilho.distanciaKm;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cores.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _corPrincipalAzul.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.map_rounded, color: _corPrincipalAzul, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    nomeTrilho,
                                    style: TextStyle(fontWeight: FontWeight.bold, color: cores.onSurface, fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.directions_walk_rounded, size: 16, color: cores.onSurfaceVariant),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$distanciaTrilho km',
                                        style: TextStyle(color: cores.onSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: cores.onSurfaceVariant),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}