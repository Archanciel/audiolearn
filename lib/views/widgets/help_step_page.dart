// lib/widgets/help_step_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/help_step.dart';

class HelpStepPage extends StatelessWidget {
  final HelpStep step;

  const HelpStepPage({
    super.key,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Conteneur avec titre et description
          _buildDescriptionContainer(context),

          // Image (capture d'écran) - ✅ Afficher seulement si imagePath n'est pas vide
          (step.imagePath.isNotEmpty)
              ? _buildImageViewer(context)
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildImageViewer(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.60,
      ),
      child: InteractiveViewer(
        panEnabled: true,
        boundaryMargin: const EdgeInsets.all(20),
        minScale: 1.0,
        maxScale: 3.0,
        child: Center(
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    // Vérifier si le fichier existe (pour Android/mobile)
    if (step.imagePath.startsWith('assets/')) {
      return Image.asset(
        step.imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageError();
        },
      );
    } else {
      // Pour les fichiers locaux (Windows/Desktop)
      final file = File(step.imagePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildImageError();
          },
        );
      }
      return _buildImageError();
    }
  }

  Widget _buildImageError() {
    return Container(
      width: 300,
      height: 400,
      color: Colors.grey[800],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 60,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 12),
          Text(
            'Image non disponible',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Étape ${step.stepNumber}',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionContainer(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.grey[900],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Numéro d'étape
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Étape ${step.stepNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Titre
          Text(
            step.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            step.description,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 16,
              height: 1.6,
            ),
          ),

          // Astuce pour zoomer - ✅ Afficher seulement si il y a une image
          if (step.imagePath.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.zoom_in,
                  size: 16,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 6),
                Text(
                  'Pincez pour zoomer sur l\'image',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
