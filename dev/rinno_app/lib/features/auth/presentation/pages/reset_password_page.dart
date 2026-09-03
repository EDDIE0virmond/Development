// lib/features/auth/presentation/pages/reset_password_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gradient_background.dart';
import '../widgets/auth_card.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/green_button.dart';
import '../../../../core/theme/widgets/logo_widget.dart';
import '../../../../core/services/password_service.dart';

class ResetPasswordPage extends StatefulWidget {
  final String token;

  const ResetPasswordPage({super.key, required this.token});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final PasswordService _passwordService = PasswordService();
  bool _isLoading = false;
  bool _isTokenValid = true;
  bool _resetSuccess = false;
  bool _checkingToken = true;

  @override
  void initState() {
    super.initState();
    _verifyToken();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _verifyToken() async {
    final response = await _passwordService.verifyResetToken(widget.token);
    
    setState(() {
      _checkingToken = false;
      _isTokenValid = response['valid'] ?? false;
    });

    if (!_isTokenValid && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Token inválido ou expirado'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final response = await _passwordService.resetPassword(
      widget.token,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (response['success'] == true) {
      setState(() {
        _resetSuccess = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Erro ao resetar senha'),
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
                
                AuthCard(
                  child: _checkingToken
                      ? _buildLoading()
                      : !_isTokenValid
                          ? _buildInvalidToken()
                          : _resetSuccess
                              ? _buildSuccessMessage()
                              : _buildForm(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Verificando token...'),
        ],
      ),
    );
  }

  Widget _buildInvalidToken() {
    return Column(
      children: [
        const Icon(
          Icons.error_outline,
          size: 80,
          color: Colors.red,
        ),
        const SizedBox(height: 24),
        Text(
          'Link Inválido',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
          textAlign: TextAlign.center,  // ✅ CORRETO - fora do style
        ),
        const SizedBox(height: 16),
        Text(
          'Este link de recuperação é inválido ou já expirou.\nSolicite um novo link.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,  // ✅ CORRETO - fora do style
        ),
        const SizedBox(height: 32),
        GreenButton(
          text: 'SOLICITAR NOVO LINK',
          onPressed: () => Navigator.pop(context),
          icon: Icons.refresh,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Nova Senha',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Digite sua nova senha',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          CustomInputField(
            controller: _passwordController,
            label: 'Nova senha',
            icon: Icons.lock_outline,
            obscureText: true,
            hintText: 'Mínimo 6 caracteres',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Senha é obrigatória';
              }
              if (value.length < 6) {
                return 'Senha deve ter no mínimo 6 caracteres';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          CustomInputField(
            controller: _confirmPasswordController,
            label: 'Confirmar senha',
            icon: Icons.lock_outline,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirme sua senha';
              }
              if (value != _passwordController.text) {
                return 'As senhas não coincidem';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 32),
          
          GreenButton(
            text: 'ALTERAR SENHA',
            onPressed: _handleResetPassword,
            isLoading: _isLoading,
            icon: Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 80,
          color: Color(0xFF2E7D32),
        ),
        const SizedBox(height: 24),
        Text(
          'Senha Alterada!',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
          textAlign: TextAlign.center,  // ✅ CORRETO - fora do style
        ),
        const SizedBox(height: 16),
        Text(
          'Sua senha foi alterada com sucesso.\nAgora você pode fazer login com sua nova senha.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,  // ✅ CORRETO - fora do style
        ),
        const SizedBox(height: 32),
        GreenButton(
          text: 'FAZER LOGIN',
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
          icon: Icons.login,
        ),
      ],
    );
  }
}