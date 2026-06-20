import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import 'login_screen.dart';

/// Ecrã de gestão de perfil e definições da conta do utilizador.
///
/// Apresenta o sumário de dados pessoais, saldo de pontos, alteração de avatar,
/// formulários modais de atualização cadastral, opção de alternância do tema visual
/// (Modo Escuro) e encerramento seguro de sessão.
class PerfilScreen extends StatefulWidget {
  /// Cria uma instância estável de [PerfilScreen].
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

/// Estado associado ao ecrã [PerfilScreen] que monitoriza dados do perfil e imagem local.
class _PerfilScreenState extends State<PerfilScreen> {
  String _nomeUtilizador = "Nome do Utilizador";
  File? _imagemSelecionada;
  final ImagePicker _picker = ImagePicker();

  String _idade = "";
  String _contacto = "";
  String? _genero;

  static const _corPrincipalAzul = Colors.indigo;
  static const _corPontosLaranja = Colors.amber;

  /// Abre a galeria do sistema nativo para o utilizador escolher uma imagem de perfil.
  Future<void> _escolherImagem() async {
    final XFile? imagem = await _picker.pickImage(source: ImageSource.gallery);
    if (imagem != null) {
      setState(() {
        _imagemSelecionada = File(imagem.path);
      });
    }
  }

