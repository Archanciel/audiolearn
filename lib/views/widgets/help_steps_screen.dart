// lib/views/widgets/help_steps_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/help_step.dart';
import '../../services/help_data_service.dart';
import '../../viewmodels/help_page_viewmodel.dart';
import 'help_step_page.dart';
import 'page_indicator.dart';
import 'navigation_buttons.dart';

class HelpStepsScreen extends StatefulWidget {
  final List<HelpStep> steps;
  final String sectionTitle;
  final int initialPage;
  final String categoryId;
  final String sectionId;

  const HelpStepsScreen({
    super.key,
    required this.steps,
    required this.sectionTitle,
    required this.categoryId,
    required this.sectionId,
    this.initialPage = 0,
  });

  @override
  State<HelpStepsScreen> createState() => _HelpStepsScreenState();
}

class _HelpStepsScreenState extends State<HelpStepsScreen> {
  final HelpDataService _helpDataService = HelpDataService();

  @override
  void dispose() {
    // Sauvegarder la position actuelle en quittant
    _saveCurrentPosition();
    super.dispose();
  }

  void _saveCurrentPosition() {
    final viewModel = context.read<HelpPageViewModel>();
    final currentStep = viewModel.currentStep;

    _helpDataService.saveLastHelpPosition(
      categoryId: widget.categoryId,
      sectionId: widget.sectionId,
      stepNumber: currentStep.stepNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HelpPageViewModel(
        steps: widget.steps,
        initialPage: widget.initialPage,
      ),
      child: Consumer<HelpPageViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.sectionTitle,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                    maxLines: 2,
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
                  onPressed: () {
                    _saveCurrentPosition();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                // PageView avec les étapes
                Expanded(
                  child: PageView.builder(
                    controller: viewModel.pageController,
                    itemCount: widget.steps.length,
                    onPageChanged: (index) {
                      // Sauvegarder automatiquement quand on change de page
                      _helpDataService.saveLastHelpPosition(
                        categoryId: widget.categoryId,
                        sectionId: widget.sectionId,
                        stepNumber: widget.steps[index].stepNumber,
                      );
                    },
                    itemBuilder: (context, index) {
                      return HelpStepPage(step: widget.steps[index]);
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
                  onClose: () {
                    _saveCurrentPosition();
                    Navigator.pop(context);
                  },
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
          itemCount: widget.steps.length,
          itemBuilder: (context, index) {
            final step = widget.steps[index];
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
                  fontWeight:
                      isCurrentStep ? FontWeight.bold : FontWeight.normal,
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
                // Sauvegarder la nouvelle position
                _helpDataService.saveLastHelpPosition(
                  categoryId: widget.categoryId,
                  sectionId: widget.sectionId,
                  stepNumber: step.stepNumber,
                );
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}
