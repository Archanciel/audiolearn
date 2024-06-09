import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../constants.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/language_provider_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';

enum AppBarPopupMenu { en, fr, about }

/// This widget is the popup menu button widget which is displayed
/// on the right side of the application appbar. It contains menu items
/// to change the application language and to display the about dialog.
///
/// The menu items are defined in the enum AppBarPopupMenu. Up to now
/// the popup menu widget is identical for all screens.
class AppBarApplicationRightPopupMenuWidget extends StatelessWidget {
  const AppBarApplicationRightPopupMenuWidget({
    super.key,
    required this.themeProvider,
  });

  final ThemeProviderVM themeProvider;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppBarPopupMenu>(
      key: const Key('appBarRightPopupMenu'),
      onSelected: (AppBarPopupMenu value) {
        switch (value) {
          case AppBarPopupMenu.en:
            Locale newLocale = const Locale('en');
            AppLocalizations.delegate.load(newLocale).then((localizations) {
              Provider.of<LanguageProviderVM>(context, listen: false)
                  .changeLocale(newLocale);
            });
            break;
          case AppBarPopupMenu.fr:
            Locale newLocale = const Locale('fr');
            AppLocalizations.delegate.load(newLocale).then((localizations) {
              Provider.of<LanguageProviderVM>(context, listen: false)
                  .changeLocale(newLocale);
            });
            break;
          case AppBarPopupMenu.about:
            showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                bool isDarkTheme = themeProvider.currentTheme == AppTheme.dark;
                AboutDialog aboutDialog = AboutDialog(
                  applicationName: kApplicationName,
                  applicationVersion: kApplicationVersion,
                  applicationIcon:
                      Image.asset('assets/images/ic_launcher_cleaner_72.png'),
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context)!.author,
                      style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.black),
                    ),
                    Text(
                      AppLocalizations.of(context)!.authorName,
                      style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.black),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        AppLocalizations.of(context)!.aboutAppDescription,
                        style: TextStyle(
                            color: isDarkTheme ? Colors.white : Colors.black),
                      ),
                    ),
                  ],
                );
                return isDarkTheme
                    ? Theme(
                        // Theme is required in dark mode in order
                        // to improve the text color of the application
                        // version so that it is better visible (white
                        // instead of blue)
                        data: Theme.of(context).copyWith(
                          textTheme: const TextTheme(
                            bodyMedium: TextStyle(
                                color:
                                    Colors.white), // or another color you need
                          ),
                        ),
                        child: aboutDialog,
                      )
                    : aboutDialog;
              },
            );
            break;
          default:
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<AppBarPopupMenu>(
            key: const Key('appBarMenuEnglish'),
            value: AppBarPopupMenu.en,
            child: Text(AppLocalizations.of(context)!
                .translate(AppLocalizations.of(context)!.english)),
          ),
          PopupMenuItem<AppBarPopupMenu>(
            key: const Key('appBarMenuFrench'),
            value: AppBarPopupMenu.fr,
            child: Text(AppLocalizations.of(context)!
                .translate(AppLocalizations.of(context)!.french)),
          ),
          PopupMenuItem<AppBarPopupMenu>(
            key: const Key('appBarMenuAbout'),
            value: AppBarPopupMenu.about,
            child: Text(AppLocalizations.of(context)!.about),
          ),
        ];
      },
    );
  }
}
