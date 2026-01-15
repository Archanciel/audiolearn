// lib/models/help_section.dart

import 'package:flutter/material.dart';

class HelpSection {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int startStep;
  final int endStep;

  HelpSection({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.startStep,
    required this.endStep,
  });

  int get stepCount => endStep - startStep + 1;
}
