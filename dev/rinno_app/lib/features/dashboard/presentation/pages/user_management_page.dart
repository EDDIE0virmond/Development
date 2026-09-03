// lib/features/dashboard/presentation/pages/user_management_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/user_management_service.dart';
import '../../../../core/models/user_with_items.dart';
import '../../../../features/auth/presentation/widgets/gradient_background.dart';
import 'user_items_page.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final UserManagementService _service = UserManagementService();
  List<UserWithItems> _clientes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadClientes();
  }

  Future<void> _loadClientes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final clientes = await _service.getClientes();
      setState(() {
        _clientes = clientes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Verifica permissão (apenas Master e Admin)
    if (!authProvider.canCreateUsers) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Gerenciar Usuários'),
          backgroundColor: const Color(0xFF1E293B),
        ),
        body: const Center(
          child: Text('Você não tem permissão para acessar esta página'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Usuários'),
        backgroundColor: authProvider.isAdmin ? const Color(0xFF7B1FA2) : const Color(0xFF44842A),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadClientes,
          ),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(_errorMessage!),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadClientes,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    )
                  : _clientes.isEmpty
                      ? const Center(
                          child: Text('Nenhum cliente cadastrado'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _clientes.length,
                          itemBuilder: (context, index) {
                            final cliente = _clientes[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: cliente.role == 'admin'
                                      ? Colors.purple
                                      : cliente.role == 'master'
                                          ? Colors.grey
                                          : Colors.green,
                                  child: Text(
                                    cliente.nome[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  cliente.nome,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(cliente.email),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: cliente.role == 'admin'
                                            ? Colors.purple.withValues(alpha: 0.1)
                                            : cliente.role == 'master'
                                                ? Colors.grey.withValues(alpha: 0.1)
                                                : Colors.green.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        cliente.role.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: cliente.role == 'admin'
                                              ? Colors.purple
                                              : cliente.role == 'master'
                                                  ? Colors.grey
                                                  : Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserItemsPage(
                                        userId: cliente.id,
                                        userName: cliente.nome,
                                      ),
                                    ),
                                  ).then((_) => _loadClientes());
                                },
                              ),
                            );
                          },
                        ),
        ),
      ),
    );
  }
}