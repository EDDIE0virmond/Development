// lib/features/dashboard/presentation/pages/user_items_page.dart
import 'package:flutter/material.dart';
import '../../../../core/services/user_management_service.dart';
import '../../../../core/models/user_item.dart';
import '../../../../features/auth/presentation/widgets/gradient_background.dart';
import '../../../../core/theme/widgets/animated_list_item.dart';
import 'add_item_dialog.dart';

class UserItemsPage extends StatefulWidget {
  final int userId;
  final String userName;

  const UserItemsPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UserItemsPage> createState() => _UserItemsPageState();
}

class _UserItemsPageState extends State<UserItemsPage> {
  final UserManagementService _service = UserManagementService();
  List<UserItem> _items = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final items = await _service.getItemsByUser(widget.userId);
      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _refreshItems() async {
    if (mounted) {
      setState(() {
        _isRefreshing = true;
      });
    }
    await _loadItems();
  }

  Future<void> _addItem(String nome, String descricao, String tipo) async {
    final success = await _service.addItemToUser(widget.userId, nome, descricao, tipo);
    
    if (mounted) {
      if (success) {
        await _refreshItems();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item adicionado com sucesso!'),
            backgroundColor: Color(0xFF2E7D32),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao adicionar item'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeItem(int itemId, String itemName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover item'),
        content: Text('Tem certeza que deseja remover "${itemName}"?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isRefreshing = true;
      });
      
      final success = await _service.removeItem(itemId);
      
      if (mounted) {
        if (success) {
          await _loadItems();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"$itemName" removido com sucesso!'),
              backgroundColor: const Color(0xFF2E7D32),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          setState(() {
            _isRefreshing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao remover item'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _getTipoLabel(String tipo) {
    switch (tipo) {
      case 'microinversor':
        return 'Micro-Inversor';
      case 'inversor':
        return 'Inversor';
      case 'placas':
        return 'Placas';
      default:
        return tipo;
    }
  }

  IconData _getTipoIcon(String tipo) {
    switch (tipo) {
      case 'microinversor':
        return Icons.inventory;
      case 'inversor':
        return Icons.build;
      case 'placas':
        return Icons.description;
      default:
        return Icons.category;
    }
  }

  Color _getTipoColor(String tipo) {
    switch (tipo) {
      case 'microinversor':
        return Colors.blue;
      case 'inversor':
        return Colors.orange;
      case 'placas':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Itens de ${widget.userName}'),
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddItemDialog(onAdd: _addItem),
              );
            },
            tooltip: 'Adicionar item',
          ),
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshItems,
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Carregando itens...'),
                    ],
                  ),
                )
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
                            onPressed: _refreshItems,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                            ),
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    )
                  : _items.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Nenhum item cadastrado',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Toque no + para adicionar um item',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _refreshItems,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return AnimatedListItem(
                                index: index,
                                child: Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: _getTipoColor(item.tipo).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        _getTipoIcon(item.tipo),
                                        color: _getTipoColor(item.tipo),
                                        size: 28,
                                      ),
                                    ),
                                    title: Text(
                                      item.nome,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          item.descricao,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getTipoColor(item.tipo).withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                _getTipoLabel(item.tipo).toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: _getTipoColor(item.tipo),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: item.status == 'ativo'
                                                    ? Colors.green.withValues(alpha: 0.1)
                                                    : Colors.red.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                item.status.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: item.status == 'ativo' ? Colors.green : Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () => _removeItem(item.id, item.nome),
                                      tooltip: 'Remover',
                                    ),
                                    isThreeLine: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
        ),
      ),
    );
  }
}