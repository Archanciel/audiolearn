// lib/views/help_sections_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/help_guide_viewmodel.dart';
import '../../models/help_section.dart';
import '../../models/help_category.dart';
import 'help_steps_screen.dart';

class HelpSectionsScreen extends StatelessWidget {
  final HelpCategory category;

  const HelpSectionsScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HelpGuideViewModel(
        jsonFilePath: category.jsonFilePath,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            category.title,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          centerTitle: true,
          elevation: 2,
        ),
        body: Consumer<HelpGuideViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (viewModel.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        viewModel.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => viewModel.reload(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            }

            return _buildSectionsList(context, viewModel);
          },
        ),
      ),
    );
  }

  Widget _buildSectionsList(
    BuildContext context,
    HelpGuideViewModel viewModel,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        ...viewModel.sections
            .map((section) => _buildSectionCard(context, viewModel, section)),
      ],
    );
  }

  Widget _buildHeader() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              category.icon,
              size: 60,
              color: Colors.blue[700],
            ),
            const SizedBox(height: 12),
            Text(
              category.description,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Sélectionnez une section pour commencer',
              style: TextStyle(fontSize: 14, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    HelpGuideViewModel viewModel,
    HelpSection section,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToSection(context, viewModel, section),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icône de section
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  section.icon,
                  size: 30,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(width: 16),

              // Contenu de la section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      section.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.list_alt,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${section.stepCount} étapes',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Flèche
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSection(
    BuildContext context,
    HelpGuideViewModel viewModel,
    HelpSection section,
  ) {
    final steps = viewModel.getStepsForSection(section.id);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HelpStepsScreen(
          steps: steps,
          sectionTitle: section.title,
          categoryId: category.id, // Passer l'ID de la catégorie
          sectionId: section.id, // Passer l'ID de la section
        ),
      ),
    );
  }
}
