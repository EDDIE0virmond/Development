// lib/features/dashboard/presentation/pages/comon_user_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/widgets/logo_widget.dart';
import '../../../../core/theme/widgets/solar_icon.dart';
import '../../../../core/network/routes.dart';
import '../../../../core/services/plant_service.dart';
import '../../../../core/services/plant_status_service.dart';
import '../../../../core/models/plant.dart';
import '../../../../core/models/plant_status.dart';

class ComonUserPage extends StatefulWidget {
  const ComonUserPage({super.key});

  @override
  State<ComonUserPage> createState() => _ComonUserPageState();
}

class _ComonUserPageState extends State<ComonUserPage> {
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
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id ?? 0;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final plants = await _plantService.getPlantsByUser(userId);
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
              // Cabeçalho
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
                          plant.localizacao,
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
              
              // ===== INFORMAÇÕES DAS PLACAS =====
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
              
              // ===== INFORMAÇÕES DO INVERSOR =====
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
                                _buildCategoriaSection(statusList, 'projeto'),
                                const SizedBox(height: 12),
                                _buildCategoriaSection(statusList, 'instalacao'),
                                const SizedBox(height: 12),
                                _buildCategoriaSection(statusList, 'completividade'),
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

  Widget _buildCategoriaSection(List<PlantStatus> statusList, String categoria) {
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
        ...items.map((status) => _buildStatusItem(status)),
      ],
    );
  }

  double _getProgressByCategoria(List<PlantStatus> statusList, String categoria) {
    final items = statusList.where((s) => s.categoria == categoria).toList();
    if (items.isEmpty) return 0.0;
    final completed = items.where((s) => s.isCompleted).length;
    return completed / items.length;
  }

  Widget _buildStatusItem(PlantStatus status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Plantas'),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: _buildDrawer(context, authProvider),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E9), Color(0xFFF5F9F0)],
          ),
        ),
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
                            onPressed: _loadPlants,
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
                                'Suas plantas aparecerão aqui',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadPlants,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header com boas-vindas
                                Column(
                                  children: [
                                    const LogoWidget(size: 50),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Bem-vindo, ${authProvider.currentUser?.nome ?? "Usuário"}!',
                                      style: const TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Suas plantas solares',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                
                                // Lista de plantas em formato retângulo
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _plants.length,
                                  itemBuilder: (context, index) {
                                    final plant = _plants[index];
                                    return _buildPlantCard(context, plant);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthProvider authProvider) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          ),
        ),
        child: Column(
          children: [
            // Header do Drawer
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      authProvider.currentUser?.nome ?? 'Usuário',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      authProvider.currentUser?.email ?? '',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.white24),
            // Itens do Menu
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: Icons.search,
                    title: 'Buscar',
                    onTap: () {
                      Navigator.pop(context);
                      _showSearchDialog(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.person_outline,
                    title: 'Minha Conta',
                    onTap: () {
                      Navigator.pop(context);
                      _showInfo(context, 'Minha Conta');
                    },
                  ),
                  const Divider(color: Colors.white24),
                  _buildDrawerItem(
                    icon: Icons.logout,
                    title: 'Sair',
                    onTap: () async {
                      Navigator.pop(context);
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, AppRoutes.leadingLogIn);
                      }
                    },
                    iconColor: Colors.red,
                  ),
                ],
              ),
            ),
            // Versão do App
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Rinnovare App v1.0',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          color: iconColor == Colors.red ? Colors.red : Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
      hoverColor: Colors.white.withValues(alpha: 0.1),
      splashColor: Colors.white.withValues(alpha: 0.2),
    );
  }

  Widget _buildPlantCard(BuildContext context, Plant plant) {
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
              // Ícone da planta - lado esquerdo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const SolarIcon(size: 32, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(width: 12),
              // Informações - lado direito
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
                      plant.localizacao,
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
              const SizedBox(width: 4),
              // Seta indicadora
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
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Plantas'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Digite o nome da planta...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (value) {
            Navigator.pop(context);
          },
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  void _showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}