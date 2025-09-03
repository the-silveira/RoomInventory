import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A customizable Cupertino-style navigation bar with optional add button.
///
/// The [CustomNavigationBar] widget provides a reusable navigation bar component
/// that follows iOS design guidelines while offering flexible configuration options.
/// It can be used for both list views (with add button) and detail views.
///
/// This widget implements [ObstructingPreferredSizeWidget] to ensure proper
/// layout behavior in Cupertino-style applications.
///
/// ## Features:
/// - **Cupertino Design**: Follows iOS navigation bar design patterns
/// - **Theme-Aware**: Automatically adapts to light/dark theme changes
/// - **Flexible Configuration**: Optional previous page title and add button
/// - **Proper Layout**: Implements preferred size and obstruction behavior
///
/// ## Usage Examples:
/// ```dart
/// // Navigation bar with add button for list pages
/// CustomNavigationBar(
///   title: 'Events',
///   previousPageTitle: 'Inventory',
///   onAddPressed: () {
///     Navigator.push(context, MaterialPageRoute(builder: (_) => AddEventPage()));
///   },
/// )
///
/// // Navigation bar without add button for detail pages
/// CustomNavigationBar(
///   title: 'Event Details',
///   previousPageTitle: 'Events',
/// )
/// ```
///
/// ## Theme Adaptation:
/// - Background color uses [ThemeData.colorScheme.surface]
/// - Text color uses [ThemeData.colorScheme.onSurface]
/// - Icon color uses [ThemeData.colorScheme.primary]
/// - Automatically adapts to light/dark theme changes
///
/// ## Platform Consistency:
/// Maintains iOS design patterns including:
/// - Cupertino-style back button with previous page title
/// - Centered title text
/// - Standard Cupertino add icon
/// - Proper spacing and padding
class CustomNavigationBar extends StatelessWidget
    implements ObstructingPreferredSizeWidget {
  /// The title of the previous page for the back button.
  ///
  /// If provided, this text appears next to the back arrow and should match
  /// the title of the page that will be shown when navigating back.
  /// If null, only the back arrow will be displayed without text.
  final String? previousPageTitle;

  /// The primary title displayed in the center of the navigation bar.
  ///
  /// This should clearly describe the current page's content or purpose.
  /// Examples: "Events", "Item Details", "Settings"
  final String title;

  /// Callback function triggered when the add button is pressed.
  ///
  /// This is typically used to navigate to a form page for creating new items.
  /// If null, the add button will not be displayed in the navigation bar.
  final VoidCallback? onAddPressed;

  /// Creates a customizable Cupertino-style navigation bar.
  ///
  /// [title]: The central title text (required)
  /// [previousPageTitle]: Optional text for the back button label
  /// [onAddPressed]: Optional callback for the add button action
  ///
  /// ## Example:
  /// ```dart
  /// CustomNavigationBar(
  ///   title: 'My Items',
  ///   previousPageTitle: 'Home',
  ///   onAddPressed: _navigateToAddPage,
  /// )
  /// ```
  const CustomNavigationBar({
    Key? key,
    required this.title,
    this.previousPageTitle,
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
      trailing: onAddPressed != null
          ? CupertinoButton(
              padding:
                  EdgeInsets.zero, // Remove default padding for compact design
              onPressed: onAddPressed,
              child: Icon(
                CupertinoIcons.add,
                color: Theme.of(context).colorScheme.primary,
                semanticLabel: 'Add new item', // Accessibility label
              ),
            )
          : null,
    );
  }

  /// The preferred size of the navigation bar.
  ///
  /// Returns a fixed height equal to the standard toolbar height [kToolbarHeight].
  /// This ensures consistent spacing and layout with other app bars throughout the app.
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  /// Determines whether this widget should fully obstruct the content behind it.
  ///
  /// Returns true to ensure the navigation bar properly overlays content
  /// and maintains Cupertino-style layout behavior with translucent effects.
  @override
  bool shouldFullyObstruct(BuildContext context) {
    return true;
  }
}
