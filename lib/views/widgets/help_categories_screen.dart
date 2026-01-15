import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../constants.dart';
import '../../models/help_category.dart';
import '../../viewmodels/help_categories_viewmodel.dart';
import 'help_sections_screen.dart';

/// This dialog is displayed when the user selects the help menu item
/// from the application right appbar popup menu. It contains a list
/// of app help topics.
class HelpCategoriesScreen extends StatelessWidget {
  const HelpCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HelpCategoriesViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Aide Audio Learn'),
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        ...viewModel.categories.map((category) => 
          _buildCategoryCard(context, category)
        ),
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
            'Consultez l\'aide d\'introduction d\'Audio Learn lors de votre première utilisation de l\'application afin de l\'initialiser correctement.',
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
}