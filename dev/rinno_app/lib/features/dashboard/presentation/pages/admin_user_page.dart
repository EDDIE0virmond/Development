// lib/features/dashboard/presentation/pages/admin_user_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/widgets/logo_widget.dart';
import '../../../../core/theme/widgets/solar_icon.dart';
import '../../../../core/network/routes.dart';
import 'admin_plant_list_page.dart';

class AdminUserPage extends StatelessWidget {
  const AdminUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrador'),
        backgroundColor: const Color(0xFF7B1FA2),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.leadingLogIn);
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF3E5F5), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7B1FA2), Color(0xFF9C27B0)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const LogoWidget(size: 60),
                      const SizedBox(height: 16),
                      Text(
                        'Bem-vindo, ${authProvider.currentUser?.nome ?? "Admin"}!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'PERFIL ADMINISTRADOR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildMenuCard(
                        icon: Icons.admin_panel_settings,
                        title: 'Criar Usuário',
                        color: const Color(0xFF7B1FA2),
                        onTap: () => _navigateToRegister(context),
                      ),
                      _buildMenuCard(
                        icon: Icons.people,
                        title: 'Gerenciar Usuários',
                        color: const Color(0xFF9C27B0),
                        onTap: () => Navigator.pushNamed(context, AppRoutes.userManagement),
                      ),
                      _buildMenuCard(
                        icon: Icons.agriculture,
                        iconWidget: const SolarIcon(size: 32, color: Color(0xFFAB47BC)),
                        title: 'Gerenciar Plantas',
                        color: const Color(0xFFAB47BC),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminPlantListPage(),
                          ),
                        ),
                      ),
                      _buildMenuCard(
                        icon: Icons.description,
                        title: 'Todos Laudos',
                        color: const Color(0xFFBA68C8),
                        onTap: () => _showInfo(context, 'Gerenciar Laudos'),
                      ),
                      _buildMenuCard(
                        icon: Icons.analytics,
                        title: 'Dashboard',
                        color: const Color(0xFFCE93D8),
                        onTap: () => _showInfo(context, 'Dashboard Admin'),
                      ),
                      _buildMenuCard(
                        icon: Icons.settings,
                        title: 'Configurações',
                        color: const Color(0xFFE1BEE7),
                        onTap: () => _showInfo(context, 'Configurações Globais'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData? icon,
    Widget? iconWidget,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: iconWidget ?? Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToRegister(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.register);
  }

  void _showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}