import 'dart:convert';
import 'dart:io';

/// https://chat.openai.com/share/1ca44f12-88f4-4d9d-9620-73447d16012d
void main() async {
  // Simulated content of an ARB file as a JSON string, including a parameterized string
  // String arbContent = '''
  // {
  // "tryAlreadyDownloadedAudiosPlaylistHelpTitle": "Audios déjà téléchargés",
  // "tryAlreadyDownloadedAudiosPlaylistHelpContent": "La sélection de la case à cocher permet de modifier la vitesse de lecture pour les fichiers audio de la playlist déjà présents sur l'appareil."
  // }
  // ''';

  const String emptyArbContent = '''
  {
  }
  ''';

  String arbContent = '''
  {
  }
  ''';

  if (arbContent == emptyArbContent) {
    final String clipboardData = await getClipboardContent();
    final String clipboardDataTrimmed = clipboardData.trim();

    if (clipboardDataTrimmed.startsWith('{') &&
        clipboardDataTrimmed.endsWith('}')) {
      arbContent = clipboardData;
    } else {
      arbContent = "{$clipboardData}";
    }
  }

  // Parsing the ARB content into a Map
  Map<String, dynamic> arbData = json.decode(arbContent);

  // Generating the Dart class
  String dartClass = generateLocalizationClass(arbData);

  // Define the path to the file in the test directory
  String filePath =
      "C:\\Users\\Jean-Pierre\\Development\\Flutter\\audiolearn\\test\\viewmodels\\mock_app_localizations.dart";

  // Insert the generated class into the file
  await insertIntoFile(filePath, dartClass);

  // Now format the file
  await Process.run('dart', ['format', filePath]);

  print('Localization class has been inserted into $filePath');
}

String generateLocalizationClass(Map<String, dynamic> arbData) {
  StringBuffer sb = StringBuffer();

  // Generate getters or methods for each key in the JSON
  arbData.forEach((key, value) {
    // Check if the value contains parameters
    RegExp exp = RegExp(r'\{([^}]+)\}');
    var matches = exp.allMatches(value);

    if (matches.isEmpty) {
      // Generate a simple getter if there are no parameters
      String getterName = toCamelCase(key);
      sb.writeln('  @override');
      sb.writeln('  String get $getterName => "$value";');
      sb.writeln();
    } else {
      // Generate a method if there are parameters
      String methodName = toCamelCase(key);
      String methodParameters =
          matches.map((m) => 'Object ${m.group(1)}').join(', ');
      String formattedString =
          value.replaceAllMapped(exp, (m) => '\${${m.group(1)}}');

      // Correctly escape double quotes inside the string
      formattedString = formattedString.replaceAll('"', '\\"');

      sb.writeln('  @override');
      sb.writeln('  String $methodName($methodParameters,) =>');
      sb.writeln('      "$formattedString";');
      sb.writeln();
    }
  });

  return sb.toString();
}

Future<void> insertIntoFile(
  String filePath,
  String contentToInsert,
) async {
  var file = File(filePath);
  if (await file.exists()) {
    String originalContent = await file.readAsString();
    int insertPosition = originalContent.lastIndexOf('}');

    contentToInsert = contentToInsert.trimRight();

    if (insertPosition != -1) {
      String newContent =
          '${originalContent.substring(0, insertPosition)}\n$contentToInsert\n${originalContent.substring(insertPosition)}';
      await file.writeAsString(newContent);
    }
  }
}

String toCamelCase(String text) {
  List<String> parts = text.split('_');
  for (int i = 1; i < parts.length; i++) {
    parts[i] = parts[i][0].toUpperCase() + parts[i].substring(1);
  }
  return parts.join();
}

Future<String> getClipboardContent() async {
  ProcessResult result;
  if (Platform.isMacOS) {
    result = await Process.run('pbpaste', []);
  } else if (Platform.isLinux) {
    // Ensure xclip or xsel is installed
    result = await Process.run('xclip', ['-selection', 'clipboard', '-o']);
    // Alternatively: result = await Process.run('xsel', ['--clipboard', '--output']);
  } else if (Platform.isWindows) {
    result =
        await Process.run('powershell', ['Get-Clipboard'], runInShell: true);
  } else {
    throw Exception('Clipboard not supported on this platform');
  }

  if (result.exitCode != 0) {
    throw Exception('Failed to access clipboard: ${result.stderr}');
  }

  return result.stdout.toString().trim();
}
