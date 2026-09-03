// lib/features/dashboard/presentation/pages/add_item_dialog.dart
import 'package:flutter/material.dart';
import '../../../../features/auth/presentation/widgets/green_button.dart';

class AddItemDialog extends StatefulWidget {
  final Function(String, String, String) onAdd;

  const AddItemDialog({super.key, required this.onAdd});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  String _selectedTipo = 'microinversor'; // CORRIGIDO: mudado de 'produto' para 'microinversor'
  bool _isLoading = false;

  final List<Map<String, dynamic>> _tipos = [
    {'value': 'microinversor', 'label': 'Micro-Inversor', 'icon': Icons.inventory},
    {'value': 'inversor', 'label': 'Inversor', 'icon': Icons.build},
    {'value': 'placas', 'label': 'Placas', 'icon': Icons.description},
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _handleAdd() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      widget.onAdd(
        _nomeController.text.trim(),
        _descricaoController.text.trim(),
        _selectedTipo,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Adicionar Item',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do item',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Descrição é obrigatória';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedTipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _tipos.map<DropdownMenuItem<String>>((tipo) {
                  return DropdownMenuItem<String>(
                    value: tipo['value'] as String,
                    child: Row(
                      children: [
                        Icon(tipo['icon'] as IconData, size: 20),
                        const SizedBox(width: 8),
                        Text(tipo['label'] as String),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedTipo = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GreenButton(
                      text: 'ADICIONAR',
                      onPressed: _handleAdd,
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}