  /// Exibe uma caixa de diálogo ([AlertDialog]) interativa para alteração do nome de exibição.
  void _alterarNome() {
    final cores = Theme.of(context).colorScheme;
    final controller = TextEditingController(text: _nomeUtilizador);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Alterar Nome', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Introduza o novo nome',
            filled: true,
            fillColor: cores.surfaceContainerLow,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: cores.onSurfaceVariant)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _corPrincipalAzul,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _nomeUtilizador = controller.text.trim();
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  /// Despoleta a abertura de uma folha modal inferior para a edição de e-mail, palavra-passe ou dados.
  ///
  /// O argumento [tipo] define a variante do formulário a ser desenhada ('email', 'password' ou 'dados').
  void _abrirSobreposicaoEdicao(BuildContext context, String tipo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          top: 16,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _ConteudoFormularioModal(
                tipoOperacao: tipo,
                idadeInicial: _idade,
                contactoInicial: _contacto,
                generoInicial: _genero,
                onGuardarDados: (novaIdade, novoContacto, novoGenero) {
                  setState(() {
                    _idade = novaIdade;
                    _contacto = novoContacto;
                    _genero = novoGenero;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Alerta o utilizador por via de um diálogo de confirmação antes de destruir a sessão atual.
  void _confirmarLogout(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Terminar Sessão', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Tem a certeza que deseja sair da sua conta?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: TextStyle(color: cores.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                );
              },
              child: Text('Sair', style: TextStyle(color: cores.error, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final stateApp = CaminhadasApp.of(context);
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cores.surface,
      appBar: AppBar(
        title: const Text('O Meu Perfil', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        centerTitle: true,
        backgroundColor: cores.surface,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        children: [
          Center(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _corPrincipalAzul.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 54,
                    backgroundColor: cores.surfaceContainerHigh,
                    backgroundImage: _imagemSelecionada != null ? FileImage(_imagemSelecionada!) : null,
                    child: _imagemSelecionada == null
                        ? const Icon(Icons.person_rounded, size: 48, color: _corPrincipalAzul)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _escolherImagem,
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: _corPrincipalAzul,
                      child: Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 32),
              Text(_nomeUtilizador, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cores.onSurface, letterSpacing: -0.5)),
              IconButton(
                icon: const Icon(Icons.edit_rounded, size: 18, color: _corPrincipalAzul),
                onPressed: _alterarNome,
              ),
            ],
          ),
          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: cores.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: _corPontosLaranja, size: 28),
                    const SizedBox(width: 12),
                    Text('Saldo Atual', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cores.onSurfaceVariant)),
                  ],
                ),
                const Text('0 pts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _corPrincipalAzul)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Container(
            decoration: BoxDecoration(
              color: cores.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.mail_outline_rounded, color: _corPrincipalAzul),
                  title: const Text('Alterar E-mail', style: TextStyle(fontWeight: FontWeight.w500)),
                  trailing: Icon(Icons.chevron_right_rounded, color: cores.onSurfaceVariant),
                  onTap: () => _abrirSobreposicaoEdicao(context, 'email'),
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: cores.outlineVariant.withValues(alpha: 0.3)),
                ListTile(
                  leading: const Icon(Icons.lock_open_rounded, color: _corPrincipalAzul),
                  title: const Text('Alterar Password', style: TextStyle(fontWeight: FontWeight.w500)),
                  trailing: Icon(Icons.chevron_right_rounded, color: cores.onSurfaceVariant),
                  onTap: () => _abrirSobreposicaoEdicao(context, 'password'),
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: cores.outlineVariant.withValues(alpha: 0.3)),
                ListTile(
                  leading: const Icon(Icons.tune_rounded, color: _corPrincipalAzul),
                  title: const Text('Outros Dados da Conta', style: TextStyle(fontWeight: FontWeight.w500)),
                  trailing: Icon(Icons.chevron_right_rounded, color: cores.onSurfaceVariant),
                  onTap: () => _abrirSobreposicaoEdicao(context, 'dados'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: cores.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined, color: _corPrincipalAzul),
                  title: const Text('Modo Escuro', style: TextStyle(fontWeight: FontWeight.w500)),
                  value: stateApp?.isDarkMode ?? false,
                  activeColor: _corPrincipalAzul,
                  onChanged: (bool value) {
                    stateApp?.alternarTema();
                  },
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: cores.outlineVariant.withValues(alpha: 0.3)),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: _corPrincipalAzul),
                  title: const Text('Política de Privacidade', style: TextStyle(fontWeight: FontWeight.w500)),
                  trailing: Icon(Icons.chevron_right_rounded, color: cores.onSurfaceVariant),
                  onTap: () {},
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: cores.outlineVariant.withValues(alpha: 0.3)),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Colors.red),
                  title: const Text('Sair da Conta', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  onTap: () => _confirmarLogout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Componente de formulário privado injetado dinamicamente na folha modal do perfil.
class _ConteudoFormularioModal extends StatefulWidget {
  final String tipoOperacao;
  final String idadeInicial;
  final String contactoInicial;
  final String? generoInicial;
  final Function(String, String, String?) onGuardarDados;

  const _ConteudoFormularioModal({
    required this.tipoOperacao,
    required this.idadeInicial,
    required this.contactoInicial,
    required this.generoInicial,
    required this.onGuardarDados,
  });

  @override
  State<_ConteudoFormularioModal> createState() => _ConteudoFormularioModalState();
}

/// Estado complementar associado à validação e controllers de input de [_ConteudoFormularioModal].
class _ConteudoFormularioModalState extends State<_ConteudoFormularioModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _idadeController;
  late TextEditingController _contactoController;
  String? _genero;

  static const _corPrincipalAzul = Colors.indigo;

  @override
  void initState() {
    super.initState();
    _idadeController = TextEditingController(text: widget.idadeInicial);
    _contactoController = TextEditingController(text: widget.contactoInicial);
    _genero = widget.generoInicial;
  }

  @override
  void dispose() {
    _idadeController.dispose();
    _contactoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    String titulo = '';
    List<Widget> campos = [];

    if (widget.tipoOperacao == 'email') {
      titulo = 'Alterar E-mail';
      campos = [
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Novo E-mail',
            filled: true,
            fillColor: cores.surfaceContainerLow,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          validator: (v) => v == null || !v.contains('@') ? 'Insira um e-mail válido' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Palavra-passe de Confirmação',
            filled: true,
            fillColor: cores.surfaceContainerLow,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          validator: (v) => v == null || v.isEmpty ? 'Confirme a sua password' : null,
        ),
      ];
    } else if (widget.tipoOperacao == 'password') {
      titulo = 'Alterar Palavra-passe';
      campos = [
        TextFormField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Palavra-passe Antiga',
            filled: true,
            fillColor: cores.surfaceContainerLow,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Nova Palavra-passe',
            filled: true,
            fillColor: cores.surfaceContainerLow,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          validator: (v) => v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Repetir Nova Palavra-passe',
            filled: true,
            fillColor: cores.surfaceContainerLow,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          validator: (v) => v == null || v.isEmpty ? 'Confirme a nova password' : null,
        ),
      ];
    } else {
      titulo = 'Dados da Conta';
      campos = [
        TextFormField(
          controller: _idadeController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Idade',
            filled: true,
            fillColor: cores.surfaceContainerLow,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _contactoController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Contacto Telefónico',
            filled: true,
            fillColor: cores.surfaceContainerLow,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _genero,
          decoration: InputDecoration(
            labelText: 'Género',
            filled: true,
            fillColor: cores.surfaceContainerLow,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          items: ['Masculino', 'Feminino', 'Outro'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (v) => setState(() => _genero = v),
        ),
      ];
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: cores.onSurface, letterSpacing: -0.5)),
          const SizedBox(height: 24),
          ...campos,
          const SizedBox(height: 32),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _corPrincipalAzul,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (widget.tipoOperacao == 'dados') {
                  widget.onGuardarDados(
                    _idadeController.text,
                    _contactoController.text,
                    _genero,
                  );
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Confirmar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}