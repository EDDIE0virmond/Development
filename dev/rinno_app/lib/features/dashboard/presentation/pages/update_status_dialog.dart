// lib/features/dashboard/presentation/pages/update_status_dialog.dart
import 'package:flutter/material.dart';
import '../../../../core/models/plant_status.dart';
import '../../../auth/presentation/widgets/green_button.dart';

class UpdateStatusDialog extends StatefulWidget {
  final PlantStatus status;
  final Function(bool, String?) onUpdate;

  const UpdateStatusDialog({
    super.key,
    required this.status,
    required this.onUpdate,
  });

  @override
  State<UpdateStatusDialog> createState() => _UpdateStatusDialogState();
}

class _UpdateStatusDialogState extends State<UpdateStatusDialog> {
  final _observacaoController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _observacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.status.isCompleted ? 'Reabrir Status' : 'Concluir Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              widget.status.nome,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _observacaoController,
              decoration: const InputDecoration(
                labelText: 'Observação (opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.comment_outlined),
              ),
              maxLines: 3,
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
                    text: widget.status.isCompleted ? 'REABRIR' : 'CONCLUIR',
                    onPressed: () {
                      widget.onUpdate(
                        !widget.status.isCompleted,
                        _observacaoController.text.isEmpty 
                            ? null 
                            : _observacaoController.text,
                      );
                      Navigator.pop(context);
                    },
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}