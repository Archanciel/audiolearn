/// Contains the correctly translated title and content of
/// a help item.
class HelpItem {
  final String helpTitle;
  final String helpContent;
  final bool displayHelpItemNumber;

  HelpItem({
    required this.helpTitle,
    required this.helpContent,
    this.displayHelpItemNumber = true,
  });
}
