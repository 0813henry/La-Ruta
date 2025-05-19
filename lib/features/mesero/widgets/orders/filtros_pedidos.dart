import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';

class FiltrosPedidos extends StatelessWidget {
  final String selectedEstado;
  final String selectedTipo;
  final ValueChanged<String> onEstadoChanged;
  final ValueChanged<String> onTipoChanged;

  const FiltrosPedidos({
    super.key,
    required this.selectedEstado,
    required this.selectedTipo,
    required this.onEstadoChanged,
    required this.onTipoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _buildDropdown(
          label: selectedEstado,
          items: [
            {'label': 'Todos', 'color': AppColors.coolGray},
            {'label': 'Pendiente', 'color': AppColors.pendiente},
            {'label': 'En Proceso', 'color': AppColors.enProceso},
            {'label': 'Listo', 'color': AppColors.listoParaServir},
          ],
          onChanged: onEstadoChanged,
        )),
        Expanded(
            child: _buildDropdown(
          label: selectedTipo,
          items: [
            {'label': 'Todos', 'color': AppColors.coolGray},
            {'label': 'Local', 'color': AppColors.principal},
            {'label': 'Domicilio', 'color': AppColors.domicilio},
            {'label': 'VIP', 'color': AppColors.vip},
          ],
          onChanged: onTipoChanged,
        )),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<Map<String, dynamic>> items,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: DropdownButton<String>(
        value: label,
        isExpanded: true,
        items: items
            .map((item) => DropdownMenuItem<String>(
                  value: item['label'],
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: item['color'] as Color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(item['label']),
                    ],
                  ),
                ))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }
}
