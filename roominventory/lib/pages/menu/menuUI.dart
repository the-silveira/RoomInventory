import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/pages/menu/menuController.dart';
import 'package:roominventory/pages/menu/menuWidgets.dart';

/// The main menu page of the Room Inventory application.
///
/// This page serves as the central navigation hub, providing access to various
/// sections of the application including inventory management, events, places,
/// DMX controls, and settings. It uses a Cupertino-style interface with a
/// large title navigation bar and organized sections.
///
/// The page is built using a [CustomScrollView] with multiple sections:
/// - Navigation Section: Main application features
/// - Preferences Section: Settings and configuration
/// - Calendar Section: Event calendar integration
///
/// Example usage:
/// ```dart
/// Navigator.push(
///   context,
///   CupertinoPageRoute(builder: (context) => MenuPage()),
/// );
/// ```
class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

/// The state class for [MenuPage], managing the menu page's state and layout.
///
/// This state class handles:
/// - Loading state management
/// - Error message display
/// - Controller initialization
/// - Building the menu page layout with organized sections
class _MenuPageState extends State<MenuPage> {
  /// Controller for handling navigation between different application pages.
  final MenuPageController _controller = MenuPageController();

  /// Indicates whether the page is currently loading content.
  ///
  /// When true, loading indicators can be shown. Currently initialized as true
  /// but may be used for future asynchronous operations.
  bool isLoading = true;

  /// Stores any error messages that occur during page initialization or operations.
  ///
  /// Empty string indicates no errors. Can be used to display error messages to users.
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Future initialization tasks can be added here
  }

  @override
  Widget build(BuildContext context) {
    /// Builds the main menu page with Cupertino-style scaffolding.
    ///
    /// Returns a [CupertinoPageScaffold] containing a [CustomScrollView] with:
    /// - Navigation bar with application title
    /// - Navigation section for main features
    /// - Preferences section for settings
    /// - Calendar section for events
    ///
    /// The layout uses slivers for efficient scrolling performance.
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          /// Application title bar with large title styling
          CupertinoSliverNavigationBar(
            largeTitle: Text(
              "Inventário",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),

          /// Main navigation section containing links to core features
          SliverToBoxAdapter(
            child: NavigationSection(
              controller: _controller,
              context: context,
            ),
          ),

          /// Preferences and settings section
          SliverToBoxAdapter(
            child: PreferencesSection(
              controller: _controller,
              context: context,
            ),
          ),

          /// Calendar and events section
          SliverToBoxAdapter(
            child: CalendarSection(),
          ),
        ],
      ),
    );
  }
}
