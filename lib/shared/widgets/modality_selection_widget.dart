import 'package:flutter/material.dart';
import '../../../../shared/models/football_modality.dart';

class ModalitySelectionWidget extends StatelessWidget {
  final FootballModality selectedModality;
  final Function(FootballModality) onModalityChanged;

  const ModalitySelectionWidget({
    super.key,
    required this.selectedModality,
    required this.onModalityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Modalidad de Fútbol',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children:
                    FootballModality.values.map((modality) {
                      final isSelected = selectedModality == modality;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => onModalityChanged(modality),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Colors.white
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow:
                                  isSelected
                                      ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.1,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                      : null,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  modality.format,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isSelected
                                            ? Color(
                                              int.parse(
                                                    modality.colorHex.substring(
                                                      1,
                                                    ),
                                                    radix: 16,
                                                  ) +
                                                  0xFF000000,
                                            )
                                            : Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  modality.displayName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        isSelected
                                            ? Colors.grey.shade700
                                            : Colors.grey.shade500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${modality.rules.minPlayers}-${modality.rules.maxPlayers}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade400,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          selectedModality.rules.description,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class ModalityInfoCard extends StatelessWidget {
  final FootballModality modality;
  final bool isSelected;
  final VoidCallback? onTap;

  const ModalityInfoCard({
    super.key,
    required this.modality,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(
      int.parse(modality.colorHex.substring(1), radix: 16) + 0xFF000000,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      modality.format,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        modality.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        '${modality.rules.minPlayers}-${modality.rules.maxPlayers} jugadores',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: color, size: 24),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              modality.rules.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
