// lib/features/dashboard/presentation/pages/add_plant_dialog.dart
import 'package:flutter/material.dart';
import '../../../../features/auth/presentation/widgets/green_button.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/models/simple_user.dart';

class AddPlantDialog extends StatefulWidget {
  final Function(
    int, 
    String, 
    String, 
    double, 
    String,
    int,
    String,
    String,
    String,
    int,
  ) onAdd;

  const AddPlantDialog({super.key, required this.onAdd});

  @override
  State<AddPlantDialog> createState() => _AddPlantDialogState();
}

class _AddPlantDialogState extends State<AddPlantDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _potenciaController = TextEditingController();
  final _localizacaoController = TextEditingController();
  
  final _quantidadePlacasController = TextEditingController();
  final _nomePlacaController = TextEditingController();
  final _nomeInversorController = TextEditingController();
  final _quantidadeInversoresController = TextEditingController();
  
  String _tipoInversor = 'micro';
  
  final UserService _userService = UserService();
  List<SimpleUser> _clientes = [];
  SimpleUser? _selectedCliente;
  bool _isLoadingUsers = true;
  bool _isLoading = false;

  final List<Map<String, String>> _tiposInversor = [
    {'value': 'micro', 'label': 'Micro'},
    {'value': 'inversor', 'label': 'Inv.'},
  ];

  @override
  void initState() {
    super.initState();
    _loadClientes();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _potenciaController.dispose();
    _localizacaoController.dispose();
    _quantidadePlacasController.dispose();
    _nomePlacaController.dispose();
    _nomeInversorController.dispose();
    _quantidadeInversoresController.dispose();
    super.dispose();
  }

  Future<void> _loadClientes() async {
    setState(() => _isLoadingUsers = true);
    try {
      final clientes = await _userService.getUsersByRole('cliente');
      setState(() {
        _clientes = clientes;
        _isLoadingUsers = false;
        if (_clientes.isNotEmpty) {
          _selectedCliente = _clientes.first;
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingUsers = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao carregar clientes'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleAdd() {
    if (_formKey.currentState!.validate() && _selectedCliente != null) {
      setState(() => _isLoading = true);
      widget.onAdd(
        _selectedCliente!.id,
        _nomeController.text.trim(),
        _descricaoController.text.trim(),
        double.parse(_potenciaController.text.trim()),
        _localizacaoController.text.trim(),
        int.parse(_quantidadePlacasController.text.trim()),
        _nomePlacaController.text.trim(),
        _tipoInversor,
        _nomeInversorController.text.trim(),
        int.parse(_quantidadeInversoresController.text.trim()),
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Adicionar Planta para Cliente',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Selecione o cliente e preencha os dados da planta',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Seletor de cliente
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: _isLoadingUsers
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : _clientes.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Nenhum cliente cadastrado',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : DropdownButtonFormField<SimpleUser>(
                              value: _selectedCliente,
                              decoration: const InputDecoration(
                                labelText: 'Selecionar Cliente',
                                border: InputBorder.none,
                                icon: Icon(Icons.person, color: Color(0xFF2E7D32)),
                              ),
                              items: _clientes.map((cliente) {
                                return DropdownMenuItem<SimpleUser>(
                                  value: cliente,
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minHeight: 40,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        cliente.nome,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCliente = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Selecione um cliente';
                                }
                                return null;
                              },
                            ),
                ),
                
                const SizedBox(height: 16),
                
                // Nome da planta
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da planta',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.agriculture),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nome é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Descrição
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Descrição é obrigatória';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Potência
                TextFormField(
                  controller: _potenciaController,
                  decoration: const InputDecoration(
                    labelText: 'Potência (kWp)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.flash_on),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Potência é obrigatória';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Digite um número válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Localização
                TextFormField(
                  controller: _localizacaoController,
                  decoration: const InputDecoration(
                    labelText: 'Localização',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Localização é obrigatória';
                    }
                    return null;
                  },
                ),
                
                const Divider(height: 32),
                
                // SEÇÃO DE PLACAS
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _quantidadePlacasController,
                        decoration: const InputDecoration(
                          labelText: 'Qtd. Placas',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.numbers),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Obrigatório';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Número válido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _nomePlacaController,
                        decoration: const InputDecoration(
                          labelText: 'Nome da Placa',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.solar_power),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Obrigatório';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // SEÇÃO DE INVERSOR
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dropdown de tipo
                    Container(
                      width: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: DropdownButtonFormField<String>(
                        value: _tipoInversor,
                        isDense: true,
                        decoration: const InputDecoration(
                          labelText: 'Tipo',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        ),
                        items: _tiposInversor.map((tipo) {
                          return DropdownMenuItem<String>(
                            value: tipo['value'],
                            child: Text(
                              tipo['label']!,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _tipoInversor = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Nome do inversor
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _nomeInversorController,
                        decoration: const InputDecoration(
                          labelText: 'Nome do Inversor',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.electric_bolt),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Obrigatório';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                TextFormField(
                  controller: _quantidadeInversoresController,
                  decoration: const InputDecoration(
                    labelText: 'Qtd. Inversores',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Obrigatório';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Número válido';
                    }
                    return null;
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
      ),
    );
  }
}