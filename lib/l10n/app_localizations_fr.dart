// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appBarTitleDownloadAudio => 'Téléch. Audio';

  @override
  String get downloadAudioScreen => 'Écran Télécharger Audio';

  @override
  String get appBarTitleAudioPlayer => 'Lire Audio';

  @override
  String get audioPlayerScreen => 'Écran Lire Audio';

  @override
  String get toggleList => 'Basculer la liste';

  @override
  String get delete => 'Supprimer';

  @override
  String get moveItemUp => 'Déplacer l\'élément vers le haut';

  @override
  String get moveItemDown => 'Déplacer l\'élément vers le bas';

  @override
  String get language => 'Langue';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';

  @override
  String get downloadAudio => 'Télécharger Audio Youtube';

  @override
  String translate(String language) {
    return '$language';
  }

  @override
  String get musicalQualityTooltip =>
      'Pour une playlist Youtube, si activé, télécharge en qualité musicale. Pour une playlist locale, si activé, indique que la playlist est en qualité musicale.';

  @override
  String get ofPreposition => 'de';

  @override
  String get atPreposition => 'à';

  @override
  String get ytPlaylistLinkLabel => 'Lien Youtube ou recherche';

  @override
  String get ytPlaylistLinkHintText => 'Entrez lien Youtube ou phrase';

  @override
  String get addPlaylist => 'Ajout';

  @override
  String get downloadSingleVideoAudio => 'Un';

  @override
  String get downloadSelectedPlaylist => 'Playlist';

  @override
  String get stopDownload => 'Stop';

  @override
  String get audioDownloadingStopping => 'Téléch en cessation ...';

  @override
  String audioDownloadError(Object error) {
    return 'Erreur de téléchargement: $error';
  }

  @override
  String get about => 'Version ...';

  @override
  String get help => 'Aide ...';

  @override
  String get defineSortFilterAudiosMenu => 'Trier/filtrer audio ...';

  @override
  String get clearSortFilterAudiosParmsHistoryMenu =>
      'Effacer l\'historique des paramètres de tri/filtre';

  @override
  String get saveSortFilterAudiosOptionsToPlaylistMenu =>
      'Sauvegarder les paramètres tri/filtre dans la playlist ...';

  @override
  String get sortFilterDialogTitle => 'Paramètres tri et filtre';

  @override
  String get sortBy => 'Trier par:';

  @override
  String get audioDownloadDate => 'Date téléch audio';

  @override
  String get videoUploadDate => 'Date mise en ligne vidéo';

  @override
  String get audioEnclosingPlaylistTitle => 'Titre playlist audio';

  @override
  String get audioDuration => 'Durée audio';

  @override
  String get audioRemainingDuration => 'Durée audio écoutable restante';

  @override
  String get audioFileSize => 'Taille fichier audio';

  @override
  String get audioMusicQuality => 'Qual. musicale';

  @override
  String get audioSpokenQuality => 'Q. orale';

  @override
  String get audioDownloadSpeed => 'Vitesse téléch audio';

  @override
  String get audioDownloadDuration => 'Durée téléch audio';

  @override
  String get sortAscending => 'Asc';

  @override
  String get sortDescending => 'Desc';

  @override
  String get filterSentences => 'Mots filtre:';

  @override
  String get filterOptions => 'Options filtre:';

  @override
  String get videoTitleOrDescription => 'Titre vidéo (mot ou phrase)';

  @override
  String get startDownloadDate => 'Date début téléch';

  @override
  String get endDownloadDate => 'Date fin téléch';

  @override
  String get startUploadDate => 'Date début mise en ligne';

  @override
  String get endUploadDate => 'Date fin mise en ligne';

  @override
  String get fileSizeRange => 'Intervalle taille fichier (MB)';

  @override
  String get start => 'Début';

  @override
  String get end => 'Fin';

  @override
  String get audioDurationRange => 'Intervalle durée audio (hh:mm)';

  @override
  String get openYoutubeVideo => 'Ouvrir la vidéo Youtube';

  @override
  String get openYoutubePlaylist => 'Ouvrir la playlist Youtube';

  @override
  String get apply => 'Appl';

  @override
  String get cancelButton => 'Annuler';

  @override
  String get deleteAudio => 'Supprimer l\'audio ...';

  @override
  String get deleteAudioFromPlaylistAswell =>
      'Supprimer l\'audio de la playlist également ...';

  @override
  String deleteAudioFromPlaylistAswellWarning(
      Object audioTitle, Object playlistTitle) {
    return 'Supprimer l\'audio \"$audioTitle\" de la playlist Youtube \"$playlistTitle\", sinon l\'audio sera téléchargé à nouveau lors du prochain téléchargement de la playlist.';
  }

  @override
  String get warningDialogTitle => 'AVERTISSEMENT';

  @override
  String updatedPlaylistUrlTitle(Object title) {
    return 'L\'URL de la playlist Youtube \"$title\" a été mise à jour. La playlist peut être téléchargée avec sa nouvelle URL.';
  }

  @override
  String addYoutubePlaylistTitle(Object title, Object quality) {
    return 'Nouvelle playlist Youtube \"$title\" de qualité $quality ajoutée à la fin de la liste des playlists.';
  }

  @override
  String addCorrectedYoutubePlaylistTitle(
      Object originalTitle, Object quality, Object correctedTitle) {
    return 'Nouvelle playlist Youtube \"$originalTitle\" de qualité $quality ajoutée avec le titre corrigé \"$correctedTitle\" à la fin de la liste des playlists.';
  }

  @override
  String addLocalPlaylistTitle(Object title, Object quality) {
    return 'Nouvelle playlist locale \"$title\" de qualité $quality ajoutée à la fin de la liste des playlists.';
  }

  @override
  String invalidPlaylistUrl(Object url) {
    return 'L\'URL \"$url\" ne pointe pas sur une playlist. Aucune playlist n\'a donc été ajoutée ou modifiée.';
  }

  @override
  String renameFileNameAlreadyUsed(Object fileName) {
    return 'Le nom de fichier \"$fileName\" est déjà utilisé par un autre fichier dans le même répertoire et ne peut donc pas être réutilisé.';
  }

  @override
  String playlistWithUrlAlreadyInListOfPlaylists(Object url, Object title) {
    return 'La playlist \"$title\" avec l\'URL \"$url\" est déjà dans la liste des playlists et ne sera donc pas recrée.';
  }

  @override
  String localPlaylistWithTitleAlreadyInListOfPlaylists(Object title) {
    return 'La playlist locale \"$title\" est déjà dans la liste des playlists. Par conséquent, la playlist locale avec ce titre ne sera pas créée.';
  }

  @override
  String youtubePlaylistWithTitleAlreadyInListOfPlaylists(Object title) {
    return 'La playlist Youtube \"$title\" est déjà dans la liste des playlists. Par conséquent, la playlist locale avec ce titre ne sera pas créée.';
  }

  @override
  String downloadAudioYoutubeError(Object videoTitle, Object exceptionMessage) {
    return 'ÉCHEC du téléchargement de l\'audio de la vidéo \"$videoTitle\" Youtube: \"$exceptionMessage\".';
  }

  @override
  String downloadAudioYoutubeErrorExceptionMessageOnly(
      Object exceptionMessage) {
    return 'Erreur de téléchargement audio Youtube: \"$exceptionMessage\".';
  }

  @override
  String downloadAudioYoutubeErrorDueToLiveVideoInPlaylist(
      Object playlistTitle, Object liveVideoString) {
    return 'Erreur de téléchargement audio Youtube. La playlist \"$playlistTitle\" contient une video live qui provoque l\'échec du téléchargement des audio\'s de la playlist. Pour résoudre le problème, après avoir téléchargé l\'audio de la vidéo live comme expliqué ci-dessous, supprimez la vidéo live de la playlist puis redémarrez l\'application et rééssayez.\n\nL\'URL de la vidéo live contient cet élément: \"$liveVideoString\". Afin d\'ajouter l\'audio de cette vidéo live à la playlist \"$playlistTitle\", téléchargez-la séparément en tant que vidéo unique en l\'ajoutant à playlist \"$playlistTitle\".';
  }

  @override
  String downloadAudioFileAlreadyOnAudioDirectory(
      Object audioValidVideoTitle, Object fileName, Object playlistTitle) {
    return 'L\'audio \"$audioValidVideoTitle\" est contenu dans le fichier \"$fileName\" se trouvant dans le répertoire de la playlist cible \"$playlistTitle\" et ne sera donc pas re-téléchargé.';
  }

  @override
  String get noInternet =>
      'Pas d\'Internet. Connectez votre appareil et rééssayez.';

  @override
  String invalidSingleVideoUUrl(Object url) {
    return 'L\'URL \"$url\" censée pointer sur une vidéo unique est invalide. Aucune vidéo n\'a donc été téléchargée.';
  }

  @override
  String get copyYoutubeVideoUrl => 'Copier l\'URL de la vidéo Youtube';

  @override
  String get displayAudioInfo => 'Informations sur l\'audio ...';

  @override
  String get renameAudioFile => 'Renommer le fichier audio ...';

  @override
  String get moveAudioToPlaylist => 'Déplacer l\'audio vers la playlist ...';

  @override
  String get copyAudioToPlaylist => 'Copier l\'audio vers la playlist ...';

  @override
  String get audioInfoDialogTitle => 'Informations sur l\'audio téléchargé';

  @override
  String get youtubeChannelLabel => 'Chaîne Youtube';

  @override
  String get originalVideoTitleLabel => 'Titre vidéo original';

  @override
  String get validVideoTitleLabel => 'Titre vidéo valide';

  @override
  String get videoUrlLabel => 'URL vidéo';

  @override
  String get audioDownloadDateTimeLabel => 'Date/heure téléch';

  @override
  String get audioDownloadDurationLabel => 'Durée téléch';

  @override
  String get audioDownloadSpeedLabel => 'Vitesse téléch';

  @override
  String get videoUploadDateLabel => 'Date mise en ligne';

  @override
  String get audioDurationLabel => 'Durée audio';

  @override
  String get audioFileNameLabel => 'Nom fichier audio';

  @override
  String get audioFileSizeLabel => 'Taille fichier';

  @override
  String get isMusicQualityLabel => 'Qualité musicale';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get octetShort => 'o';

  @override
  String get infiniteBytesPerSecond => '∞ o/s';

  @override
  String get updatePlaylistJsonFilesMenu =>
      'Mettre à jour les fichiers playlist JSON';

  @override
  String get compactVideoDescription => 'Description vidéo compacte';

  @override
  String get ignoreCase => 'Ignorer la casse';

  @override
  String get searchInVideoCompactDescription => 'Inclure la description';

  @override
  String get on => 'le';

  @override
  String get copyYoutubePlaylistUrl => 'Copier l\'URL de la playlist Youtube';

  @override
  String get displayPlaylistInfo => 'Données de la playlist ...';

  @override
  String get playlistInfoDialogTitle => 'Playlist Informations';

  @override
  String get playlistTitleLabel => 'Titre de la playlist';

  @override
  String get playlistIdLabel => 'ID de la playlist';

  @override
  String get playlistUrlLabel => 'URL de la playlist';

  @override
  String get playlistDownloadPathLabel => 'Répertoire de la playlist';

  @override
  String get playlistLastDownloadDateTimeLabel => 'Date/heure dernier téléch';

  @override
  String get playlistIsSelectedLabel => 'Playlist sélectionnée';

  @override
  String get playlistTotalAudioNumberLabel => 'Nombre audio\'s total';

  @override
  String get playlistPlayableAudioNumberLabel => 'Nombre audio\'s jouables';

  @override
  String get playlistPlayableAudioTotalDurationLabel =>
      'Durée totale audio jouable';

  @override
  String get playlistPlayableAudioTotalRemainingDurationLabel =>
      'Durée totale audio non écoutée';

  @override
  String get playlistPlayableAudioTotalSizeLabel =>
      'Taille totale fichiers audio jouables';

  @override
  String get updatePlaylistPlayableAudioList =>
      'Mettre à jour la liste des audio\'s jouables';

  @override
  String updatedPlayableAudioLst(Object number, Object title) {
    return 'La liste des audio\'s jouables de la playlist \"$title\" a été mise à jour. $number audio ont été supprimés.';
  }

  @override
  String get addYoutubePlaylistDialogTitle => 'Ajouter une playlist Youtube';

  @override
  String get addLocalPlaylistDialogTitle => 'Ajouter une playlist locale';

  @override
  String get renameAudioFileDialogTitle => 'Renommer le fichier audio';

  @override
  String get renameAudioFileDialogComment => '';

  @override
  String get renameAudioFileLabel => 'Nom';

  @override
  String get renameAudioFileTooltip =>
      'Renommer le fichier audio renomme également le fichier de commentaire audio s\'il existe';

  @override
  String get renameAudioFileButton => 'Renommer';

  @override
  String get modifyAudioTitleDialogTitle => 'Modifier le titre de l\'audio';

  @override
  String get modifyAudioTitleTooltip => '';

  @override
  String get modifyAudioTitleDialogComment =>
      'Modifier le titre audio pour permettre d’ajuster son ordre de lecture.';

  @override
  String get modifyAudioTitleLabel => 'Titre';

  @override
  String get modifyAudioTitleButton => 'Modifier';

  @override
  String get youtubePlaylistUrlLabel => 'URL de la playlist Youtube';

  @override
  String get localPlaylistTitleLabel => 'Titre playlist locale';

  @override
  String get playlistTypeLabel => 'Type de playlist';

  @override
  String get playlistTypeYoutube => 'Youtube';

  @override
  String get playlistTypeLocal => 'Locale';

  @override
  String get playlistQualityLabel => 'Qualité de la playlist';

  @override
  String get playlistQualityMusic => 'musicale';

  @override
  String get playlistQualityAudio => 'vocale';

  @override
  String get audioQualityHighSnackBarMessage =>
      'Téléchargement à qualité musicale';

  @override
  String get audioQualityLowSnackBarMessage => 'Téléchargement à qualité audio';

  @override
  String get add => 'Ajouter';

  @override
  String get noSortFilterSaveAsNameWarning =>
      'Le nom de sauvegarde des paramètres de tri/filtre ne peut pas être vide. Entrez un nom valide et rééssayez ...';

  @override
  String get noPlaylistSelectedForSingleVideoDownloadWarning =>
      'Aucune playlist sélectionnée pour le téléchargement d\'une vidéo unique. Sélectionnez une playlist et rééssayez ...';

  @override
  String get noPlaylistSelectedForAudioCopyWarning =>
      'Aucune playlist sélectionnée pour la copie de l\'audio. Sélectionnez une playlist et rééssayez ...';

  @override
  String get noPlaylistSelectedForAudioMoveWarning =>
      'Aucune playlist sélectionnée pour le déplacement de l\'audio. Sélectionnez une playlist et rééssayez ...';

  @override
  String get tooManyPlaylistSelectedForSingleVideoDownloadWarning =>
      'Plus d\'une playlist sélectionnée pour le téléchargement d\'une vidéo unique. Sélectionnez une seule playlist et rééssayez ...';

  @override
  String get noSortFilterParameterWasModifiedWarning =>
      'Aucun paramètre de tri/filtre n\'a été modifié. Définissez un paramètre et rééssayez ...';

  @override
  String get deletedSortFilterParameterNotExistWarning =>
      'Le paramètre de tri/filtre que vous tentez de supprimer n\'existe pas. Veuillez définir un paramètre de tri/filtre existant et rééssayer ...';

  @override
  String get historicalSortFilterParameterWasDeletedWarning =>
      'Le paramètre de tri/filtre historique a été supprimé.';

  @override
  String get allHistoricalSortFilterParameterWereDeletedWarning =>
      'Tous les paramètres de tri/filtre historiques ont été supprimés.';

  @override
  String get allHistoricalSortFilterParametersDeleteConfirmation =>
      'Suppression de tous les paramètres de tri/filtre historiques.';

  @override
  String playlistRootPathNotExistWarning(Object playlistRootPath) {
    return 'Le répertoire défini \"$playlistRootPath\" n\'existe pas. Veuillez entrer un répertoire valide et rééssayer ...';
  }

  @override
  String get confirmDialogTitle => 'CONFIRMATION';

  @override
  String confirmSingleVideoAudioPlaylistTitle(Object title) {
    return 'Confirmez la playlist cible \"$title\" sélectionnée pour le téléchargement en qualité vocale de l\'audio de la vidéo unique.';
  }

  @override
  String confirmSingleVideoAudioAtMusicQualityPlaylistTitle(Object title) {
    return 'Confirmez la playlist cible \"$title\" sélectionnée pour le téléchargement en qualité musicale de l\'audio de la vidéo unique.';
  }

  @override
  String get playlistJsonFileSizeLabel => 'Taille fichier JSON';

  @override
  String get playlistOneSelectedDialogTitle => 'Sélectionnez une playlist';

  @override
  String get confirmButton => 'Confirmer';

  @override
  String get enclosingPlaylistLabel => 'Playlist englobante';

  @override
  String audioNotMovedFromLocalPlaylistToLocalPlaylist(
      Object audioTitle,
      Object fromPlaylistTitle,
      Object notCopiedOrMovedReason,
      Object toPlaylistTitle) {
    return 'L\'audio \"$audioTitle\" N\'A PAS été déplacé de la playlist locale \"$fromPlaylistTitle\" vers la playlist locale \"$toPlaylistTitle\" $notCopiedOrMovedReason.';
  }

  @override
  String audioNotMovedFromLocalPlaylistToYoutubePlaylist(
      Object audioTitle,
      Object fromPlaylistTitle,
      Object notCopiedOrMovedReason,
      Object toPlaylistTitle) {
    return 'L\'audio \"$audioTitle\" N\'A PAS été déplacé de la playlist locale \"$fromPlaylistTitle\" vers la playlist Youtube \"$toPlaylistTitle\" $notCopiedOrMovedReason.';
  }

  @override
  String audioNotMovedFromYoutubePlaylistToLocalPlaylist(
      Object audioTitle,
      Object fromPlaylistTitle,
      Object notCopiedOrMovedReason,
      Object toPlaylistTitle) {
    return 'L\'audio \"$audioTitle\" N\'A PAS été déplacé de la playlist Youtube \"$fromPlaylistTitle\" vers la playlist locale \"$toPlaylistTitle\" $notCopiedOrMovedReason.';
  }

  @override
  String audioNotMovedFromYoutubePlaylistToYoutubePlaylist(
      Object audioTitle,
      Object fromPlaylistTitle,
      Object notCopiedOrMovedReason,
      Object toPlaylistTitle) {
    return 'L\'audio \"$audioTitle\" N\'A PAS été déplacé de la playlist Youtube \"$fromPlaylistTitle\" vers la playlist Youtube \"$toPlaylistTitle\" $notCopiedOrMovedReason.';
  }

  @override
  String audioNotCopiedFromLocalPlaylistToLocalPlaylist(
      Object audioTitle,
      Object fromPlaylistTitle,
      Object notCopiedOrMovedReason,
      Object toPlaylistTitle) {
    return 'L\'audio \"$audioTitle\" N\'A PAS été copié de la playlist locale \"$fromPlaylistTitle\" vers la playlist locale \"$toPlaylistTitle\" $notCopiedOrMovedReason.';
  }

  @override
  String audioNotCopiedFromLocalPlaylistToYoutubePlaylist(
      Object audioTitle,
      Object fromPlaylistTitle,
      Object notCopiedOrMovedReason,
      Object toPlaylistTitle) {
    return 'L\'audio \"$audioTitle\" N\'A PAS été copié de la playlist locale \"$fromPlaylistTitle\" vers la playlist Youtube \"$toPlaylistTitle\" $notCopiedOrMovedReason.';
  }

  @override
  String audioNotCopiedFromYoutubePlaylistToLocalPlaylist(
      Object audioTitle,
      Object fromPlaylistTitle,
      Object notCopiedOrMovedReason,
      Object toPlaylistTitle) {
    return 'L\'audio \"$audioTitle\" N\'A PAS été copié de la playlist Youtube \"$fromPlaylistTitle\" vers la playlist locale \"$toPlaylistTitle\" $notCopiedOrMovedReason.';
  }

  @override
  String audioNotCopiedFromYoutubePlaylistToYoutubePlaylist(
      Object audioTitle,
      Object fromPlaylistTitle,
      Object notCopiedOrMovedReason,
      Object toPlaylistTitle) {
    return 'L\'audio \"$audioTitle\" N\'A PAS été copié de la playlist Youtube \"$fromPlaylistTitle\" vers la playlist Youtube \"$toPlaylistTitle\" $notCopiedOrMovedReason.';
  }

  @override
  String get author => 'Auteur:';

  @override
  String get authorName => 'Jean-Pierre Schnyder / Suisse';

  @override
  String get aboutAppDescription =>
      'Audio Learn vous permet de télécharger l\'audio de vidéos présentes dans des playlists Youtube ajoutées à l\'application, ou l\'audio d\'une vidéo Youtube individuelle à partir de son lien.\n\nVous pouvez également importer des fichiers audio, comme des livres audio, directement dans l\'application.\n\nEn plus de l\'écoute des fichiers audio, Audio Learn offre la possibilité d\'ajouter des commentaires positionnés à chaque fichier, facilitant ainsi la réécoute des passages les plus intéressants.\n\nEnfin, l\'application permet de trier et filtrer les fichiers audio selon de nombreux critères.\n\nDans la prochaine version, vous pourrez extraire les segments audio commentés pour les partager par email ou via WhatsApp, ou encore les combiner pour créer un nouvel audio récapitulatif.';

  @override
  String get keepAudioEntryInSourcePlaylist =>
      'Conserver les données de l\'audio dans la playlist source';

  @override
  String get keepAudioEntryInSourcePlaylistTooltip =>
      'Conserve les données audio dans le fichier JSON de la playlist d\'origine, même après avoir transféré le fichier audio vers une autre playlist. Cela empêche de retélécharger le fichier audio s\'il n\'existe plus dans son répertoire d\'origine.';

  @override
  String get movedFromPlaylistLabel => 'Déplacé de la playlist';

  @override
  String get movedToPlaylistLabel => 'Déplacé vers la playlist';

  @override
  String get downloadSingleVideoButtonTooltip =>
      'Télécharger l\'audio de la vidéo.\n\nPour télécharger l\'audio d\'une vidéo Youtube, entrez son URL dans le champ \"Lien Youtube\" et cliquez sur le bouton Un. Vous devez ensuite choisir à quelle playlist l\'audio sera ajouté.';

  @override
  String get addPlaylistButtonTooltip =>
      'Ajouter une playlist Youtube ou locale.\n\nPour ajouter une playlist Youtube, entrez son URL dans le champ \"Lien Youtube\" et cliquez sur le bouton Ajout. IMPORTANT: pour qu\'une playlist Youtube puisse être téléchargée par l\'application, sa confidentialité ne doit pas être \"Privée\", mais \"Non répertoriée\" ou \"Publique\".\n\nPour définir une playlist locale, cliquez sur le bouton Ajout alors que le champ \"Lien Youtube\" est vide.';

  @override
  String get stopDownloadingButtonTooltip => 'Stopper le téléchargement ...';

  @override
  String get clearPlaylistUrlOrSearchButtonTooltip =>
      'Effacer le champ \"Lien Youtube ou recherche\".';

  @override
  String get playlistToggleButtonInPlaylistDownloadViewTooltip =>
      'Afficher/masquer les playlists.';

  @override
  String get downloadSelPlaylistsButtonTooltip =>
      'Télécharger les audio\'s de la playlist sélectionnée.';

  @override
  String get audioOneSelectedDialogTitle => 'Sélectionnez un\naudio';

  @override
  String get audioPositionLabel => 'Position audio';

  @override
  String get audioStateLabel => 'État audio';

  @override
  String get audioStatePaused => 'En pause';

  @override
  String get audioStatePlaying => 'En lecture';

  @override
  String get audioStateTerminated => 'Terminé';

  @override
  String get audioStateNotListened => 'Non écouté';

  @override
  String get audioPausedDateTimeLabel => 'Date/heure dernière écoute';

  @override
  String get audioPlaySpeedLabel => 'Vitesse lecture';

  @override
  String get playlistAudioPlaySpeedLabel => 'Vitesse de lecture';

  @override
  String get audioPlayVolumeLabel => 'Volume sonore';

  @override
  String get copiedFromPlaylistLabel => 'Copié de la playlist';

  @override
  String get copiedToPlaylistLabel => 'Copié vers la playlist';

  @override
  String get audioPlayerViewNoCurrentAudio => 'Aucun audio sélectionné';

  @override
  String get deletePlaylist => 'Supprimer la playlist ...';

  @override
  String deleteYoutubePlaylistDialogTitle(Object title) {
    return 'Supprimer la playlist Youtube \"$title\"';
  }

  @override
  String deleteLocalPlaylistDialogTitle(Object title) {
    return 'Supprimer la playlist locale \"$title\"';
  }

  @override
  String deletePlaylistDialogComment(Object audioNumber,
      Object audioCommentsNumber, Object audioPicturesNumber) {
    return 'Suppression de la playlist, de ses $audioNumber fichiers audio, de ses $audioCommentsNumber commentaire(s) audio, de ses $audioPicturesNumber photo(s) audio ainsi que de son fichier JSON et de son répertoire.';
  }

  @override
  String get appBarTitleAudioExtractor => 'Extraire Audio';

  @override
  String get setAudioPlaySpeedDialogTitle => 'Vitesse de lecture';

  @override
  String get setAudioPlaySpeedTooltip =>
      'Définir la vitesse de lecture de l\'audio.';

  @override
  String get exclude => 'Exclure les audio\'s ';

  @override
  String get fullyPlayed => 'terminés';

  @override
  String get audio => 'audio';

  @override
  String increaseAudioVolumeIconButtonTooltip(Object percentValue) {
    return 'Augmenter le volume audio (actuellement $percentValue). Le bouton est désactivé lorsque le volume maximum est atteint.';
  }

  @override
  String decreaseAudioVolumeIconButtonTooltip(Object percentValue) {
    return 'Diminuer le volume audio (actuellement $percentValue). Le bouton est désactivé lorsque le volume minimum est atteint.';
  }

  @override
  String get resetSortFilterOptionsTooltip =>
      'Réinitialiser les paramètres de tri et de filtrage.';

  @override
  String get clickToSetAscendingOrDescendingTooltip =>
      'Cliquez pour définir l\'ordre de tri croissant ou décroissant.';

  @override
  String get and => 'et';

  @override
  String get or => 'ou';

  @override
  String get videoTitleSearchSentenceTextFieldTooltip =>
      'Entrez un mot ou une phrase à rechercher le titre de la vidéo et dans la chaîne Youtube si \'Inclure la chaîne Youtube\' est coché et dans la description de la vidéo si \'Inclure la description\' est coché. ENSUITE, CLIQUEZ SUR LE BOUTON \'+\'.';

  @override
  String get andSentencesTooltip =>
      'Sélectionne les audio\'s qui contiennent tous les mots ou phrases listés.';

  @override
  String get orSentencesTooltip =>
      'Sélectionne les audio\'s qui contienneoptionsnt l\'un des mots ou phrases listés.';

  @override
  String get searchInVideoCompactDescriptionTooltip =>
      'Inclure la description de la vidéo dans la recherche.';

  @override
  String get fullyListened => 'Entièrement écouté';

  @override
  String get partiallyListened => 'Partiellement écouté';

  @override
  String get notListened => 'Non écouté';

  @override
  String saveSortFilterOptionsToPlaylistDialogTitle(
      Object sortFilterParmsName) {
    return 'Sauvegarder les paramètres de tri et de filtre \"$sortFilterParmsName\"';
  }

  @override
  String saveSortFilterOptionsToPlaylist(Object title) {
    return 'Dans la playlist \"$title\"';
  }

  @override
  String get saveButton => 'Sauver';

  @override
  String errorInPlaylistJsonFile(Object filePathName) {
    return 'Le fichier \"$filePathName\" une donnée de définition invalide. Essayez de trouver le probléme afin de le corriger avant de réexéuter l\'opération.';
  }

  @override
  String get updatePlaylistJsonFilesMenuTooltip =>
      'Si un ou plusieurs répertoires de playlists contenant ou non des audio\'s ont été ajoutés ou supprimés manuellement dans le répertoire contenant les playlists de l\'application ou si des audio\'s ont été supprimés manuellement d\'un ou de plusieurs répertoires de playlist, cette fonctionnalité met à jour les fichiers JSON des playlists ainsi que le fichier JSON contenant les paramètres de l\'application afin de refléter les changements dans les écrans de l\'application. Des répertoires de playlist localisés sur un PC peuvent également être copiés dans le répertoire contenant les playlists de l\'application Android. De même, des répertoires de playlist localisés dans Android peuvent également être copiés dans le répertoire contenant les playlists de l\'application PC ...';

  @override
  String get updatePlaylistPlayableAudioListTooltip =>
      'Si des audio\'s ont été supprimés manuellement d\'un ou de plusieurs répertoires de playlist, cette fonctionnalité met à jour les fichiers JSON des playlists afin de refléter les changements dans les écrans de l\'application.';

  @override
  String get audioPlayedInThisOrderTooltip =>
      'Les audio\'s sont joués dans cet ordre. Par défaut, les derniers audio\'s téléchargés sont en bas de la liste.';

  @override
  String get playableAudioDialogSortDescriptionTooltipBottomDownloadBefore =>
      'Les audio en bas ont été téléchargés avant ceux d\'en haut.';

  @override
  String get playableAudioDialogSortDescriptionTooltipBottomDownloadAfter =>
      'Les audio en bas ont été téléchargés après ceux d\'en haut.';

  @override
  String get playableAudioDialogSortDescriptionTooltipBottomUploadBefore =>
      'Les vidéos en bas ont été téléchargées avant celles d\'en haut.';

  @override
  String get playableAudioDialogSortDescriptionTooltipBottomUploadAfter =>
      'Les vidéos en bas ont été téléchargées après celles d\'en haut.';

  @override
  String get playableAudioDialogSortDescriptionTooltipTopDurationBigger =>
      'Les audio en haut ont une durée plus longue que ceux d\'en bas.';

  @override
  String get playableAudioDialogSortDescriptionTooltipTopDurationSmaller =>
      'Les audio en haut ont une durée plus courte que ceux d\'en bas.';

  @override
  String get playableAudioDialogSortDescriptionTooltipTopRemainingDurationBigger =>
      'Les audio en haut ont une durée d\'écoute restante plus longue que ceux d\'en bas.';

  @override
  String get playableAudioDialogSortDescriptionTooltipTopRemainingDurationSmaller =>
      'Les audio en haut ont une durée d\'écoute restante plus courte que ceux d\'en bas.';

  @override
  String
      get playableAudioDialogSortDescriptionTooltipTopLastListenedDatrTimeBigger =>
          'Les audio en haut ont été écoutés plus récemment que ceux d\'en bas.';

  @override
  String
      get playableAudioDialogSortDescriptionTooltipTopLastListenedDatrTimeSmaller =>
          'Les audio en haut ont été écoutés moins récemment que ceux d\'en bas.';

  @override
  String get saveAs => 'Enregistrer sous:';

  @override
  String get sortFilterSaveAsTextFieldTooltip =>
      'Enregistrer les paramètres de tri/filtrage avec le nom spécifié. Les paramètres existants avec le même nom seront mis à jour.';

  @override
  String get applySortFilterToView => 'Appliquer le tri/filtre aux vues:';

  @override
  String get applySortFilterToViewTooltip =>
      'Application du tri/filtrage à une ou deux vues audio. Ceci sera appliqué aux playlists auxquelles ce tri/filtrage est associé.';

  @override
  String get saveSortFilterOptionsTooltip =>
      'Si le nom existe déjà, les paramètres de tri/filtre existantes sont mises à jour avec les paramètres modifiés.';

  @override
  String get applyButton => 'Appliq';

  @override
  String get applySortFilterOptionsTooltip =>
      'Étant donné que le nom est vide, les paramètres de tri/filtrage définis sont appliqués puis ajoutés à l\'historique des tri/filtres.';

  @override
  String get deleteSortFilterOptionsTooltip =>
      'Si ces paramètres de tri/filtre sont appliquées dans une vue, après leur suppression, les paramètres de tri/filtre par défaut seront appliquées à la place.';

  @override
  String get deleteShort => 'Suppr';

  @override
  String get sortFilterParametersDefaultName => 'défaut';

  @override
  String get sortFilterParametersDownloadButtonHint => 'Sélec tri/filtre';

  @override
  String get appBarMenuOpenSettingsDialog => 'Paramètres de l\'application ...';

  @override
  String get appSettingsDialogTitle => 'Paramètres de l\'application';

  @override
  String get setAudioPlaySpeed => 'Définir la vitesse de lecture ...';

  @override
  String get applyToAlreadyDownloadedAudio =>
      'Appliquer aux audio déjà\ntéléchargés ou importés';

  @override
  String get applyToAlreadyDownloadedAudioTooltip =>
      'Appliquer la vitesse de lecture aux audio dans toutes les playlists existantes. Si non défini, l\'appliquer uniquement aux nouvelles playlists ajoutées.';

  @override
  String get applyToAlreadyDownloadedAudioOfCurrentPlaylistTooltip =>
      'Appliquer la vitesse de lecture aux audio\'s de la playlist actuelle. Si non défini, l\'appliquer uniquement aux audio nouvellement téléchargés ou importés.';

  @override
  String get applyToExistingPlaylist => 'Appliquer aux playlists\nexistantes';

  @override
  String get applyToExistingPlaylistTooltip =>
      'Appliquer la vitesse de lecture à toutes les playlists existantes. Si non défini, l\'appliquer uniquement aux nouvelles playlists ajoutées.';

  @override
  String get playlistRootpathLabel => 'Répertoire racine des playlists';

  @override
  String get closeTextButton => 'Fermer';

  @override
  String get helpDialogTitle => 'Aide';

  @override
  String get defaultApplicationHelpTitle => 'Application par défaut';

  @override
  String get defaultApplicationHelpContent =>
      'Si aucune option n\'est sélectionnée, la vitesse de lecture définie s\'appliquera uniquement aux nouvelles playlists créées.';

  @override
  String get modifyingExistingPlaylistsHelpTitle =>
      'Modification des playlists existantes';

  @override
  String get modifyingExistingPlaylistsHelpContent =>
      'En sélectionnant la première case à cocher, toutes les playlists existantes seront configurées pour utiliser la nouvelle vitesse de lecture. Cependant, cette modification affectera uniquement les fichiers audio qui seront téléchargés après l\'activation de cette option.';

  @override
  String get alreadyDownloadedAudiosHelpTitle =>
      'Audio déjà téléchargés ou importés';

  @override
  String get alreadyDownloadedAudiosHelpContent =>
      'La sélection de la deuxième case à cocher permet de modifier la vitesse de lecture pour les fichiers audio déjà présents sur l\'appareil.';

  @override
  String get excludingFutureDownloadsHelpTitle =>
      'Exclusion des futurs téléchargements';

  @override
  String get excludingFutureDownloadsHelpContent =>
      'Si seule la deuxième case est cochée, la vitesse de lecture des audio\'s qui seront téléchargés ultérieurement ne sera pas modifiée dans les playlists existantes. Toutefois, comme mentionné précédemment, les nouvelles playlists utiliseront la vitesse de lecture nouvellement définie pour tous les audio\'s téléchargés.';

  @override
  String get alreadyDownloadedAudiosPlaylistHelpTitle =>
      'Appliquer aux audio\'s déjà téléchargés ou importés';

  @override
  String get alreadyDownloadedAudiosPlaylistHelpContent =>
      'La sélection de cette case à cocher permet de modifier la vitesse de lecture pour les fichiers audio de la playlist déjà présents sur l\'appareil.';

  @override
  String get commentsIconButtonTooltip =>
      'Afficher ou insérer des commentaires à des points spécifiques de l\'audio.';

  @override
  String get commentsDialogTitle => 'Commentaires';

  @override
  String get playlistCommentsDialogTitle =>
      'Commentaires des audio\'s de la playlist';

  @override
  String get addPositionedCommentTooltip =>
      'Ajouter un commentaire à la position actuelle de l\'audio.';

  @override
  String get commentTitle => 'Titre';

  @override
  String get commentText => 'Commentaire';

  @override
  String get commentDialogTitle => 'Commentaire';

  @override
  String get update => 'Mettre à jour';

  @override
  String get deleteCommentConfirnTitle => 'Suppression de commentaire';

  @override
  String deleteCommentConfirnBody(Object title) {
    return 'Supprimer le commentaire \"$title\".';
  }

  @override
  String get commentMenu => 'Commentaires de l\'audio ...';

  @override
  String get tenthOfSecondsCheckboxTooltip =>
      'Activer cette case à cocher pour spécifier la position du commentaire avec une précision au dixième de seconde.';

  @override
  String get setCommentPosition => 'Définir la position';

  @override
  String get commentPosition => 'Position (hh:)mm:ss(.d)';

  @override
  String get commentPositionTooltip =>
      'Effacer le champ de position et sélectionner la case à cocher \"Début\" définira la position de début du commentaire à 0:00. Sélectionner la case à cocher \"Fin\" définira la position de fin du commentaire à la durée totale de l\'audio.';

  @override
  String get commentPositionExplanation =>
      'La position suggérée pour le commentaire correspond au point de lecture actuel de l\'audio. Vous pouvez ajuster cette valeur si nécessaire et choisir à quelle position de commentaire elle doit être appliquée.';

  @override
  String get commentStartPosition => 'Début';

  @override
  String get commentEndPosition => 'Fin';

  @override
  String get updateCommentStartEndPositionTooltip =>
      'Mettre à jour la position de début ou de fin du commentaire.';

  @override
  String noCheckboxSelectedWarning(Object atLeast) {
    return 'Aucune case à cocher sélectionnée. Veuillez en sélectionner ${atLeast}une avant de cliquer sur \'Ok\' ou cliquez sur \'Annuler\' pour quitter.';
  }

  @override
  String get atLeast => 'au moins ';

  @override
  String get commentCreationDateTooltip => 'Date de création du commentaire';

  @override
  String get commentUpdateDateTooltip => 'Date de mise à jour du commentaire';

  @override
  String get playlistCommentMenu => 'Commentaires des audio\'s ...';

  @override
  String get modifyAudioTitle => 'Modifier le titre de l\'audio ...';

  @override
  String invalidLocalPlaylistTitle(Object playlistTitle) {
    return 'Le titre de la playlist locale \"$playlistTitle\" ne peut contenir aucune virgule. Corrigez le titre et rééssayez ...';
  }

  @override
  String invalidYoutubePlaylistTitle(Object playlistTitle) {
    return 'Le titre de la playlist Youtube \"$playlistTitle\" ne peut contenir aucune virgule. Corrigez le titre et rééssayez ...';
  }

  @override
  String setValueToTargetWarning(
      Object invalidValueWarningParam, Object maxMinPossibleValue) {
    return 'La valeur entrée $invalidValueWarningParam ($maxMinPossibleValue). Corrigez la valeur et rééssayez ...';
  }

  @override
  String get invalidValueTooBig => 'excède la valeur maximale';

  @override
  String get invalidValueTooSmall => 'est inférieure à la valeur minimale';

  @override
  String confirmCommentedAudioDeletionTitle(Object audioTitle) {
    return 'Confirmez la suppression de l\'audio commenté \"$audioTitle\"';
  }

  @override
  String confirmCommentedAudioDeletionComment(Object commentNumber) {
    return 'L\'audio contient $commentNumber commentaire(s) qui seront également supprimés. Confirmer la suppression ?';
  }

  @override
  String get commentStartPositionTooltip =>
      'Début du commentaire dans l\'audio.';

  @override
  String get commentEndPositionTooltip => 'Fin du commentaire dans l\'audio.';

  @override
  String get playlistToggleButtonInAudioPlayerViewTooltip =>
      'Afficher/masquer les playlists. Ensuite, cochez une playlist pour sélectionner son audio en cours d\'écoute.';

  @override
  String playlistSelectedSnackBarMessage(Object title) {
    return 'Playlist \"$title\" sélectionnée';
  }

  @override
  String get playlistImportAudioMenu => 'Importer des audio\'s ...';

  @override
  String get playlistImportAudioMenuTooltip =>
      'Importer des audio\'s dans la playlist afin de pouvoir les écouter ainsi qu\'y ajouter des commentaires positionnés.';

  @override
  String get setPlaylistAudioPlaySpeedTooltip =>
      'Définir la vitesse de lecture audio pour les prochains audio téléchargés dans la playlist ainsi que pour les audio\'s existants.';

  @override
  String audioNotImportedToLocalPlaylist(
      Object rejectedImportedAudioFileNames, Object toPlaylistTitle) {
    return 'Le(s) audio(s)\n\n$rejectedImportedAudioFileNames\n\nn\'ont pas été importés vers la playlist locale \"$toPlaylistTitle\" car ils sont déjà présents dans son répertoire.';
  }

  @override
  String audioNotImportedToYoutubePlaylist(
      Object rejectedImportedAudioFileNames, Object toPlaylistTitle) {
    return 'Le(s) audio(s)\n\n$rejectedImportedAudioFileNames\n\nn\'ont pas été importés vers la playlist Youtube \"$toPlaylistTitle\" car ils sont déjà présents dans son répertoire.';
  }

  @override
  String audioImportedToLocalPlaylist(
      Object importedAudioFileNames, Object toPlaylistTitle) {
    return 'Le(s) audio(s)\n\n$importedAudioFileNames\n\nont été importés vers la playlist locale \"$toPlaylistTitle\".';
  }

  @override
  String audioImportedToYoutubePlaylist(
      Object importedAudioFileNames, Object toPlaylistTitle) {
    return 'Le(s) audio(s)\n\n$importedAudioFileNames\n\nont été importés vers la playlist Youtube \"$toPlaylistTitle\".';
  }

  @override
  String get imported => 'importé';

  @override
  String get audioImportedInfoDialogTitle =>
      'Informations sur l\'audio importé';

  @override
  String get audioTitleLabel => 'Titre audio';

  @override
  String get chapterAudioTitleLabel => 'Chapitre audio';

  @override
  String get importedAudioDateTimeLabel => 'Date/heure import';

  @override
  String get importedAudioUrlLabel => 'URL audio importé';

  @override
  String get importedAudioDescriptionLabel => 'Description audio importé';

  @override
  String get sortFilterParametersAppliedName => 'appliqué';

  @override
  String get lastListenedDateTime => 'Date/heure dernière écoute';

  @override
  String get downloadSingleVideoAudioAtMusicQuality =>
      'Télécharger l\'audio de la vidéo à qualité musicale';

  @override
  String get videoTitleNotWrittenInOccidentalLettersWarning =>
      'Le titre original de la vidéo n\'étant pas écrit en caractères occidentaux, le titre audio est vide. Vous pouvez utiliser le menu audio \'Modifier le titre de l\'audio ...\' pour définir un titre valide. Même remarque pour améliorer le nom du fichier audio ...';

  @override
  String renameCommentFileNameAlreadyUsed(Object fileName) {
    return 'Le nom du fichier de commentaires \"$fileName.json\" est déjà utilisé dans le même répertoire de commentaires. Il est donc impossible de renommer le fichier audio avec le nom \"$fileName.mp3\".';
  }

  @override
  String renameFileNameInvalid(Object fileName) {
    return 'Le nom du fichier audio \"$fileName\" n\'a pas d\'extension mp3 et n\'est donc pas valide.';
  }

  @override
  String renameAudioFileConfirmation(Object newFileName, Object oldFileIame) {
    return 'Le fichier audio \"$oldFileIame.mp3\" a été renommé en \"$newFileName.mp3\".';
  }

  @override
  String renameAudioAndCommentFileConfirmation(
      Object newFileName, Object oldFileIame) {
    return 'Le fichier audio \"$oldFileIame.mp3\" a été renommé \"$newFileName.mp3\" ainsi que le fichier de commentaires associé \"$oldFileIame.json\" a été renommé \"$newFileName.json\".';
  }

  @override
  String forScreen(Object screenName) {
    return 'Pour l\'écran \"$screenName\"';
  }

  @override
  String get downloadVideoUrlsFromTextFileInPlaylist =>
      'Télécharger les URL depuis un fichier ...';

  @override
  String get downloadVideoUrlsFromTextFileInPlaylistTooltip =>
      'Téléchargez les audio\'s dans la playlist à partir des URL vidéo répertoriées dans un fichier texte à sélectionner. Le fichier texte doit contenir une URL par ligne.';

  @override
  String downloadAudioFromVideoUrlsInPlaylistTitle(Object title) {
    return 'Télécharger les audio\'s des videos dans la playlist \"$title\"';
  }

  @override
  String downloadAudioFromVideoUrlsInPlaylist(Object number) {
    return 'Téléchargement de $number audio\'s en qualité sélectionnée.';
  }

  @override
  String notRedownloadAudioFilesInPlaylistDirectory(
      Object number, Object playlistTitle) {
    return '$number audio\'s sont déjà contenus dans le répertoire de la playlist cible \"$playlistTitle\" et n\'ont donc pas été re-téléchargés.';
  }

  @override
  String get clickToSetAscendingOrDescendingPlayingOrderTooltip =>
      'Cliquez pour définir l\'ordre de lecture croissant ou décroissant.';

  @override
  String get removeSortFilterAudiosOptionsFromPlaylistMenu =>
      'Eliminer les paramètres tri/filtre de la playlist ...';

  @override
  String removeSortFilterOptionsFromPlaylist(Object title) {
    return 'De la playlist \"$title\"';
  }

  @override
  String removeSortFilterOptionsFromPlaylistDialogTitle(
      Object sortFilterParmsName) {
    return 'Eliminer les paramètres de tri et de filtre \"$sortFilterParmsName\"';
  }

  @override
  String fromScreen(Object screenName) {
    return 'Sur l\'écran \"$screenName\"';
  }

  @override
  String get removeButton => 'Eliminer';

  @override
  String saveSortFilterParmsConfirmation(
      Object sortFilterParmsName, Object playlistTitle, Object forViewMessage) {
    return 'Les paramètres de tri/filtre \"$sortFilterParmsName\" ont été enregistrés dans la playlist \"$playlistTitle\" pour l\'écran(s) \"$forViewMessage\".';
  }

  @override
  String removeSortFilterParmsConfirmation(
      Object sortFilterParmsName, Object playlistTitle, Object forViewMessage) {
    return 'Les paramètres de tri/filtre \"$sortFilterParmsName\" ont été supprimés de la playlist \"$playlistTitle\" sur l\'écran(s) \"$forViewMessage\".';
  }

  @override
  String playlistSortFilterLabel(Object screenName) {
    return '$screenName tri/filtre';
  }

  @override
  String get playlistAudioCommentsLabel => 'Commentaires des audio\'s';

  @override
  String get listenedOn => 'Écouté le';

  @override
  String get remaining => 'Durée restante';

  @override
  String get searchInYoutubeChannelName => 'Inclure la chaîne Youtube';

  @override
  String get searchInYoutubeChannelNameTooltip =>
      'Inclure le nom de la chaîne Youtube dans la recherche.';

  @override
  String get savePlaylistAndCommentsToZipMenu =>
      'Sauver les playlists, commentaires, photos et settings dans un fichier ZIP ...';

  @override
  String get savePlaylistAndCommentsToZipTooltip =>
      'Sauvegarde les playlists, les commentaires et les photos ainsi que le fichier settings.json contenant les paramètres de l\'application dans un fichier ZIP. Seuls les fichiers JSON sont copiés. Les fichiers MP3 et JPG ne sont pas inclus.';

  @override
  String get setYoutubeChannelMenu => 'Youtube channel définition';

  @override
  String confirmYoutubeChannelModifications(
      Object numberOfModifiedDownloadedAudio,
      Object numberOfModifiedPlayableAudio) {
    return 'La chaîne Youtube a été définie dans $numberOfModifiedDownloadedAudio audio téléchargés ainsi que dans $numberOfModifiedPlayableAudio audio écoutables.';
  }

  @override
  String get rewindAudioToStart => 'Repositionner les audio\'s au début';

  @override
  String get rewindAudioToStartTooltip =>
      'Repositionner tous les audio\'s de la playlist au début. Cela est utile si vous souhaitez réécouter tous les audio\'s.';

  @override
  String rewindedPlayableAudioNumber(Object number) {
    return '$number audio\'s de la playlist ont été repositionnés au début et le premier audio écoutable a été selectionné.';
  }

  @override
  String get dateFormat => 'Format de date ...';

  @override
  String get dateFormatSelectionDialogTitle =>
      'Sélectionnez le format de date de l\'application';

  @override
  String get commented => 'Commenté';

  @override
  String get notCommented => 'Non com.';

  @override
  String deleteFilteredAudioConfirmationTitle(
      Object sortFilterParmsName, Object playlistTitle) {
    return 'Supprimer les audio\'s filtrés par le paramètre \"$sortFilterParmsName\" dans la playlist \"$playlistTitle\"';
  }

  @override
  String deleteFilteredAudioConfirmation(Object deleteAudioNumber,
      Object deleteAudioTotalFileSize, Object deleteAudioTotalDuration) {
    return 'Nombre d\'audio\'s à supprimer: $deleteAudioNumber,\nTaille totale correspondante: $deleteAudioTotalFileSize,\nDurée totale correspondante: $deleteAudioTotalDuration.';
  }

  @override
  String get deleteFilteredCommentedAudioWarningTitleOne =>
      'ATTENTION: vous supprimez';

  @override
  String deleteFilteredCommentedAudioWarningTitleTwo(
      Object sortFilterParmsName, Object playlistTitle) {
    return 'des audio\'s COMMENTÉS et non commentés filtrés par le paramètre \"$sortFilterParmsName\" dans la playlist \"$playlistTitle\". Consultez l\'aide pour résoudre le problème.';
  }

  @override
  String deleteFilteredCommentedAudioWarning(
      Object deleteAudioNumber,
      Object deleteCommentedAudioNumber,
      Object deleteAudioTotalFileSize,
      Object deleteAudioTotalDuration) {
    return 'Nombre total d\'audio à supprimer: $deleteAudioNumber,\nNombre d\'audio COMMENTÉS à supprimer: $deleteCommentedAudioNumber,\nTaille totale correspondante: $deleteAudioTotalFileSize,\nDurée totale correspondante: $deleteAudioTotalDuration.';
  }

  @override
  String get commentedAudioDeletionHelpTitle =>
      'Comment créer et utiliser un paramètre de tri/filtrage pour éviter de supprimer les audio\'s commentés ?';

  @override
  String get commentedAudioDeletionHelpContent =>
      'Ce guide explique comment supprimer les audio\'s entièrement écoutés qui ne sont pas commentés.';

  @override
  String get commentedAudioDeletionSolutionHelpTitle =>
      'La solution est de créer un paramètre de tri/filtrage pour sélectionner uniquement les audio\'ss entièrement écoutés et non commentés';

  @override
  String get commentedAudioDeletionSolutionHelpContent =>
      'Dans la boîte de dialogue de définition des paramètres de tri/filtrage, les options de sélection sont représentées par des cases à cocher ...';

  @override
  String get commentedAudioDeletionOpenSFDialogHelpTitle =>
      'Ouvrir la boîte de dialogue de définition des paramètres de tri/filtrage';

  @override
  String get commentedAudioDeletionOpenSFDialogHelpContent =>
      'Cliquez sur l\'icône de menu à droite dans la vue de téléchargement des audio\'s, puis sélectionnez \"Trier/Filtrer audio ...\".';

  @override
  String get commentedAudioDeletionCreateSFParmHelpTitle =>
      'Créer un paramètre de tri/filtrage valide';

  @override
  String get commentedAudioDeletionCreateSFParmHelpContent =>
      'Dans le champ \"Enregistrer sous\", entrez un nom pour le paramètre de tri/filtrage (par exemple, écoutéNonComm). Décochez les cases \"Partiellement écouté\", \"Non écouté\" et \"Commenté\". Puis cliquez sur \"Sauver\".';

  @override
  String get commentedAudioDeletionSelectSFParmHelpTitle =>
      'Une fois enregistré, le paramètre de tri/filtrage est appliqué à la playlist, réduisant la liste affichée des audio\'s.';

  @override
  String get commentedAudioDeletionSelectSFParmHelpContent =>
      'Cliquez sur le bouton \"Playlists\" pour masquer la liste des playlists. Vous verrez votre nouveau paramètre de tri/filtrage sélectionné dans le menu déroulant. Vous pouvez appliquer ce paramètre ou un autre à n\'importe quelle playlist ...';

  @override
  String get commentedAudioDeletionApplyingNewSFParmHelpTitle =>
      'Enfin recliquez sur le bouton \"Playlists\" afin de réafficher la liste des playlists, ouvrez le menu de la playlist source et cliquez sur \"Traiter les audio\'s filtrés ...\" puis sur \"Supprimer les audio\'ss filtrés ...\".';

  @override
  String get commentedAudioDeletionApplyingNewSFParmHelpContent =>
      'Cette fois, puisqu\'un paramètre de tri/filtrage correct est appliqué, aucun avertissement ne sera affiché lors de la suppression des audio\'s sélectionnés non commentés.';

  @override
  String get filteredAudioActions => 'Traiter les audio\'s filtrés ...';

  @override
  String get moveFilteredAudio =>
      'Déplacer les audio\'s filtrés dans une playlist ...';

  @override
  String get copyFilteredAudio =>
      'Copier les audio\'s filtrés dans une playlist ...';

  @override
  String get deleteFilteredAudio => 'Supprimer les audio\'s filtrés ...';

  @override
  String confirmMovedUnmovedAudioNumberFromYoutubeToYoutubePlaylist(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName,
      Object movedAudioNumber,
      Object movedCommentedAudioNumber,
      Object unmovedAudioNumber) {
    return 'En appliquant le filtre \"$sortedFilterParmsName\", de la playlist Youtube \"$sourcePlaylistTitle\" à la playlist Youtube \"$targetPlaylistTitle\", $movedAudioNumber audio(s) ont été déplacé(s) dont $movedCommentedAudioNumber commenté(s), et $unmovedAudioNumber audio(s) n\'ont pu être déplacé(s).';
  }

  @override
  String confirmMovedUnmovedAudioNumberFromYoutubeToLocalPlaylist(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName,
      Object movedAudioNumber,
      Object movedCommentedAudioNumber,
      Object unmovedAudioNumber) {
    return 'En appliquant le filtre \"$sortedFilterParmsName\", de la playlist Youtube \"$sourcePlaylistTitle\" à la playlist locale \"$targetPlaylistTitle\", $movedAudioNumber audio(s) ont été déplacé(s) dont $movedCommentedAudioNumber commenté(s), et $unmovedAudioNumber audio(s) n\'ont pu être déplacé(s).';
  }

  @override
  String confirmMovedUnmovedAudioNumberFromLocalToYoutubePlaylist(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName,
      Object movedAudioNumber,
      Object movedCommentedAudioNumber,
      Object unmovedAudioNumber) {
    return 'En appliquant le filtre \"$sortedFilterParmsName\", de la playlist locale \"$sourcePlaylistTitle\" à la playlist Youtube \"$targetPlaylistTitle\", $movedAudioNumber audio(s) ont été déplacé(s) dont $movedCommentedAudioNumber commenté(s), et $unmovedAudioNumber audio(s) n\'ont pu être déplacé(s).';
  }

  @override
  String confirmMovedUnmovedAudioNumberFromLocalToLocalPlaylist(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName,
      Object movedAudioNumber,
      Object movedCommentedAudioNumber,
      Object unmovedAudioNumber) {
    return 'En appliquant le filtre \"$sortedFilterParmsName\", de la playlist locale \"$sourcePlaylistTitle\" à la playlist locale \"$targetPlaylistTitle\", $movedAudioNumber audio(s) ont été déplacé(s) dont $movedCommentedAudioNumber commenté(s), et $unmovedAudioNumber audio(s) n\'ont pu être déplacé(s).';
  }

  @override
  String confirmCopiedNotCopiedAudioNumberFromYoutubeToYoutubePlaylist(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName,
      Object copiedAudioNumber,
      Object copiedCommentedAudioNumber,
      Object notCopiedAudioNumber) {
    return 'En appliquant le filtre \"$sortedFilterParmsName\", de la playlist Youtube \"$sourcePlaylistTitle\" à la playlist Youtube \"$targetPlaylistTitle\", $copiedAudioNumber audio(s) ont été copié(s) dont $copiedCommentedAudioNumber commenté(s), et $notCopiedAudioNumber audio(s) n\'ont pu être copié(s).';
  }

  @override
  String confirmCopiedNotCopiedAudioNumberFromYoutubeToLocalPlaylist(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName,
      Object copiedAudioNumber,
      Object copiedCommentedAudioNumber,
      Object notCopiedAudioNumber) {
    return 'En appliquant le filtre \"$sortedFilterParmsName\", de la playlist Youtube \"$sourcePlaylistTitle\" à la playlist locale \"$targetPlaylistTitle\", $copiedAudioNumber audio(s) ont été copié(s) dont $copiedCommentedAudioNumber commenté(s), et $notCopiedAudioNumber audio(s) n\'ont pu être copié(s).';
  }

  @override
  String confirmCopiedNotCopiedAudioNumberFromLocalToYoutubePlaylist(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName,
      Object copiedAudioNumber,
      Object copiedCommentedAudioNumber,
      Object notCopiedAudioNumber) {
    return 'En appliquant le filtre \"$sortedFilterParmsName\", de la playlist locale \"$sourcePlaylistTitle\" à la playlist Youtube \"$targetPlaylistTitle\", $copiedAudioNumber audio(s) ont été copié(s) dont $copiedCommentedAudioNumber commenté(s), et $notCopiedAudioNumber audio(s) n\'ont pu être copié(s).';
  }

  @override
  String confirmCopiedNotCopiedAudioNumberFromLocalToLocalPlaylist(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName,
      Object copiedAudioNumber,
      Object copiedCommentedAudioNumber,
      Object notCopiedAudioNumber) {
    return 'En appliquant le filtre \"$sortedFilterParmsName\", de la playlist locale \"$sourcePlaylistTitle\" à la playlist locale \"$targetPlaylistTitle\", $copiedAudioNumber audio(s) ont été copié(s) dont $copiedCommentedAudioNumber commenté(s), et $notCopiedAudioNumber audio(s) n\'ont pu être copié(s).';
  }

  @override
  String defaultSFPNotApplyedToMoveAudioFromYoutubeToYoutubePlaylistWarning(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName) {
    return 'Puisque les paramètres de tri/filtrage \"$sortedFilterParmsName\" sont sélectionnés, aucun audio ne peut être déplacé de la playlist YouTube \"$sourcePlaylistTitle\" vers la playlist YouTube \"$targetPlaylistTitle\". SOLUTION : définissez des paramètres de tri/filtrage et appliquez-les avant d\'exécuter cette opération ...';
  }

  @override
  String defaultSFPNotApplyedToMoveAudioFromYoutubeToLocalPlaylistWarning(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName) {
    return 'Puisque les paramètres de tri/filtrage \"$sortedFilterParmsName\" sont sélectionnés, aucun audio ne peut être déplacé de la playlist YouTube \"$sourcePlaylistTitle\" vers la playlist locale \"$targetPlaylistTitle\". SOLUTION : définissez des paramètres de tri/filtrage et appliquez-les avant d\'exécuter cette opération ...';
  }

  @override
  String defaultSFPNotApplyedToMoveAudioFromLocalToYoutubePlaylistWarning(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName) {
    return 'Puisque les paramètres de tri/filtrage \"$sortedFilterParmsName\" sont sélectionnés, aucun audio ne peut être déplacé de la playlist locale \"$sourcePlaylistTitle\" vers la playlist YouTube \"$targetPlaylistTitle\". SOLUTION : définissez des paramètres de tri/filtrage et appliquez-les avant d\'exécuter cette opération ...';
  }

  @override
  String defaultSFPNotApplyedToMoveAudioFromLocalToLocalPlaylistWarning(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName) {
    return 'Puisque les paramètres de tri/filtrage \"$sortedFilterParmsName\" sont sélectionnés, aucun audio ne peut être déplacé de la playlist locale \"$sourcePlaylistTitle\" vers la playlist locale \"$targetPlaylistTitle\". SOLUTION : définissez des paramètres de tri/filtrage et appliquez-les avant d\'exécuter cette opération ...';
  }

  @override
  String defaultSFPNotApplyedToCopyAudioFromYoutubeToYoutubePlaylistWarning(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName) {
    return 'Puisque les paramètres de tri/filtrage \"$sortedFilterParmsName\" sont sélectionnés, aucun audio ne peut être copié de la playlist YouTube \"$sourcePlaylistTitle\" vers la playlist YouTube \"$targetPlaylistTitle\". SOLUTION : définissez des paramètres de tri/filtrage et appliquez-les avant d\'exécuter cette opération ...';
  }

  @override
  String defaultSFPNotApplyedToCopyAudioFromYoutubeToLocalPlaylistWarning(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName) {
    return 'Puisque les paramètres de tri/filtrage \"$sortedFilterParmsName\" sont sélectionnés, aucun audio ne peut être copié de la playlist YouTube \"$sourcePlaylistTitle\" vers la playlist locale \"$targetPlaylistTitle\". SOLUTION : définissez des paramètres de tri/filtrage et appliquez-les avant d\'exécuter cette opération ...';
  }

  @override
  String defaultSFPNotApplyedToCopyAudioFromLocalToYoutubePlaylistWarning(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName) {
    return 'Puisque les paramètres de tri/filtrage \"$sortedFilterParmsName\" sont sélectionnés, aucun audio ne peut être copié de la playlist locale \"$sourcePlaylistTitle\" vers la playlist YouTube \"$targetPlaylistTitle\". SOLUTION : définissez des paramètres de tri/filtrage et appliquez-les avant d\'exécuter cette opération ...';
  }

  @override
  String defaultSFPNotApplyedToCopyAudioFromLocalToLocalPlaylistWarning(
      Object sourcePlaylistTitle,
      Object targetPlaylistTitle,
      Object sortedFilterParmsName) {
    return 'Puisque les paramètres de tri/filtrage \"$sortedFilterParmsName\" sont sélectionnés, aucun audio ne peut être copié de la playlist locale \"$sourcePlaylistTitle\" vers la playlist locale \"$targetPlaylistTitle\". SOLUTION : définissez des paramètres de tri/filtrage et appliquez-les avant d\'exécuter cette opération ...';
  }

  @override
  String get appBarMenuEnableNextAudioAutoPlay =>
      'Activer la lecture automatique du prochain audio ...';

  @override
  String get batteryParameters => 'Paramètre de la batterie';

  @override
  String get disableBatteryOptimisation =>
      'Afficher le paramétre de la batterie afin d\'en désactiver l\'optimisation, ce qui permet ensuite à l\'application de jouer automatiquement l\'audio suivant dans la playlist courante.\n\nCliquez sur le bouton ci-dessous et ensuite cliquez sur l\'option \"Batterie\" au bas de la liste. Ensuite, sélectionnez \"Non restreinte\", puis sortez des paramètres.';

  @override
  String get openBatteryOptimisationButton =>
      'Afficher le paramétre de la batterie';

  @override
  String deleteSortFilterParmsWarningTitle(
      Object sortFilterParmsName, Object playlistNumber) {
    return 'ATTENTION: vous supprimez le paramètre de tri/filtre \"$sortFilterParmsName\" utilisé dans $playlistNumber playlist(s) listée(s) ci-dessous';
  }

  @override
  String updatingSortFilterParmsWarningTitle(Object sortFilterParmsName) {
    return 'ATTENTION: le paramètre de tri/filtre \"$sortFilterParmsName\" a été modifié. Voulez-vous mettre à jour le paramètre de tri/filtre existant en cliquant sur \"Confirmer\", ou le sauver sous un nom différent ou annuler l\'operation d\'édition, cela en cliquant sur \"Annuler\" ?';
  }

  @override
  String get presentOnlyInFirstTitle => 'Uniquement en version initiale';

  @override
  String get presentOnlyInSecondTitle => 'Uniquement en version modifiée';

  @override
  String get ascendingShort => 'asc';

  @override
  String get descendingShort => 'desc';

  @override
  String get startAudioDownloadDateSortFilterTooltip =>
      'Si seule la date de début du téléchargement est définie, tous les audio\'ss téléchargés à partir de la date définie seront listés.';

  @override
  String get endAudioDownloadDateSortFilterTooltip =>
      'Si seule la date de fin du téléchargement est définie, tous les audio\'ss téléchargés jusqu\'à la date définie seront listés.';

  @override
  String get startVideoUploadDateSortFilterTooltip =>
      'Si seule la date de début de mise en ligne est définie, toutes les vidéos mises en ligne à partir de la date définie seront listées.';

  @override
  String get endVideoUploadDateSortFilterTooltip =>
      'Si seule la date de fin de mise en ligne est définie, toutes les vidéos mises en ligne jusqu\'à la date définie seront listées.';

  @override
  String get startAudioDurationSortFilterTooltip =>
      'Si seule la durée minimale est définie, tous les audio\'ss d\'une durée égale ou supérieure à la valeur définie seront listés.';

  @override
  String get endAudioDurationSortFilterTooltip =>
      'Si seule la durée maximale est définie, tous les audio\'ss d\'une durée égale ou inférieure à la valeur définie seront listés.';

  @override
  String get startAudioFileSizeSortFilterTooltip =>
      'Si seule la taille minimale du fichier est définie, tous les audio\'ss d\'une taille égale ou supérieure à la valeur définie seront listés.';

  @override
  String get endAudioFileSizeSortFilterTooltip =>
      'Si seule la taille maximale du fichier est définie, tous les audio\'ss d\'une taille égale ou inférieure à la valeur définie seront listés.';

  @override
  String get valueInInitialVersionTitle => 'En version initiale';

  @override
  String get valueInModifiedVersionTitle => 'En version modifiée';

  @override
  String get checked => 'coché';

  @override
  String get unchecked => 'décoché';

  @override
  String get emptyDate => 'vide';

  @override
  String get helpMainTitle => 'Aide Audio Learn';

  @override
  String get helpMainIntroduction =>
      'Consultez l\'aide d\'introduction d\'Audio Learn lors de votre première utilisation de l\'application afin de l\'initialiser correctement.';

  @override
  String get helpAudioLearnIntroductionTitle => 'Introduction d\'Audio Learn';

  @override
  String get helpAudioLearnIntroductionSubTitle =>
      'Définir, ajouter et télécharger une playlist YouTube';

  @override
  String get helpLocalPlaylistTitle => 'Playlist Locale';

  @override
  String get helpLocalPlaylistSubTitle =>
      'Définir et utiliser une playlist locale';

  @override
  String get helpPlaylistMenuTitle => 'Menu Playlist';

  @override
  String get helpPlaylistMenuSubTitle => 'Fonctionnalités du menu playlist';

  @override
  String get helpAudioMenuTitle => 'Menu Audio';

  @override
  String get helpAudioMenuSubTitle => 'Fonctionnalités du menu audio';

  @override
  String get addPrivateYoutubePlaylist =>
      'Ajouter une playlist YouTube privée n\'est pas possible car les audio\'s d\'une playlist privée ne peuvent pas être téléchargés. Pour résoudre le problème, éditez la playlist sur YouTube et changez sa confidentialité de \"Privée\" à \"Non répertoriée\" ou à \"Publique\", puis réajoutez-la à l\'application.';

  @override
  String get addAudioPicture => 'Ajouter une photo à l\'audio ...';

  @override
  String get removeAudioPicture => 'Eliminer la photo de l\'audio ...';

  @override
  String savedAppDataToZip(Object filePathName) {
    return 'Fichiers JSON des playlists, des commentaires et des photos ainsi que les paramètres de l\'application sauvagardés dans \"$filePathName\".';
  }

  @override
  String get appDataCouldNotBeSavedToZip =>
      'Les fichiers JSON des playlists, des commentaires et des photos ainsi que les paramètres de l\'application n\'ont pu être sauvagardés dans un ZIP !';

  @override
  String get pictured => 'Avec photo';

  @override
  String get notPictured => 'Sans ph.';

  @override
  String get restorePlaylistAndCommentsFromZipMenu =>
      'Restaurer la/les playlist(s), commentaires, photos et settings depuis un fichier ZIP ...';

  @override
  String get restorePlaylistAndCommentsFromZipTooltip =>
      'En fonction du contenu du fichier ZIP sélectionné, restaure une ou plusieurs playlists, leurs commentaires, photos ainsi que les paramètres de l\'application s\'ils sont inclus dans le fichier ZIP. Les fichiers audio n\'étant pas inclus dans ce fichier, ils ne sont pas restaurés.';

  @override
  String restoredAppDataFromZip(
      Object playlistsNumber,
      Object audiosNumber,
      Object commentsNumber,
      Object updatedCommentNumber,
      Object addedCommentNumber,
      Object picturesNumber,
      Object filePathName) {
    return 'Les fichiers JSON de $playlistsNumber playlists, de $commentsNumber commentaires et de $picturesNumber photos ainsi que $audiosNumber références audio et $addedCommentNumber commentaires ajoutés plus $updatedCommentNumber modifiés et les paramètres de l\'application ont été restaurés depuis \"$filePathName\".';
  }

  @override
  String restoredUniquePlaylistFromZip(
      Object playlistsNumber,
      Object audiosNumber,
      Object commentsNumber,
      Object updatedCommentNumber,
      Object addedCommentNumber,
      Object picturesNumber,
      Object filePathName) {
    return 'Les fichiers JSON de $playlistsNumber playlist sauvegardée individuellement, de $commentsNumber commentaires et de $picturesNumber photos ainsi que $audiosNumber références audio et $addedCommentNumber commentaires ajoutés plus $updatedCommentNumber modifiés ont été restaurés depuis \"$filePathName\".';
  }

  @override
  String get appDataCouldNotBeRestoredFromZip =>
      'Les fichiers JSON des playlists et des commentaires ainsi que les paramètres de l\'application n\'ont pu être restaurés à partir d\'un ZIP !';

  @override
  String get deleteFilteredAudioFromPlaylistAsWell =>
      'Supprimer les audio\'s filtrés de la playlist également ...';

  @override
  String deleteFilteredAudioFromPlaylistAsWellConfirmationTitle(
      Object sortFilterParmsName, Object playlistTitle) {
    return 'Supprimer les audio\'s filtrés par le paramètre \"$sortFilterParmsName\" de la playlist \"$playlistTitle\" également (pourront être re-téléchargés)';
  }

  @override
  String get redownloadFilteredAudio => 'Re-télécharger les audio\'s filtrés';

  @override
  String get redownloadFilteredAudioTooltip =>
      'Les audio\'s filtrés sont re-téléchargés sous leurs noms de fichiers d\'origine.';

  @override
  String redownloadedAudioNumbersConfirmation(Object playlistTitle,
      Object redownloadedAudioNumber, Object notRedownloadedAudioNumber) {
    return '\"$redownloadedAudioNumber\" audio\'s ont été re-téléchargés dans la playlist \"$playlistTitle\". \"$notRedownloadedAudioNumber\" audio\'s n\'ont pas été re-téléchargés du fait qu\'ils sont déjà presents dans le répertoire de la playlist.';
  }

  @override
  String get redownloadDeletedAudio => 'Re-télécharger l\'audio supprimé';

  @override
  String redownloadedAudioConfirmation(
      Object playlistTitle, Object redownloadedAudioTitle) {
    return 'L\'audio \"$redownloadedAudioTitle\" a été re-téléchargé dans la playlist \"$playlistTitle\".';
  }

  @override
  String get playable => 'Jouable';

  @override
  String get notPlayable => 'Non jouable';

  @override
  String audioNotRedownloadedWarning(
      Object playlistTitle, Object redownloadedAudioTitle) {
    return 'L\'audio \"$redownloadedAudioTitle\" N\'A PAS été re-téléchargé dans la playlist \"$playlistTitle\" du fait que le fichier audio est déjà présent dans le répertoire de la playlist.';
  }

  @override
  String get isPlayableLabel => 'Jouable';

  @override
  String get setPlaylistAudioQuality => 'Définir la qualité audio ...';

  @override
  String get setPlaylistAudioQualityTooltip =>
      'La qualité audio sélectionnée sera appliquée aux prochains fichiers audio téléchargés. Si la qualité audio doit être appliquée aux fichiers audio déjà téléchargés, ces fichiers doivent être supprimés \"de la playlist également\" afin qu\'ils puissent être re-téléchargés avec la qualité audio modifiée.';

  @override
  String get setPlaylistAudioQualityDialogTitle =>
      'Qualité audio de la playlist';

  @override
  String get selectAudioQuality => 'Sélectionnez la qualité audio';

  @override
  String audioCopiedOrMovedFromPlaylistToPlaylist(
      Object audioTitle,
      Object yesOrNo,
      Object operationType,
      Object fromPlaylistType,
      Object fromPlaylistTitle,
      Object toPlaylistTitle,
      Object toPlaylistType,
      Object notCopiedOrMovedReason) {
    return 'L\'audio \"$audioTitle\"$yesOrNo$operationType de la playlist $fromPlaylistType \"$fromPlaylistTitle\" vers la playlist $toPlaylistType \"$toPlaylistTitle\"$notCopiedOrMovedReason';
  }

  @override
  String get sinceAbsentFromSourcePlaylist =>
      ' car il n\'est pas présent dans la playlist source.';

  @override
  String get sinceAlreadyPresentInTargetPlaylist =>
      ' car il est déjà présent dans cette playlist.';

  @override
  String audioNotKeptInSourcePlaylist(
      Object audioTitle, Object fromPlaylistTitle) {
    return '.\n\nSUPPRIMEZ L\'AUDIO \"$audioTitle\" DE LA PLAYLIST YOUTUBE \"$fromPlaylistTitle\", SINON L\'AUDIO SERA TÉLÉCHARGÉ À NOUVEAU LORS DU PROCHAIN TÉLÉCHARGEMENT DE LA PLAYLIST.';
  }

  @override
  String get noOperation => ' N\'A PAS été ';

  @override
  String get yesOperation => ' ';

  @override
  String get localPlaylistType => 'locale';

  @override
  String get youtubePlaylistType => 'Youtube';

  @override
  String get movedOperationType => 'a été déplacé';

  @override
  String get copiedOperationType => 'a été copié';

  @override
  String get noOperationMovedOperationType => 'déplacé';

  @override
  String get noOperationCopiedOperationType => 'copié';

  @override
  String savedPictureNumberMessage(Object pictureNumber) {
    return '\n\nEgalement $pictureNumber fichier(s) de photo JPG sauvegardé(s) dans le même répertoire / pictures.';
  }

  @override
  String addedToZipPictureNumberMessage(Object pictureNumber) {
    return '\n\nEgalement $pictureNumber fichier(s) de photo JPG sauvegardé(s) dans le fichier ZIP.';
  }

  @override
  String restoredPictureNumberMessage(Object pictureNumber) {
    return '\n\nEgalement $pictureNumber fichier(s) de photo JPG restauré(s) dans le répertoire \"pictures\" de l\'application.';
  }

  @override
  String get replaceExistingPlaylists => 'Remplacer les playlists\nexistantes';

  @override
  String get playlistRestorationDialogTitle => 'Restauration des playlists';

  @override
  String get playlistRestorationExplanation =>
      'Important: si vous avez apporté des modifications à vos playlists existantes (ajout de fichiers audio, de commentaires ou d\'images) depuis la création de la sauvegarde ZIP, gardez cette case DÉCOCHÉE. Sinon, vos modifications récentes seront remplacées par les versions antérieures contenues dans la sauvegarde.';

  @override
  String get playlistRestorationHelpTitle =>
      'Fonction de restauration des playlists';

  @override
  String get playlistRestorationFirstHelpTitle =>
      'Situation particuliaire où, après avoir restauré les playlists à partir d\'un fichier ZIP, vous avez exécuté la fonction de mise à jour des fichiers playlist JSON en ayant activé la case à cocher \"Effacer les fichiers audio supprimés\". Comme lors de la restauration à partir d\'un fichier ZIP les fichiers audio ne sont pas restaurés, en applicant la fonction de mise à jour avec l\'effacement des fichiers audio activé, les audio\'s ne sont plus disponibles dans l\'application pour être re-téléchargés.';

  @override
  String get playlistRestorationFirstHelpContent =>
      'Pour résoudre ce problème, supprimez les playlists impactées par l\'effacement de leurs audio\'s. Deux moyens de suppression peuvent être utilisés:\n\n1 - Suppression dans l\'application\nChaque playlist dispose d\'un menu. Son dernier élément \"Supprimer la playlist ...\" permet d\'effectuer la suppression.\n\n2 - Suppression manuelle\nSi le nombre de playlists est élevé, il est plus productif de se rendre dans le répertoire de l\'application qui contient les playlists, de sélectionner les playlists à effacer et de supprimer le groupe sélectionné.';

  @override
  String get playlistRestorationSecondHelpTitle =>
      'Une fois les playlists affectées supprimées, restaurez-les à nouveau à partir du fichier ZIP en vous assurant que la case \"Effacer les fichiers audio supprimés\" reste DÉCOCHÉE. Cette étape est cruciale car elle permettra aux fichiers audio de rester disponibles pour le téléchargement après la restauration.';

  @override
  String get playlistJsonFilesUpdateDialogTitle =>
      'Mise à jour des fichiers playlist JSON';

  @override
  String get playlistJsonFilesUpdateExplanation =>
      'Important: si vous avez restauré une sauvegarde ZIP ET ajouté manuellement des playlists par la suite, soyez prudent lors de la mise à jour. Lorsque vous exécutez \"Mettre à jour les fichiers playlist JSON\", les fichiers audio restaurés qui n\'ont pas été re-téléchargés disparaîtront de vos playlists. Pour préserver ces fichiers et conserver la possibilité de les retélécharger, assurez-vous que la case à cocher \"Effacer les fichiers audio supprimés\" reste DÉCOCHÉE avant la mise à jour.';

  @override
  String get removeDeletedAudioFiles => 'Effacer les fichiers audio\nsupprimés';

  @override
  String get updatePlaylistJsonFilesHelpTitle =>
      'Fonction de mise à jour des fichiers playlist JSON';

  @override
  String get updatePlaylistJsonFilesHelpContent =>
      'Note importante: Cette fonction est uniquement nécessaire pour les modifications effectuées HORS application. Les modifications réalisées directement dans l\'application (ajout/suppression de playlists, ajout/importation/suppression de fichiers audio) sont automatiquement prises en compte et ne nécessitent pas d\'utiliser cette fonction de mise à jour.';

  @override
  String get updatePlaylistJsonFilesFirstHelpTitle =>
      'Utilisation de la fonction de mise à jour des fichiers playlist JSON';

  @override
  String get saveUniquePlaylistCommentsAndPicturesToZipMenu =>
      'Sauver la playlist, ses commentaires et ses photos dans un fichier ZIP ...';

  @override
  String get saveUniquePlaylistCommentsAndPicturesToZipTooltip =>
      'Sauvegarde la playlist, les commentaires et les photos de ses audio\'s dans un fichier ZIP. Seuls les fichiers JSON et JPG sont copiés. Les fichiers MP3 ne sont pas inclus.';

  @override
  String savedUniquePlaylistToZip(Object filePathName) {
    return 'Fichiers JSON de la playlist, des commentaires et des photos sauvegardés dans \"$filePathName\".';
  }

  @override
  String get downloadedCheckbox => 'Téléchargé';

  @override
  String get importedCheckbox => 'Importé';

  @override
  String get restoredElementsHelpTitle => 'Description des éléments restaurés';

  @override
  String get restoredElementsHelpContent =>
      'N playlists: nombre de nouveaux fichiers JSON de playlist créés par la restauration.\n\nN commentaires: nombre de nouveaux fichiers JSON de commentaires créés par la restauration. Ceci se produit uniquement si l\'audio commenté n\'avait aucun commentaire avant la restauration. Sinon, le nouveau commentaire est ajouté au fichier JSON de commentaires audio existant.\n\nN photos : nombre de nouveaux fichiers JSON d\'images créés par la restauration. Ceci se produit uniquement si l\'audio illustré n\'avait aucune image avant la restauration. Sinon, la nouvelle image est ajoutée au fichier JSON d\'images audio existant.\n\nN références audio: nombre d\'éléments audio contenus dans un ou plusieurs fichier(s) JSON de playlist créé(s) par la restauration. Si le nombre de playlist restaurée est 0, alors le nombre de référence(s) audio correspond au nombre d\'élément(s) audio ajouté(s) à leur fichier JSON de playlist par la restauration. La restauration n\'ajoute pas de fichiers MP3 puisqu\'aucun MP3 n\'est contenu dans le fichier ZIP. Les audios référencés ajoutés peuvent être téléchargés après la restauration.\n\nN commentaires ajoutés: nombre de commentaires ajoutés par la restauration aux fichiers JSON de commentaires audio existants.\n\nN commentaires modifiés: nombre de commentaires modifiés par la restauration dans les fichiers JSON de commentaires audio existants.';

  @override
  String get playlistInfoDownloadAudio => 'Téléch. audio';

  @override
  String get playlistInfoAudioPlayer => 'Lire audio';

  @override
  String get savePlaylistsAudioMp3FilesToZipMenu =>
      'Sauver les audio\'s MP3 des playlists dans des fichiers ZIP ...';

  @override
  String get savePlaylistsAudioMp3FilesToZipTooltip =>
      'Sauvegarde les fichiers audio MP3 de toutes les playlists dans des fichiers ZIP. Vous pouvez spécifier un filtre de date/heure pour n\'inclure que les fichiers audio téléchargés à partir de cette date.';

  @override
  String get setAudioDownloadFromDateTimeTitle =>
      'Définir la date de téléchargement';

  @override
  String get audioDownloadFromDateTimeAllPlaylistsExplanation =>
      'La date de téléchargement spécifiée par défaut correspond à la date de téléchargement audio la plus ancienne de toutes les playlists. Modifiez cette valeur en spécifiant la date de téléchargement à partir de laquelle les fichiers audio MP3 seront inclus dans le fichier ZIP.';

  @override
  String audioDownloadFromDateTimeLabel(Object selectedAppDateFormat) {
    return 'Date/heure $selectedAppDateFormat hh:mm';
  }

  @override
  String get audioDownloadFromDateTimeAllPlaylistsTooltip =>
      'Puisque la valeur de date/heure actuelle correspond à la valeur de date/heure de l\'audio téléchargé le plus ancien de l\'application, si la date/heure n\'est pas modifiée, tous les fichiers audio MP3 de l\'application seront inclus dans le fichier ZIP.';

  @override
  String get audioDownloadFromDateTimeSinglePlaylistTooltip =>
      'Puisque la valeur de date/heure actuelle correspond à la valeur de date/heure de l\'audio téléchargé le plus ancien de la playlist, si la date/heure n\'est pas modifiée, tous les fichiers audio MP3 de la playlist seront inclus dans le fichier ZIP.';

  @override
  String noAudioMp3WereSavedToZip(Object audioDownloadFromDateTime) {
    return 'Aucun fichier audio MP3 n\'a été sauvegardé dans un fichier ZIP du fait qu\'aucun audio n\'a été téléchargé à partir du $audioDownloadFromDateTime.';
  }

  @override
  String get savePlaylistAudioMp3FilesToZipMenu =>
      'Sauver les audio\'s MP3 de la playlist dans 1 ou n fichier(s) ZIP ...';

  @override
  String get savePlaylistAudioMp3FilesToZipTooltip =>
      'Sauvegarde les fichiers audio MP3 de la playlist dans un ou plusieurs fichier(s) ZIP. Vous pouvez spécifier un filtre de date/heure pour n\'inclure que les fichiers audio téléchargés à partir de cette date.';

  @override
  String get audioDownloadFromDateTimeUniquePlaylistExplanation =>
      'La date de téléchargement spécifiée par défaut correspond à la date de téléchargement audio la plus ancienne de la playlist. Modifiez cette valeur en spécifiant la date de téléchargement à partir de laquelle les fichiers audio MP3 seront inclus dans le fichier ZIP.';

  @override
  String get audioDownloadFromDateTimeUniquePlaylistTooltip =>
      'Puisque la valeur de date/heure actuelle correspond à la valeur de date/heure de l\'audio téléchargé le plus ancien de la playlist, si la date/heure n\'est pas modifiée, tous les fichiers audio MP3 de la playlist seront inclus dans le fichier ZIP.';

  @override
  String invalidDateFormatErrorMessage(Object dateStr) {
    return '$dateStr ne respecte pas le format date ou date heure:minute.';
  }

  @override
  String savingUniquePlaylistAudioMp3(Object playlistTitle) {
    return 'Sauvegarde des fichiers audio de la playlist $playlistTitle ...';
  }

  @override
  String get savingMultiplePlaylistsAudioMp3 =>
      'Sauvegarde des fichiers audio de multiples playlists ...';

  @override
  String savingApproximativeTime(Object saveTime, Object zipNumber) {
    return 'Peut prendre approxim. $saveTime. Nb ZIP: $zipNumber';
  }

  @override
  String get savingUpToHalfHour =>
      'Patience, cela peut prendre 10 à 30 minutes, voir plus ...';

  @override
  String savingAudioToZipTime(Object evaluatedSaveTime) {
    return 'La sauvegarde des fichiers audio MP3 dans un fichier ZIP va nécessiter cette durée estimée (hh:mm:ss): $evaluatedSaveTime.';
  }

  @override
  String get savingAudioToZipTimeTitle =>
      'Estimation de la durée de sauvegarde';

  @override
  String correctedSavedUniquePlaylistAudioMp3ToZip(
      Object audioDownloadFromDateTime,
      Object savedAudioNumber,
      Object savedAudioTotalFileSize,
      Object savedAudioTotalDuration,
      Object saveOperationRealDuration,
      Object bytesNumberSavedPerSecond,
      Object filePathName,
      Object zipFilesNumber,
      Object zipTooLargeFileInfo) {
    return 'Enregistré dans des ZIP\'s tous les fichiers audio MP3 de la playlist unique téléchargés depuis le $audioDownloadFromDateTime.\n\nNombre total d\'audios sauvegardés: $savedAudioNumber, taille totale: $savedAudioTotalFileSize et durée totale: $savedAudioTotalDuration.\n\nDurée réelle de l\'opération de sauvegarde: $saveOperationRealDuration, nombre de bytes sauvés par seconde: $bytesNumberSavedPerSecond, nombre de fichier(s) ZIP créé(s): $zipFilesNumber.\n\nFichier ZIP: \"$filePathName\".$zipTooLargeFileInfo';
  }

  @override
  String correctedSavedMultiplePlaylistsAudioMp3ToZip(
      Object audioDownloadFromDateTime,
      Object savedAudioNumber,
      Object savedAudioTotalFileSize,
      Object savedAudioTotalDuration,
      Object saveOperationRealDuration,
      Object bytesNumberSavedPerSecond,
      Object filePathName,
      Object zipFilesNumber,
      Object zipTooLargeFileInfo) {
    return 'Enregistré dans le ZIP tous les fichiers audio MP3 des playlists téléchargés depuis le $audioDownloadFromDateTime.\n\nNombre total d\'audios sauvegardés: $savedAudioNumber, taille totale: $savedAudioTotalFileSize et durée totale: $savedAudioTotalDuration.\n\nDurée réelle de l\'opération de sauvegarde: $saveOperationRealDuration, nombre de bytes sauvés par seconde: $bytesNumberSavedPerSecond, nombre de fichier(s) ZIP créé(s): $zipFilesNumber.\n\nFichier ZIP: \"$filePathName\"$zipTooLargeFileInfo';
  }

  @override
  String get restorePlaylistsAudioMp3FilesFromZipMenu =>
      'Restaurer les audio\'s MP3 des playlists depuis un fichier ZIP ...';

  @override
  String get restorePlaylistsAudioMp3FilesFromZipTooltip =>
      'Restaure les audio\'s MP3 des playlists à partir d\'un fichier ZIP préalablement sauvé. Seuls les fichiers MP3 qui correspondent aux audio\'s listés dans les playlists et qui ne sont pas déjà présents dans ces playlists sont restaurés.';

  @override
  String get audioMp3RestorationDialogTitle => 'Restauration des MP3';

  @override
  String get audioMp3RestorationExplanation =>
      'Seuls les fichiers MP3 qui correspondent aux audio\'s listés dans les playlists et qui ne sont pas déjà présents dans les playlists sont restaurés.';

  @override
  String get restorePlaylistAudioMp3FilesFromZipMenu =>
      'Restaurer les audio\'s MP3 de la playlist depuis un fichier ZIP ...';

  @override
  String get restorePlaylistAudioMp3FilesFromZipTooltip =>
      'Restaure les audio\'s MP3 de la playlist à partir d\'un fichier ZIP préalablement sauvé. Seuls les fichiers MP3 qui correspondent aux audio\'s listés dans la playlist et qui ne sont pas déjà présents dans cette playlist sont restaurés.';

  @override
  String get audioMp3UniquePlaylistRestorationDialogTitle =>
      'Restauration des MP3';

  @override
  String get audioMp3UniquePlaylistRestorationExplanation =>
      'Seuls les fichiers MP3 qui correspondent aux audio\'s listés dans la playlist et qui ne sont pas déjà présents dans cette playlist sont restaurés.';

  @override
  String playlistInvalidRootPathWarning(
      Object playlistRootPath, Object wrongName) {
    return 'Le répertoire défini \"$playlistRootPath\" est invalide du fait que le nom du répertoire final \'$wrongName\' devant contenir les playlists est différent de \'playlists\'. Veuillez renommer le nouveau répertoire contenant les playlists et rééffectuer son changement';
  }

  @override
  String restoringUniquePlaylistAudioMp3(Object playlistTitle) {
    return 'Restoration des fichiers audio de la playlist $playlistTitle ...';
  }

  @override
  String get restoringMultiplePlaylistsAudioMp3 =>
      'Restoration des fichiers audio de multiples playlists ...';

  @override
  String get playlistsMp3RestorationHelpTitle =>
      'Fonction de restauration MP3 des playlists';

  @override
  String get playlistsMp3RestorationHelpContent =>
      'Cette fonction est utile dans la situation où les playlists ont été restaurées depuis un fichier ZIP qui ne contenait que les fichiers JSON des playlists, des commentaires et des photos et donc ne contenait pas les fichiers audio MP3.';

  @override
  String get uniquePlaylistMp3RestorationHelpTitle =>
      'Fonction de restauration MP3 de la playlist';

  @override
  String get uniquePlaylistMp3RestorationHelpContent =>
      'Cette fonction est utile dans la situation où la playlist a été restaurée depuis un fichier ZIP qui ne contenait que les fichiers JSON de la playlist, des commentaires et des photos et donc ne contenait pas les fichiers audio MP3.';

  @override
  String get playlistsMp3SaveHelpTitle =>
      'Fonction de sauvegarde MP3 des playlists';

  @override
  String playlistsMp3SaveHelpContent(
      Object dateOne, Object dateThree, Object dateTwo) {
    return 'Si vous avez déjà exécuté cette fonctionnalité de sauvegarde MP3 il y a quelques semaines, l\'exemple suivant vous aidera à comprendre le résultat de la nouvelle exécution de sauvegarde MP3 des playlists. Considérez que le premier fichier ZIP MP3 sauvegardé est nommé audioLearn_mp3_from_2023-05-17_07_03_50_on_2025-06-15_11_59_38.zip. Maintenant, le $dateOne à 10:00 vous effectuez une nouvelle sauvegarde MP3 des playlists en définissant la date de téléchargement audio la plus ancienne au $dateTwo, c\'est-à-dire la date à laquelle le fichier ZIP MP3 précédent a été créé. Mais si le fichier ZIP nouvellement créé est nommé audioLearn_mp3_from_2025-06-20_09_25_34_on_2025-07-27_16_23_32.zip et non audioLearn_mp3_from_2025-06-15_on_2025-07-27_16_23_32.zip, la raison est que l\'audio téléchargé le plus ancien après le $dateTwo a été téléchargé le $dateThree 09:25:34.';
  }

  @override
  String get uniquePlaylistMp3SaveHelpTitle =>
      'Fonction de sauvegarde MP3 de la playlist';

  @override
  String uniquePlaylistMp3SaveHelpContent(
      Object dateOne, Object dateThree, Object dateTwo) {
    return 'Si vous avez déjà exécuté cette fonctionnalité de sauvegarde MP3 il y a quelques semaines, l\'exemple suivant vous aidera à comprendre le résultat de la nouvelle exécution de sauvegarde MP3 de la playlist. Considérez que le premier fichier ZIP MP3 sauvegardé est nommé audioLearn_mp3_from_2023-05-17_07_03_50_on_2025-06-15_11_59_38.zip. Maintenant, le $dateOne à 10:00 vous effectuez une nouvelle sauvegarde MP3 de la playlist en définissant la date de téléchargement audio la plus ancienne au $dateTwo, c\'est-à-dire la date à laquelle le fichier ZIP MP3 précédent a été créé. Mais si le fichier ZIP nouvellement créé est nommé audioLearn_mp3_from_2025-06-20_09_25_34_on_2025-07-27_16_23_32.zip et non audioLearn_mp3_from_2025-06-15_on_2025-07-27_16_23_32.zip, la raison est que l\'audio téléchargé le plus ancien après le $dateTwo a été téléchargé le $dateThree 09:25:34.';
  }

  @override
  String get insufficientStorageSpace =>
      'Espace de stockage insuffisant détecté lors de la sélection du fichier ZIP contenant les MP3\'s.';

  @override
  String get pathError => 'Échec de la récupération du chemin de fichier.';

  @override
  String get androidStorageAccessErrorMessage =>
      'Impossible d\'accéder au stockage externe Android.';

  @override
  String get zipTooLargeFileInfoLabel =>
      'Ces fichiers sont trop volumineux pour être inclus dans les fichiers ZIP MP3 et n\'ont donc pas été sauvegardés:\n';

  @override
  String get mp3ZipFileSizeLimitInMbLabel =>
      'Taille maximale en Mo des fichiers ZIP';

  @override
  String get mp3ZipFileSizeLimitInMbTooltip =>
      'Taille maximale en Mo pour chaque fichier ZIP lors de la sauvegarde des fichiers audio MP3. Sur les appareils Android, si cette limite est trop élevée, l\'opération de sauvegarde échouera en raison de contraintes de mémoire. Plusieurs fichiers ZIP seront créés automatiquement si le contenu total dépasse cette limite.';

  @override
  String get zipTooLargeOneFileInfoLabel =>
      'Ce fichier est trop volumineux pour être inclu dans un fichier ZIP MP3 et n\'a donc pas été sauvegardé:\n';

  @override
  String androidZipFileCreationError(Object zipFileName, Object zipFileSize) {
    return 'Erreur lors de la sauvegarde du fichier ZIP $zipFileName. Ceci est dû à sa taille trop importante: $zipFileSize.\n\nSolution: dans les paramètres de l\'application, réduisez la taille maximale des fichiers ZIP et réexécutez la sauvegarde des MP3 dans des fichiers ZIP.';
  }

  @override
  String get obtainMostRecentAudioDownloadDateTimeMenu =>
      'Obtenir la date de téléchargement audio la plus récente';

  @override
  String get obtainMostRecentAudioDownloadDateTimeTooltip =>
      'Trouve la date de téléchargement audio la plus récente parmi toutes les playlists. Utilisez cette date lors de la création de sauvegardes ZIP avec le menu \'Sauver les audio\'s MP3 des playlists dans des fichiers ZIP\' pour ne capturer que les fichiers audio les plus récents afin de les restaurer dans cette version de l\'application.';

  @override
  String get displayNewestAudioDownloadDateTimeTitle =>
      'Date récente de téléchargement audio';

  @override
  String displayNewestAudioDownloadDateTime(
      Object newestAudioDownloadDateTime) {
    return 'Ceci est la date/heure de téléchargement audio la plus récente: $newestAudioDownloadDateTime.';
  }

  @override
  String get audioTitleModificationHelpTitle =>
      'Utilisation de la modification du titre de l\'audio';

  @override
  String get audioTitleModificationHelpContent =>
      'Par exemple, si dans une playlist on dispose de trois audio\'s qui ont été téléchargés dans cet ordre:\n  dernier\n  premier\n  deuxième\net que l\'on souhaite écouter dans l\'ordre en rapport avec leur titre, il est utile de renommer les titres de cette manière:\n  3-dernier\n  1-premier\n  2-deuxième\n\nEnsuite il faut cliquer sur le menu \"Trier/filtrer audio ...\" afin de définir un tri que l\'on nomme et qui trie les audios selon leur titre.\n\nUne fois le dialogue \"Paramètres tri et filtre\" ouvert, définir le nom du filtre dans le champ \"Enregistrer sous:\" et ouvrir la liste \"Trier par:\". Sélectionner \"Titre audio\" et ensuite supprimer \"Date téléch audio\". Enfin, cliquer sur \"Sauver\".\n\nUne fois que ce tri est défini, on vérifie qu\'il est sélectionné et l\'on utilise le menu \"Sauvegarder les paramètres tri/filtre dans la playlist ...\" en sélectionnant l\'écran pour lequel le tri sera appliqué. Ainsi, les audios seront joués dans l\'ordre dans lequel on souhaite les écouter.';

  @override
  String get playlistConvertTextToAudioMenu =>
      'Convertir un texte en audio ...';

  @override
  String get playlistConvertTextToAudioMenuTooltip =>
      'Convertir un texte en audio écoutable qui est ajouté à la playlist. Comme pour les autres audio\'s, il sera possible d\'ajouter des commentaires positionnés ou une image à cet audio.';

  @override
  String get convertTextToAudioDialogTitle => 'Convertir le texte en audio';

  @override
  String textToConvert(Object brace_1) {
    return 'Texte à convertir, $brace_1 = silence';
  }

  @override
  String get textToConvertTextFieldTooltip =>
      'Entrer le texte à convertir en un audio ajouté à la playlist. L\'audio est généré en utilisant la voix sélectionée. Insérer une ou plusieures accolade(s) afin d\'ajouter à cet endroit une ou plusieures seconde(s) de silence.';

  @override
  String get textToConvertTextFieldHint => 'Entrez votre texte ici ...';

  @override
  String get conversionVoiceSelection => 'Sélection de la voix:';

  @override
  String get masculineVoice => 'masculine';

  @override
  String get femineVoice => 'féminine';

  @override
  String get listenTextButton => 'Écouter';

  @override
  String get listenTextButtonTooltip =>
      'Écoute du texte à convertir avec la voix sélectionnée.';

  @override
  String get createAudioFileButton => 'Créer MP3';

  @override
  String get createAudioFileButtonTooltip =>
      'Création du fichier audio en utilisant la voix sélectionnée et ajout de l\'audio à la playlist.';

  @override
  String get stopListeningTextButton => 'Stopper';

  @override
  String get stopListeningTextButtonTooltip =>
      'Arrêter la lecture utilisant la voix sélectionnée.';

  @override
  String get mp3FileName => 'Nom du fichier MP3';

  @override
  String get enterMp3FileName => 'Entrer le nom du fichier MP3';

  @override
  String get myMp3FileName => 'nom de fichier';

  @override
  String get createMP3 => 'Créer MP3';

  @override
  String audioImportedFromTextToSpeechToLocalPlaylist(
      Object importedAudioFileNames, Object toPlaylistTitle) {
    return 'L\'audio créé par la conversion de texte en MP3\n\n$importedAudioFileNames\n\na été ajouté à la playlist locale \"$toPlaylistTitle\".';
  }

  @override
  String audioImportedFromTextToSpeechToYoutubePlaylist(
      Object importedAudioFileNames, Object toPlaylistTitle) {
    return 'L\'audio créé par la conversion de texte en MP3\n\n$importedAudioFileNames\n\na été ajouté à la playlist Youtube \"$toPlaylistTitle\".';
  }

  @override
  String replaceExistingAudioInPlaylist(Object fileName, Object playlistTitle) {
    return 'Le fichier \"$fileName.mp3\" existe déjà dans la playlist \"$playlistTitle\". Si vous voulez le remplacer par la nouvelle version, cliquez sur le bouton \"Confirmer\". Sinon, cliquez sur le bouton \"Annuler\" et vous pourrez définir un nom de fichier différent.';
  }

  @override
  String get speech => 'Paroles';

  @override
  String convertTextToAudioHelpTitle(Object brace_1) {
    return 'Utilisation du caractère $brace_1';
  }

  @override
  String convertTextToAudioHelpContent(
      Object brace_1, Object brace_2, Object brace_3) {
    return '${brace_1}Un texte avec un caractère qui introduit un silence de 1 seconde. Au dàbut du texte, 2 secondes de silence sont ajoutées. $brace_2 Avant cette phrase, 4 secondes de silence sont introduites. $brace_3 Ici, une seconde de silence. Ce caractère a été choisi du fait qu\'il n\'est pas normalement utilisé dans les écritures.';
  }

  @override
  String get textToSpeech => 'converti';

  @override
  String get audioTextToSpeechInfoDialogTitle =>
      'Informations sur l\'audio converti';

  @override
  String get convertedAudioDateTimeLabel => 'Date//heure prem conversion';

  @override
  String get convertedAudioUrlLabel => 'URL audio converti';

  @override
  String get convertedAudioDescriptionLabel => 'Description audio converti';
}
