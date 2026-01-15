// lib/viewmodels/help_page_viewmodel.dart

import 'package:flutter/material.dart';
import '../models/help_step.dart';

class HelpPageViewModel extends ChangeNotifier {
  final PageController pageController;
  final List<HelpStep> steps;
  int _currentPage = 0;

  HelpPageViewModel({
    required this.steps,
    int initialPage = 0,
  }) : pageController = PageController(initialPage: initialPage) {
    _currentPage = initialPage;
    pageController.addListener(_onPageChanged);
  }

  int get currentPage => _currentPage;
  int get totalPages => steps.length;
  bool get isFirstPage => _currentPage == 0;
  bool get isLastPage => _currentPage == steps.length - 1;
  HelpStep get currentStep => steps[_currentPage];

  void _onPageChanged() {
    final page = pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      _currentPage = page;
      notifyListeners();
    }
  }

  void nextPage() {
    if (!isLastPage) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousPage() {
    if (!isFirstPage) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void jumpToPage(int page) {
    if (page >= 0 && page < steps.length) {
      pageController.jumpToPage(page);
    }
  }

  @override
  void dispose() {
    pageController.removeListener(_onPageChanged);
    pageController.dispose();
    super.dispose();
  }
}
