// lib/views/widgets/help_categories_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/help_category.dart';
import '../../services/help_data_service.dart';
import '../../viewmodels/help_categories_viewmodel.dart';
import '../../viewmodels/help_guide_viewmodel.dart';
import 'help_sections_screen.dart';
import 'help_steps_screen.dart';

class HelpCategoriesScreen extends StatelessWidget {
  const HelpCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HelpCategoriesViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Aide AudioLearn',
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          centerTitle: true,
          elevation: 2,
        ),
        body: Consumer<HelpCategoriesViewModel>(
          builder: (context, viewModel, child) {
            return _buildCategoriesList(context, viewModel);
          },
        ),
      ),
    );
  }

  Widget _buildCategoriesList(
    BuildContext context,
    HelpCategoriesViewModel viewModel,
  ) {
    final helpDataService = HelpDataService();
    final hasLastPosition = helpDataService.hasLastHelpPosition();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(),
        const SizedBox(height: 24),

        // Bouton pour reprendre où on s'était arrêté
        if (hasLastPosition) ...[
          _buildResumeCard(context, viewModel, helpDataService),
          const SizedBox(height: 24),
        ],

        ...viewModel.categories
            .map((category) => _buildCategoryCard(context, category)),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'Consultez l\'aide d\'introduction d\'AudioLearn lors de votre première utilisation de l\'application afin de l\'initialiser correctement.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResumeCard(
    BuildContext context,
    HelpCategoriesViewModel viewModel,
    HelpDataService helpDataService,
  ) {
    final categoryId = helpDataService.getLastHelpCategoryId();
    final category = viewModel.getCategoryById(categoryId ?? '');

    if (category == null) {
      // Si la catégorie n'existe plus, effacer la position sauvegardée
      helpDataService.clearLastHelpPosition();
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 0),
      elevation: 4,
      color: Colors.blue[700],
      child: InkWell(
        onTap: () => _resumeLastPosition(context, viewModel, helpDataService),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icône
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.history,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),

              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reprendre où vous en étiez',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // Flèche
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    HelpCategory category,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToCategory(context, category),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icône de catégorie
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      category.icon,
                      size: 28,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Titre de la catégorie
                  Expanded(
                    child: Text(
                      category.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                category.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCategory(
    BuildContext context,
    HelpCategory category,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HelpSectionsScreen(
          category: category,
        ),
      ),
    );
  }

  Future<void> _resumeLastPosition(
    BuildContext context,
    HelpCategoriesViewModel viewModel,
    HelpDataService helpDataService,
  ) async {
    final categoryId = helpDataService.getLastHelpCategoryId();
    final sectionId = helpDataService.getLastHelpSectionId();
    final stepNumber = helpDataService.getLastHelpStepNumber();

    if (categoryId == null || sectionId == null || stepNumber == null) {
      return;
    }

    final category = viewModel.getCategoryById(categoryId);
    if (category == null) {
      helpDataService.clearLastHelpPosition();
      return;
    }

    // Charger le guide pour cette catégorie
    final guideViewModel = HelpGuideViewModel(
      jsonFilePath: category.jsonFilePath,
    );

    // Attendre que le contenu soit chargé
    await Future.delayed(const Duration(milliseconds: 100));

    if (!context.mounted) return;

    // Récupérer les étapes de la section
    final steps = guideViewModel.getStepsForSection(sectionId);

    if (steps.isEmpty) {
      helpDataService.clearLastHelpPosition();
      return;
    }

    final section = guideViewModel.getSectionById(sectionId);
    if (section == null) {
      helpDataService.clearLastHelpPosition();
      return;
    }

    // Trouver l'index de l'étape
    final stepIndex = steps.indexWhere((step) => step.stepNumber == stepNumber);
    final initialPage = stepIndex >= 0 ? stepIndex : 0;

    // Naviguer directement vers HelpStepsScreen avec la bonne page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HelpStepsScreen(
          steps: steps,
          sectionTitle: section.title,
          initialPage: initialPage,
          categoryId: categoryId,
          sectionId: sectionId,
        ),
      ),
    );
  }
}
