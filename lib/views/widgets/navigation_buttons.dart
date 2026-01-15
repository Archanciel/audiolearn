// lib/widgets/navigation_buttons.dart

import 'package:flutter/material.dart';

class NavigationButtons extends StatelessWidget {
  final bool isFirstPage;
  final bool isLastPage;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onClose;

  const NavigationButtons({
    super.key,
    required this.isFirstPage,
    required this.isLastPage,
    required this.onPrevious,
    required this.onNext,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Bouton Précédent
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isFirstPage ? null : onPrevious,
                icon: const Icon(Icons.arrow_back, size: 20),
                label: const Text('Précédent'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  disabledBackgroundColor: Colors.grey[800],
                  disabledForegroundColor: Colors.grey[600],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Bouton Suivant ou Terminer
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isLastPage ? onClose : onNext,
                icon: Icon(
                  isLastPage ? Icons.check : Icons.arrow_forward,
                  size: 20,
                ),
                label: Text(isLastPage ? 'Terminer' : 'Suivant'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: isLastPage
                      ? const Color.fromARGB(255, 160, 160, 67)
                      : const Color.fromARGB(255, 92, 160, 67)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
