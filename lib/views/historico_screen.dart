import 'package:flutter/material.dart';
import '../controllers/atividade_controller.dart';
import '../models/atividade_model.dart';

/// Ecrã responsável por apresentar o histórico de atividades físicas do utilizador.
///
/// Permite filtrar os registos por diferentes períodos de tempo (Semana, Mês ou Ano)
/// e exibe a listagem de passos, quilómetros e pontos obtidos em cada atividade.
class HistoricoScreen extends StatefulWidget {
  /// Cria uma instância estável de [HistoricoScreen].
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

/// Estado associado ao ecrã [HistoricoScreen] que gere a filtragem e carregamento de dados.
///
/// Implementa [SingleTickerProviderStateMixin] para suportar transições e animações
/// de alternância de estados visuais.
class _HistoricoScreenState extends State<HistoricoScreen> with SingleTickerProviderStateMixin {
  /// O filtro temporal atualmente selecionado na interface.
  String _filtroAtual = 'Semana';

  /// Instância do controlador de negócio para consulta e cálculo de métricas.
  final AtividadeController _controller = AtividadeController();

  /// Lista que armazena os registos de atividade recuperados após a aplicação do filtro.
  List<AtividadeModel> _dadosFiltrados = [];

  /// Sinalizador que indica se existe uma operação assíncrona de carregamento a decorrer.
  bool _carregando = false;

  static const _corPrincipalAzul = Colors.indigo;
  static const _corPontosLaranja = Colors.amber;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  /// Realiza a chamada assíncrona para atualizar a listagem de atividades com base no filtro ativo.
  Future<void> _carregarDados() async {
    setState(() => _carregando = true);
    final dados = await _controller.obterHistorico(_filtroAtual);
    setState(() {
      _dadosFiltrados = dados;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cores.surface,
      appBar: AppBar(
        title: const Text('O Meu Histórico', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
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
              children: ['Semana', 'Mês', 'Ano'].map((tipo) {
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
                      _carregarDados();
                    }
                  },
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _carregando
                  ? const Center(child: CircularProgressIndicator(color: _corPrincipalAzul))
                  : _dadosFiltrados.isEmpty
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
                          child: const Icon(Icons.history_toggle_off_rounded, size: 40, color: _corPrincipalAzul),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Sem atividade registada',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cores.onSurface),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Não encontrámos caminhadas guardadas no período da $_filtroAtual.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: cores.onSurfaceVariant, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                itemCount: _dadosFiltrados.length,
                itemBuilder: (context, index) {
                  final atividade = _dadosFiltrados[index];

                  final passos = atividade.passos;
                  final dataDateTime = atividade.data;
                  final dataStr = "${dataDateTime.day.toString().padLeft(2, '0')}/${dataDateTime.month.toString().padLeft(2, '0')}/${dataDateTime.year}";
                  final km = _controller.calcularQuilometros(passos);
                  final pontos = _controller.calcularPontos(passos);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cores.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _corPrincipalAzul.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.directions_walk_rounded, color: _corPrincipalAzul, size: 22),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dataStr,
                                style: TextStyle(fontWeight: FontWeight.bold, color: cores.onSurface, fontSize: 15),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$passos passos • $km km',
                                style: TextStyle(color: cores.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '+$pontos pts',
                          style: const TextStyle(fontWeight: FontWeight.w900, color: _corPontosLaranja, fontSize: 16),
                        ),
                      ],
                    ),
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