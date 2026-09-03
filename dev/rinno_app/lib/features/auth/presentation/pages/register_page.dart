// lib/features/auth/presentation/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/auth_card.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/green_button.dart';
import '../../../../core/theme/widgets/logo_widget.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/models/create_user_request.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String _selectedRole = 'cliente';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  
  final UserService _userService = UserService();

  final List<Map<String, dynamic>> _roles = [
    {'value': 'cliente', 'label': 'Cliente', 'color': const Color(0xFF2E7D32)},
    {'value': 'master', 'label': 'Usuário Master', 'color': const Color(0xFF1E293B)},
    {'value': 'admin', 'label': 'Administrador', 'color': const Color(0xFF7B1FA2)},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    // Verifica permissão novamente
    if (!authProvider.canCreateUsers) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Você não tem permissão para criar usuários'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    
    // Verifica regra específica para Admin
    final isAdmin = authProvider.userRole == 'admin';
    if (isAdmin && _selectedRole != 'cliente') {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Administradores só podem criar usuários do tipo Cliente.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    
    // Cria a requisição
    final request = CreateUserRequest(
      nome: _nameController.text.trim(),
      email: _emailController.text.trim(),
      senha: _passwordController.text,
      role: _selectedRole,
      criadoPor: authProvider.userRole,
    );
    
    final response = await _userService.createUser(request);
    
    if (mounted) {
      setState(() => _isLoading = false);
      
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usuário ${_nameController.text} criado com sucesso!'),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.userRole == 'admin';
    
    // Verifica se o usuário tem permissão para criar novos usuários
    if (!authProvider.canCreateUsers) {
      return _buildAccessDenied(context);
    }
    
    return _buildRegisterForm(context, authProvider, isAdmin);
  }

  Widget _buildAccessDenied(BuildContext context) {
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Acesso Negado',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Apenas administradores e masters\npodem criar novos usuários.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 32),
                GreenButton(
                  text: 'VOLTAR',
                  onPressed: () => Navigator.pop(context),
                  isOutlined: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm(BuildContext context, AuthProvider authProvider, bool isAdmin) {
    // Se for admin, força a seleção para 'cliente'
    if (isAdmin && _selectedRole != 'cliente') {
      _selectedRole = 'cliente';
    }
    
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
          title: Text(
            'Novo Usuário',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const LogoWidget(size: 70),
                const SizedBox(height: 24),
                
                AuthCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          isAdmin ? 'Criar novo cliente' : 'Criar novo usuário',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isAdmin 
                              ? 'Preencha os dados abaixo para criar um novo cliente'
                              : 'Preencha os dados abaixo para criar uma nova conta',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Nome completo
                        CustomInputField(
                          controller: _nameController,
                          label: 'Nome completo',
                          icon: Icons.person_outline,
                          hintText: 'Digite o nome completo',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nome é obrigatório';
                            }
                            if (value.length < 3) {
                              return 'Nome deve ter no mínimo 3 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // E-mail
                        CustomInputField(
                          controller: _emailController,
                          label: 'E-mail',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          hintText: 'email@rinnovare.com.br',
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
                        const SizedBox(height: 20),
                        
                        // Perfil de acesso - Desabilitado para Admin
                        if (!isAdmin)
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedRole,
                              decoration: const InputDecoration(
                                labelText: 'Perfil de acesso',
                                border: InputBorder.none,
                                icon: Icon(Icons.admin_panel_settings, color: Color(0xFF2E7D32)),
                              ),
                              items: _roles.map<DropdownMenuItem<String>>((role) {
                                return DropdownMenuItem<String>(
                                  value: role['value'] as String,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: role['color'] as Color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(role['label'] as String),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedRole = value!;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Selecione um perfil';
                                }
                                return null;
                              },
                            ),
                          ),
                        
                        // Para Admin, mostra apenas informação
                        if (isAdmin)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, color: Color(0xFF2E7D32)),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Como administrador, você só pode criar usuários do tipo Cliente.',
                                    style: TextStyle(fontSize: 13, color: Color(0xFF2E7D32)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        const SizedBox(height: 20),
                        
                        // Senha
                        CustomInputField(
                          controller: _passwordController,
                          label: 'Criar senha',
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
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
                        const SizedBox(height: 20),
                        
                        // Confirmar senha
                        CustomInputField(
                          controller: _confirmPasswordController,
                          label: 'Confirmar senha',
                          icon: Icons.lock_outline,
                          obscureText: _obscureConfirmPassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirme sua senha';
                            }
                            if (value != _passwordController.text) {
                              return 'As senhas não coincidem';
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Informação sobre o perfil selecionado (apenas para não-admin)
                        if (!isAdmin)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFA5D6A7)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, color: Color(0xFF2E7D32), size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Perfil selecionado:',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF2E7D32),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _roles.firstWhere((r) => r['value'] == _selectedRole)['label'] as String,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF2E7D32),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        const SizedBox(height: 24),
                        
                        GreenButton(
                          text: isAdmin ? 'CRIAR CLIENTE' : 'CRIAR USUÁRIO',
                          onPressed: () => _handleRegister(authProvider),
                          isLoading: _isLoading,
                          icon: Icons.person_add,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Deseja voltar? ',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}