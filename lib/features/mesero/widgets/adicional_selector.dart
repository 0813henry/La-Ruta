import 'package:flutter/material.dart';
import '../../../core/model/adicional_model.dart';
import '../../../core/services/adicional_service.dart';

class AdicionalSelector extends StatefulWidget {
  final Function(List<Adicional>) onAdicionalesSelected;

  const AdicionalSelector({required this.onAdicionalesSelected, super.key});

  @override
  _AdicionalSelectorState createState() => _AdicionalSelectorState();
}

class _AdicionalSelectorState extends State<AdicionalSelector> {
  final AdicionalService _adicionalService = AdicionalService();
  final Set<String> _selectedAdicionalIds =
      {}; // Track selected adicionales by ID

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Adicional>>(
      stream: _adicionalService.obtenerAdicionales(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No hay adicionales disponibles.'));
        }
        final adicionales = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          itemCount: adicionales.length,
          itemBuilder: (context, index) {
            final adicional = adicionales[index];
            final isSelected = _selectedAdicionalIds.contains(adicional.id);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.green : Colors.grey[300],
                  foregroundColor: isSelected ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    if (isSelected) {
                      _selectedAdicionalIds.remove(adicional.id);
                    } else {
                      _selectedAdicionalIds.add(adicional.id);
                    }
                  });
                  widget.onAdicionalesSelected(
                    adicionales
                        .where((ad) => _selectedAdicionalIds.contains(ad.id))
                        .toList(),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(adicional.name),
                    Text('\$${adicional.price.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
