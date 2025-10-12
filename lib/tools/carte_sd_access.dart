import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<Directory?> obtenirRepertoireCartSD() async {
  // Obtenir tous les répertoires de stockage externe
  List<Directory>? directories = await getExternalStorageDirectories();
  
  if (directories != null && directories.length > 1) {
    // Le premier est généralement le stockage interne
    // Le second (et suivants) sont les cartes SD externes
    Directory carteSdBase = directories[1];
    
    // Remonter à la racine de la carte SD
    // De : /storage/XXXX-XXXX/Android/data/com.exemple.app/files
    // À : /storage/XXXX-XXXX/
    String cheminCarteSd = carteSdBase.path.split('/Android')[0];
    
    // Construire le chemin vers votre répertoire
    String cheminComplet = path.join(cheminCarteSd, 'sauvegarde', 'mp3');
    Directory monRepertoire = Directory(cheminComplet);
    
    print('Chemin carte SD : $cheminComplet');
    
    if (await monRepertoire.exists()) {
      return monRepertoire;
    }
  }
  
  return null;
}

void main() async {
  Directory? repertoireSD = await obtenirRepertoireCartSD();
  
  if (repertoireSD != null) {
    print('Répertoire trouvé : ${repertoireSD.path}');
    
    // Lister les fichiers MP3
    List<FileSystemEntity> fichiers = repertoireSD.listSync();
    for (var fichier in fichiers) {
      if (fichier.path.endsWith('.mp3')) {
        print(fichier.path);
      }
    }
  } else {
    print('Carte SD non trouvée ou répertoire inexistant');
  }
}