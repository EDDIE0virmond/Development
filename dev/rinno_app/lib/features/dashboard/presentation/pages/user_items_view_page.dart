// lib/features/dashboard/presentation/pages/user_items_view_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rinno_app/features/auth/presentation/widgets/gradient_background.dart';
import '../../../../core/services/user_management_service.dart';
import '../../../../core/models/user_item.dart';
import '../../../../core/models/user_item.dart'; // Certifique-se de importar corretamente

class UserItemsViewPage extends StatefulWidget {
  final int userId;
  final String userName;

  const UserItemsViewPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UserItemsViewPage> createState() => _UserItemsViewPageState();
}

class _UserItemsViewPageState extends State<UserItemsViewPage> {
  final UserManagementService _service = UserManagementService();
  List<UserItem> _items = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _service.getItemsByUser(widget.userId);
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
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
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadItems,
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
                        'Seus itens aparecerão aqui quando forem adicionados',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _getTipoColor(
                              item.tipo,
                            ).withValues(alpha: 0.1),
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
                                    color: _getTipoColor(
                                      item.tipo,
                                    ).withValues(alpha: 0.1),
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
                                      color: item.status == 'ativo'
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          _showItemDetails(context, item);
                        },
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  void _showItemDetails(BuildContext context, UserItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.nome),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${_getTipoLabel(item.tipo)}'),
            const SizedBox(height: 8),
            Text('Descrição: ${item.descricao}'),
            const SizedBox(height: 8),
            Text('Status: ${item.status}'),
            const SizedBox(height: 8),
            Text('Data: ${_formatDate(item.dataCriacao)}'),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
