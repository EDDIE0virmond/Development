// lib/features/dashboard/presentation/pages/admin_plant_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/plant_service.dart';
import '../../../../core/services/plant_status_service.dart';
import '../../../../core/models/plant.dart';
import '../../../../core/models/plant_status.dart';
import '../../../../core/theme/widgets/solar_icon.dart';
import '../../../../features/auth/presentation/widgets/gradient_background.dart';
import 'add_plant_dialog.dart';
import 'update_status_dialog.dart';

class AdminPlantListPage extends StatefulWidget {
  const AdminPlantListPage({super.key});

  @override
  State<AdminPlantListPage> createState() => _AdminPlantListPageState();
}

class _AdminPlantListPageState extends State<AdminPlantListPage> {
  final PlantService _plantService = PlantService();
  final PlantStatusService _statusService = PlantStatusService();
  List<Plant> _plants = [];
  bool _isLoading = true;
  String? _errorMessage;

  final Map<String, String> _categoriaLabels = {
    'projeto': 'Projeto',
    'instalacao': 'Instalação',
    'completividade': 'Completividade',
  };

  final Map<String, IconData> _categoriaIcons = {
    'projeto': Icons.description,
    'instalacao': Icons.build,
    'completividade': Icons.checklist,
  };

  final Map<String, Color> _categoriaColors = {
    'projeto': Colors.blue,
    'instalacao': Colors.orange,
    'completividade': Colors.green,
  };

  @override
  void initState() {
    super.initState();
    _loadAllPlants();
  }

