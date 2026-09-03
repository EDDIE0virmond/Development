// lib/features/auth/presentation/pages/forgot_password_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gradient_background.dart';
import '../widgets/auth_card.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/green_button.dart';
import '../../../../core/theme/widgets/logo_widget.dart';
import '../../../../core/services/password_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final PasswordService _passwordService = PasswordService();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Primeiro verifica se o e-mail existe
    final checkEmail = await _passwordService.checkEmail(_emailController.text.trim());
    
    if (!checkEmail.exists) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-mail não encontrado no sistema'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Solicita recuperação
    final response = await _passwordService.forgotPassword(_emailController.text.trim());

    setState(() {
      _isLoading = false;
    });

    if (response['success'] == true) {
      setState(() {
        _emailSent = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Erro ao solicitar recuperação'),
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
                  child: _emailSent
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

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Recuperar Senha',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Digite seu e-mail cadastrado para receber um link de recuperação',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          CustomInputField(
            controller: _emailController,
            label: 'E-mail',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            hintText: 'seuemail@rinnovare.com.br',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'E-mail é obrigatório';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Digite um e-mail válido';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 32),
          
          GreenButton(
            text: 'ENVIAR LINK',
            onPressed: _handleForgotPassword,
            isLoading: _isLoading,
            icon: Icons.send,
          ),
          
          const SizedBox(height: 16),
          
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Voltar para o login',
              style: TextStyle(
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 80,
          color: Color(0xFF2E7D32),
        ),
        const SizedBox(height: 24),
        Text(
          'E-mail enviado!',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
          textAlign: TextAlign.center,  // ✅ CORRETO - fora do style
        ),
        const SizedBox(height: 16),
        Text(
          'Enviamos um link de recuperação para:\n${_emailController.text}',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,  // ✅ CORRETO - fora do style
        ),
        const SizedBox(height: 16),
        Text(
          'Verifique sua caixa de entrada e spam.',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,  // ✅ CORRETO - fora do style
        ),
        const SizedBox(height: 32),
        GreenButton(
          text: 'VOLTAR PARA O LOGIN',
          onPressed: () => Navigator.pop(context),
          icon: Icons.arrow_back,
        ),
      ],
    );
  }
}