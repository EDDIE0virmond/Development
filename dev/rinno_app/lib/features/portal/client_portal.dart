import 'package:flutter/material.dart';
import '../../core/network/app_api.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/widgets/glass_surface.dart';
import 'client_home_page.dart';

class ClientPortal extends StatefulWidget {
  final AppApi api;
  const ClientPortal({super.key, required this.api});
  @override
  State<ClientPortal> createState() => _ClientPortalState();
}

class _ClientPortalState extends State<ClientPortal> {
  bool restoring = true;
  String? restoreError;
  late final String? tokenHash = Uri.base.queryParameters['token_hash'];
  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    try {
      if (widget.api.user == null && tokenHash == null) {
        await widget.api.restore();
      }
    } catch (e) {
      restoreError = e.toString();
    }
    if (mounted) setState(() => restoring = false);
  }

  @override
  Widget build(BuildContext context) => PortalBackground(
    child: Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: restoring
            ? const Center(child: CircularProgressIndicator())
            : AnimatedBuilder(
                animation: widget.api,
                builder: (context, _) => widget.api.user == null
                    ? _Login(
                        api: widget.api,
                        tokenHash: tokenHash,
                        initialError: restoreError,
                      )
                    : ClientHomePage(
                        key: ValueKey(widget.api.user!.id),
                        api: widget.api,
                      ),
              ),
      ),
    ),
  );
}

class _Login extends StatefulWidget {
  final AppApi api;
  final String? tokenHash, initialError;
  const _Login({required this.api, this.tokenHash, this.initialError});
  @override
  State<_Login> createState() => _LoginState();
}

class _LoginState extends State<_Login> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController(), password = TextEditingController();
  bool busy = false, hidden = true;
  late String mode = widget.tokenHash != null ? 'reset' : 'login';
  late String? message = widget.initialError;
  bool success = false;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    setState(() {
      busy = true;
      message = null;
      success = false;
    });
    try {
      if (mode == 'recover') {
        await widget.api.recover(email.text);
        message =
            'Se houver uma conta para esse e-mail, você receberá as instruções de recuperação.';
        success = true;
      } else if (mode == 'reset') {
        await widget.api.reset(widget.tokenHash!, password.text);
        mode = 'login';
        password.clear();
        message = 'Senha atualizada. Entre com a nova senha.';
        success = true;
      } else {
        await widget.api.login(email.text, password.text);
      }
    } catch (e) {
      message = e.toString();
    }
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth > 1000;
      final login = GlassSurface(
        padding: EdgeInsets.all(wide ? 36 : 24),
        child: Form(
          key: form,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'PORTAL DO CLIENTE',
                  style: TextStyle(
                    color: AppTheme.lime,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.4,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  mode == 'login'
                      ? 'Bem-vindo à sua energia.'
                      : mode == 'recover'
                      ? 'Vamos recuperar seu acesso.'
                      : 'Uma nova senha.',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  mode == 'login'
                      ? 'Sua instalação, cada etapa e todos os documentos. Em um só lugar.'
                      : mode == 'recover'
                      ? 'Informe o e-mail cadastrado com a Rinnovare.'
                      : 'Use pelo menos 12 caracteres para proteger sua conta.',
                  style: const TextStyle(color: AppTheme.muted, height: 1.6),
                ),
                const SizedBox(height: 32),
                if (message != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        message!,
                        style: TextStyle(
                          color: success
                              ? AppTheme.lime
                              : const Color(0xFFFFB4AB),
                        ),
                      ),
                    ),
                  ),
                if (mode != 'reset') ...[
                  TextFormField(
                    controller: email,
                    enabled: !busy,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.alternate_email, size: 20),
                    ),
                    validator: (v) =>
                        v != null &&
                            RegExp(
                              r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                            ).hasMatch(v.trim())
                        ? null
                        : 'Informe um e-mail válido.',
                  ),
                  const SizedBox(height: 18),
                ],
                if (mode != 'recover') ...[
                  TextFormField(
                    controller: password,
                    enabled: !busy,
                    obscureText: hidden,
                    autofillHints: [
                      mode == 'reset'
                          ? AutofillHints.newPassword
                          : AutofillHints.password,
                    ],
                    onFieldSubmitted: (_) => busy ? null : submit(),
                    decoration: InputDecoration(
                      labelText: mode == 'reset' ? 'Nova senha' : 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(
                        tooltip: hidden ? 'Mostrar senha' : 'Ocultar senha',
                        onPressed: () => setState(() => hidden = !hidden),
                        icon: Icon(
                          hidden
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                        ),
                      ),
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Informe sua senha.'
                        : mode == 'reset' && v.length < 12
                        ? 'Use pelo menos 12 caracteres.'
                        : null,
                  ),
                  const SizedBox(height: 10),
                ],
                if (mode == 'login')
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: busy
                          ? null
                          : () => setState(() {
                              mode = 'recover';
                              message = null;
                            }),
                      child: const Text('Esqueci minha senha'),
                    ),
                  ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: busy ? null : submit,
                  child: busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          mode == 'login'
                              ? 'Entrar no portal'
                              : mode == 'recover'
                              ? 'Enviar instruções'
                              : 'Salvar nova senha',
                        ),
                ),
                if (mode != 'login')
                  TextButton(
                    onPressed: busy
                        ? null
                        : () => setState(() {
                            mode = 'login';
                            message = null;
                          }),
                    child: const Text('Voltar para entrar'),
                  ),
                const SizedBox(height: 28),
                const Divider(),
                const SizedBox(height: 18),
                const Text(
                  'Seu acesso é liberado pela equipe Rinnovare após a vinculação da instalação.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.muted,
                    fontSize: 12,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return SingleChildScrollView(
        padding: EdgeInsets.all(wide ? 48 : 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1160),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandMark(),
                const SizedBox(height: 64),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 72),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.wb_sunny_outlined,
                                color: AppTheme.lime,
                                size: 52,
                              ),
                              const SizedBox(height: 32),
                              Text(
                                'Um futuro mais leve.\nUma energia mais sua.',
                                style: Theme.of(context).textTheme.headlineLarge
                                    ?.copyWith(fontSize: 56),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Acompanhe a transformação da sua energia,\ndo projeto à instalação.',
                                style: TextStyle(
                                  color: AppTheme.muted,
                                  fontSize: 18,
                                  height: 1.7,
                                ),
                              ),
                              const SizedBox(height: 48),
                              const Text(
                                'ENGENHARIA  /  CONFIANÇA  /  PROXIMIDADE',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.muted,
                                  letterSpacing: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 440, child: login),
                    ],
                  )
                else
                  login,
                const SizedBox(height: 48),
                const Text(
                  'Rinnovare Engenharia Solar · Sua energia, bem acompanhada.',
                  style: TextStyle(color: AppTheme.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
