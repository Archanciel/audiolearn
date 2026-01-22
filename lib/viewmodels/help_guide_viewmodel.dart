// lib/viewmodels/help_guide_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/help_step.dart';
import '../models/help_section.dart';

class HelpGuideViewModel extends ChangeNotifier {
  final String jsonFilePath;

  List<HelpStep> _allSteps = [];
  List<HelpSection> _sections = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<HelpStep> get allSteps => _allSteps;
  List<HelpSection> get sections => _sections;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  HelpGuideViewModel({
    required this.jsonFilePath,
  }) {
    _initializeSections();
    _loadHelpContent();
  }

  void _initializeSections() {
    // Sections pour "Introduction d'AudioLearn" (playlist_usage)
    if (jsonFilePath.contains('playlist_usage')) {
      _sections = [
        HelpSection(
          id: "create_playlist",
          title: "Créer une playlist YouTube",
          description:
              "Apprenez à créer une playlist YouTube Non répertoriée ou Publique.",
          icon: Icons.playlist_add,
          startStep: 1,
          endStep: 13,
        ),
        HelpSection(
          id: "download_playlist",
          title: "Télécharger la playlist",
          description:
              "Téléchargez les audios de votre playlist dans l'application.",
          icon: Icons.download,
          startStep: 14,
          endStep: 19,
        ),
        HelpSection(
          id: "download_single",
          title: "Télécharger une vidéo unique",
          description: "Téléchargez l'audio d'une seule vidéo YouTube.",
          icon: Icons.download_for_offline,
          startStep: 20,
          endStep: 26,
        ),
      ];
    }
    // Sections pour "Introduction d'AudioLearn" (playlist_usage)
    else if (jsonFilePath.contains('playlist_local_usage')) {
      _sections = [
        HelpSection(
          id: "create_playlist",
          title: "Créer une playlist locale",
          description:
              "Apprenez à créer une playlist locale.",
          icon: Icons.playlist_add,
          startStep: 1,
          endStep: 4,
        ),
        HelpSection(
          id: "local_playlist_utility",
          title: "Utilité des playlists locales",
          description:
              "Description de l'usage des playlists locales.",
          icon: Icons.playlist_play_rounded,
          startStep: 5,
          endStep: 7,
        ),
      ];
    }
    // Sections pour menu "Convertir un texte en audio"
    else if (jsonFilePath.contains("text_to_speech_conversion")) {
      _sections = [
        HelpSection(
          id: "first_conversion",
          title: "Première conversion d'un texte en audio",
          description:
              "Apprenez à convertir un texte en audio dans une playlist existante.",
          icon: Icons.play_circle_outline,
          startStep: 1,
          endStep: 11,
        ),
        HelpSection(
          id: "conversion_replacement",
          title: "Remplacer la conversion (texte et voix modifiés)",
          description:
              "Si l'écoute de l'audio ne vous convient pas, modifiez le texte et/ou convertissez-le à nouveau en utilisant une voix différente.",
          icon: Icons.play_circle,
          startStep: 12,
          endStep: 19,
        ),
        HelpSection(
          id: "erreur_de_prononciation",
          title: "Résoudre une erreur de prononciation",
          description:
              "Si l'écoute de l'audio vous remarquez qu'un mot est mal prononcé, voici un exemple de solution.",
          icon: Icons.play_lesson,
          startStep: 20,
          endStep: 21,
        ),
      ];
    }
    // Sections pour "Menu Playlist"
    else if (jsonFilePath.contains("menu_playlist")) {
      _sections = [
        HelpSection(
          id: "playlist_operations",
          title: "Opérations sur les Playlists",
          description: "Gérer, modifier et supprimer vos playlists",
          icon: Icons.playlist_play,
          startStep: 1,
          endStep: 10,
        ),
      ];
    }
    // Sections pour "Menu Audio"
    else if (jsonFilePath.contains("menu_audio")) {
      _sections = [
        HelpSection(
          id: "audio_controls",
          title: "Contrôles Audio",
          description: "Lecture, pause et navigation dans les audios",
          icon: Icons.audiotrack,
          startStep: 1,
          endStep: 10,
        ),
      ];
    }
  }

  Future<void> _loadHelpContent() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final String jsonString = await rootBundle.loadString(jsonFilePath);
      final List<dynamic> jsonData = json.decode(jsonString);

      _allSteps = jsonData.map((json) => HelpStep.fromJson(json)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erreur lors du chargement du guide: $e';
      notifyListeners();
    }
  }

  List<HelpStep> getStepsForSection(String sectionId) {
    return _allSteps.where((step) => step.sectionId == sectionId).toList();
  }

  HelpSection? getSectionById(String sectionId) {
    try {
      return _sections.firstWhere((section) => section.id == sectionId);
    } catch (e) {
      return null;
    }
  }

  Future<void> reload() async {
    await _loadHelpContent();
  }
}
