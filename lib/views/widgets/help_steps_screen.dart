// lib/views/help_steps_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/help_step.dart';
import '../../viewmodels/help_page_viewmodel.dart';
import 'help_step_page.dart';
import 'page_indicator.dart';
import 'navigation_buttons.dart';

class HelpStepsScreen extends StatelessWidget {
  final List<HelpStep> steps;
  final String sectionTitle;
  final int initialPage;

  const HelpStepsScreen({
    super.key,
    required this.steps,
    required this.sectionTitle,
    this.initialPage = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HelpPageViewModel(
        steps: steps,
        initialPage: initialPage,
      ),
      child: Consumer<HelpPageViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sectionTitle,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Étape ${viewModel.currentPage + 1}/${viewModel.totalPages}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.list),
                  tooltip: 'Liste des étapes',
                  onPressed: () => _showStepsList(context, viewModel),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            body: Column(
              children: [
                // PageView avec les étapes
                Expanded(
                  child: PageView.builder(
                    controller: viewModel.pageController,
                    itemCount: steps.length,
                    itemBuilder: (context, index) {
                      return HelpStepPage(step: steps[index]);
                    },
                  ),
                ),

                // Indicateur de page
                PageIndicator(
                  currentPage: viewModel.currentPage,
                  totalPages: viewModel.totalPages,
                ),

                // Boutons de navigation
                NavigationButtons(
                  isFirstPage: viewModel.isFirstPage,
                  isLastPage: viewModel.isLastPage,
                  onPrevious: viewModel.previousPage,
                  onNext: viewModel.nextPage,
                  onClose: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showStepsList(BuildContext context, HelpPageViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: steps.length,
          itemBuilder: (context, index) {
            final step = steps[index];
            final isCurrentStep = index == viewModel.currentPage;
            
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: isCurrentStep
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300],
                child: Text(
                  '${step.stepNumber}',
                  style: TextStyle(
                    color: isCurrentStep ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                step.title,
                style: TextStyle(
                  fontWeight: isCurrentStep ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isCurrentStep
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                    )
                  : null,
              onTap: () {
                viewModel.jumpToPage(index);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}
