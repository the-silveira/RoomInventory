import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A custom Cupertino-style navigation bar with a save button for form pages.
///
/// The [AddNavigationBar] widget provides a consistent navigation bar design
/// for pages that involve adding or editing data. It includes:
/// - A title in the middle
/// - A back button with previous page title
/// - A trailing "Save" button for form submission
///
/// This widget implements [ObstructingPreferredSizeWidget] to ensure proper
/// layout behavior in Cupertino-style applications.
///
/// ## Features:
/// - **Cupertino Design**: Follows iOS design guidelines
/// - **Theme-Aware**: Adapts to light/dark theme changes
/// - **Form Integration**: Includes save button for form submissions
/// - **Proper Layout**: Implements preferred size and obstruction behavior
///
/// ## Usage:
/// ```dart
/// AddNavigationBar(
///   title: 'New Event',
///   previousPageTitle: 'Events',
///   onAddPressed: () {
///     // Handle save logic
///     _saveForm();
///   },
/// )
/// ```
///
/// ## Example Integration:
/// ```dart
/// Scaffold(
///   appBar: AddNavigationBar(
///     title: 'Edit Item',
///     previousPageTitle: 'Inventory',
///     onAddPressed: _submitForm,
///   ),
///   body: MyFormContent(),
/// )
/// ```
///
/// ## Theme Adaptation:
/// - Background color uses [ThemeData.colorScheme.surface]
/// - Text color uses [ThemeData.colorScheme.onSurface]
/// - Automatically adapts to light/dark theme changes
class AddNavigationBar extends StatelessWidget
    implements ObstructingPreferredSizeWidget {
  /// The title displayed in the center of the navigation bar.
  ///
  /// Typically describes the current page or action, such as "New Event"
  /// or "Edit Item".
  final String title;

  /// The title of the previous page for the back button.
  ///
  /// This text appears next to the back arrow and should match the title
  /// of the page that will be shown when navigating back.
  final String previousPageTitle;

  /// Callback function triggered when the save button is pressed.
  ///
  /// This is typically used to submit forms, save data, or perform
  /// the primary action of the page.
  ///
  /// If null, the save button will be disabled.
  final VoidCallback? onAddPressed;

  /// Creates a custom navigation bar for add/edit pages.
  ///
  /// [title]: The central title text
  /// [previousPageTitle]: The back button label text
  /// [onAddPressed]: Optional callback for the save button action
  const AddNavigationBar({
    Key? key,
    required this.title,
    required this.previousPageTitle,
    this.onAddPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(
      middle: Text(
        title,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      previousPageTitle: previousPageTitle,
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        minSize: 0,
        child: Text(
          'Save',
          style: TextStyle(
            color: onAddPressed != null
                ? CupertinoColors.activeBlue
                : CupertinoColors.tertiaryLabel,
          ),
        ),
        onPressed: onAddPressed,
      ),
    );
  }

  /// The preferred size of the navigation bar.
  ///
  /// Returns a fixed height equal to the standard toolbar height [kToolbarHeight].
  /// This ensures consistent spacing and layout with other app bars.
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  /// Determines whether this widget should fully obstruct the content behind it.
  ///
  /// Returns true to ensure the navigation bar properly overlays content
  /// and maintains Cupertino-style layout behavior.
  @override
  bool shouldFullyObstruct(BuildContext context) {
    return true;
  }
}
