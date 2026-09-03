// lib/features/auth/presentation/pages/log_in_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/auth_card.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/green_button.dart';
import '../../../../core/theme/widgets/logo_widget.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/network/routes.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
      _rememberMe,
    );

    if (!mounted) return;

    if (success) {
      await Future.delayed(const Duration(milliseconds: 100));

      final role = authProvider.userRole;
      print('Login bem-sucedido! Role: $role');

      if (role == 'admin') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.adminUser,
          (route) => false,
        );
      } else if (role == 'master') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.masterUser,
          (route) => false,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.comonUser,
          (route) => false,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bem-vindo, ${authProvider.currentUser?.nome}!'),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Falha no login'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const LogoWidget(size: 80),
                const SizedBox(height: 32),

                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return AuthCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Acessar Rinnovare',
                              style: GoogleFonts.poppins(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Digite seu e-mail e senha para entrar',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Mensagem de erro se houver
                            if (authProvider.errorMessage != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.red.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red.shade700,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        authProvider.errorMessage!,
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => authProvider.clearError(),
                                      child: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            CustomInputField(
                              controller: _emailController,
                              label: 'E-mail',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              hintText: 'seuemail@dominio.com.br',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'E-mail é obrigatório';
                                }
                                if (!value.contains('@')) {
                                  return 'Digite um e-mail válido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            CustomInputField(
                              controller: _passwordController,
                              label: 'Senha',
                              icon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              hintText: '••••••••',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Senha é obrigatória';
                                }
                                if (value.length < 4) {
                                  return 'Senha deve ter no mínimo 4 caracteres';
                                }
                                return null;
                              },
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 16),

                            // CORRIGIDO: Row com Expanded para evitar overflow
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Lembrar-me - com Expanded para controle de espaço
                                Expanded(
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 40,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          onChanged: (value) {
                                            setState(() {
                                              _rememberMe = value ?? false;
                                            });
                                          },
                                          activeColor: const Color(0xFF2E7D32),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                      const Expanded(
                                        child: Text(
                                          'Lembrar-me',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Esqueceu a senha - CORRIGIDO
                                Flexible(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/forgot-password',
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Esqueceu a senha?',
                                      style: TextStyle(
                                        color: Color(0xFF2E7D32),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            GreenButton(
                              text: 'ENTRAR',
                              onPressed: () => _handleLogin(authProvider),
                              isLoading: authProvider.isLoading,
                              icon: Icons.login,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}