  Future<void> _loadAllPlants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final plants = await _plantService.getAllPlants();
      setState(() {
        _plants = plants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addPlant(
    int userId, 
    String nome, 
    String descricao, 
    double potencia, 
    String localizacao,
    int quantidadePlacas,
    String nomePlaca,
    String tipoInversor,
    String nomeInversor,
    int quantidadeInversores,
  ) async {
    final success = await _plantService.createPlant(
      userId, 
      nome, 
      descricao, 
      potencia, 
      localizacao,
      quantidadePlacas,
      nomePlaca,
      tipoInversor,
      nomeInversor,
      quantidadeInversores,
    );
    
    if (mounted) {
      if (success) {
        await _loadAllPlants();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🌱 Planta criada com sucesso!'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao criar planta'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateStatus(PlantStatus status, bool isCompleted, String? observacao) async {
    final success = await _statusService.updatePlantStatus(status.id, isCompleted, observacao: observacao);
    
    if (mounted) {
      if (success) {
        await _loadAllPlants();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCompleted 
                ? '✅ ${status.nome} concluído!' 
                : '↩️ ${status.nome} reaberto',
            ),
            backgroundColor: isCompleted ? Colors.green : Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao atualizar status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showPlantDetailDialog(Plant plant) async {
    List<PlantStatus> statusList = [];
    bool isLoading = true;
    String? errorMessage;

    try {
      statusList = await _statusService.getPlantStatus(plant.id);
      isLoading = false;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 400,
            maxHeight: 600,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com SolarIcon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const SolarIcon(size: 28, color: Color(0xFF2E7D32)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plant.nome,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ID: ${plant.userId} - ${plant.localizacao}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: plant.statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      plant.statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: plant.statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Potência
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flash_on, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      '${plant.potencia.toStringAsFixed(1)} kWp',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Informações das placas
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.solar_power, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${plant.quantidadePlacas}x ${plant.nomePlaca}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Placas solares',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Informações do inversor
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.electric_bolt, size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${plant.quantidadeInversores}x ${plant.nomeInversor}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            plant.tipoInversor == 'micro' ? 'Micro Inversor' : 'Inversor',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              
              // Conteúdo dos status
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, size: 40, color: Colors.red),
                                const SizedBox(height: 8),
                                Text(
                                  errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildCategoriaSection(statusList, 'projeto', plant.id),
                                const SizedBox(height: 12),
                                _buildCategoriaSection(statusList, 'instalacao', plant.id),
                                const SizedBox(height: 12),
                                _buildCategoriaSection(statusList, 'completividade', plant.id),
                              ],
                            ),
                          ),
              ),
              const SizedBox(height: 8),
              // Botão fechar
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'FECHAR',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriaSection(List<PlantStatus> statusList, String categoria, int plantId) {
    final items = statusList.where((s) => s.categoria == categoria).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    final color = _categoriaColors[categoria] ?? Colors.grey;
    final icon = _categoriaIcons[categoria] ?? Icons.category;
    final label = _categoriaLabels[categoria] ?? categoria;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const Spacer(),
            Text(
              '${(_getProgressByCategoria(statusList, categoria) * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 50,
              child: LinearProgressIndicator(
                value: _getProgressByCategoria(statusList, categoria),
                backgroundColor: Colors.grey[200],
                color: color,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...items.map((status) => _buildStatusItem(status, plantId)),
      ],
    );
  }

  double _getProgressByCategoria(List<PlantStatus> statusList, String categoria) {
    final items = statusList.where((s) => s.categoria == categoria).toList();
    if (items.isEmpty) return 0.0;
    final completed = items.where((s) => s.isCompleted).length;
    return completed / items.length;
  }

  Widget _buildStatusItem(PlantStatus status, int plantId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => UpdateStatusDialog(
              status: status,
              onUpdate: (isCompleted, observacao) {
                _updateStatus(status, isCompleted, observacao);
              },
            ),
          );
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: status.isCompleted 
                ? Colors.green.withValues(alpha: 0.05) 
                : Colors.orange.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: status.isCompleted ? Colors.green : Colors.orange,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                status.statusIcon,
                color: status.statusColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  status.nome,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    decoration: status.isCompleted 
                        ? TextDecoration.lineThrough 
                        : null,
                    color: status.isCompleted 
                        ? Colors.green 
                        : Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: status.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.statusLabel,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: status.statusColor,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.edit,
                size: 14,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Plantas'),
        backgroundColor: isAdmin ? const Color(0xFF7B1FA2) : const Color(0xFF44842A),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddPlantDialog(onAdd: _addPlant),
              );
            },
            tooltip: 'Adicionar planta',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllPlants,
            tooltip: 'Recarregar',
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
                            onPressed: _loadAllPlants,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                            ),
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    )
                  : _plants.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SolarIcon(size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Nenhuma planta cadastrada',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Toque no + para adicionar uma planta',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadAllPlants,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _plants.length,
                            itemBuilder: (context, index) {
                              final plant = _plants[index];
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  onTap: () => _showPlantDetailDialog(plant),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const SolarIcon(size: 28, color: Color(0xFF2E7D32)),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      plant.nome,
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFF0F172A),
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: plant.statusColor.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Text(
                                                      plant.statusLabel,
                                                      style: TextStyle(
                                                        fontSize: 9,
                                                        fontWeight: FontWeight.w600,
                                                        color: plant.statusColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Usuário ID: ${plant.userId} - ${plant.localizacao}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              // Linha com Potência + Placas
                                              Wrap(
                                                spacing: 12,
                                                runSpacing: 2,
                                                children: [
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(Icons.flash_on, size: 12, color: Colors.orange),
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        '${plant.potencia.toStringAsFixed(1)} kWp',
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w500,
                                                          color: Colors.orange,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(Icons.solar_power, size: 12, color: Colors.blue),
                                                      const SizedBox(width: 2),
                                                      Flexible(
                                                        child: Text(
                                                          '${plant.quantidadePlacas}x ${plant.nomePlaca}',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors.blue[700],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              // Linha com Inversores
                                              Row(
                                                children: [
                                                  const Icon(Icons.electric_bolt, size: 12, color: Colors.orange),
                                                  const SizedBox(width: 2),
                                                  Flexible(
                                                    child: Text(
                                                      '${plant.quantidadeInversores}x ${plant.nomeInversor} (${plant.tipoInversor == 'micro' ? 'Micro' : 'Inv.'})',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.orange[700],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.chevron_right,
                                          color: Colors.grey,
                                          size: 20,
                                        ),
                                      ],
                                    ),
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}