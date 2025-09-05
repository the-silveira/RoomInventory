import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/globalWidgets/appbar/appbar.dart';
import 'package:roominventory/pages/events/detailsEvents/detailsEventsController.dart';
import 'package:roominventory/pages/events/detailsEvents/detailsEventsWidgets.dart';

/// A page that displays detailed information about a specific event and its associated items.
///
/// This page provides a comprehensive view of an event including:
/// - Event header information
/// - List of items associated with the event
/// - Action buttons for editing and deleting the event
/// - Pull-to-refresh functionality
/// - Navigation to add items to the event
///
/// The page uses a [detailsEventsController] to manage data fetching and operations.
///
/// Example usage:
/// ```dart
/// Navigator.push(
///   context,
///   CupertinoPageRoute(
///     builder: (context) => detailsEventsPage(eventId: 'event123'),
///   ),
/// );
/// ```
class detailsEventsPage extends StatefulWidget {
  /// The unique identifier of the event to display
  final String eventId;

  /// Creates an event details page for the specified event
  ///
  /// [eventId]: The unique identifier of the event to display
  const detailsEventsPage({required this.eventId});

  @override
  _detailsEventsPageState createState() => _detailsEventsPageState();
}

/// The state class for [detailsEventsPage] that manages the page's lifecycle and UI state.
///
/// This state class handles:
/// - Data loading and refreshing
/// - Controller initialization
/// - Navigation events
/// - UI state management based on loading and error states
class _detailsEventsPageState extends State<detailsEventsPage> {
  /// Controller responsible for fetching and managing event data
  final detailsEventsController _controller = detailsEventsController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Loads event data when the widget is initialized
  ///
  /// This method is called automatically when the state is created.
  /// It triggers the controller to fetch event details and associated items.
  void _loadData() async {
    await _controller.fetchData(widget.eventId);
    setState(() {});
  }

  /// Refreshes the event data with pull-to-refresh functionality
  ///
  /// This method:
  /// 1. Shows a brief delay for visual feedback
  /// 2. Sets loading state to true
  /// 3. Re-fetches data from the controller
  /// 4. Updates the UI with new data
  ///
  /// Returns: [Future<void>] that completes when refresh is done
  Future<void> _refreshData() async {
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {
      _controller.isLoading = true;
    });
    await _controller.fetchData(widget.eventId);
    setState(() {
      _controller.isLoading = false;
    });
  }

  /// Navigates to the add items page for this event
  ///
  /// Uses the controller's navigation method to open the add items screen.
  void _navigateToAddItems() {
    _controller.navigateToAddItems(context, widget.eventId);
  }

  /// Handles successful event deletion by navigating back with a result
  ///
  /// This method is called when an event is successfully deleted.
  /// It pops the navigation stack twice to return to the previous screen
  /// with a success indicator.
  void _onDeleteSuccess() {
    Navigator.pop(context, true);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar(
        title: 'Relatório',
        previousPageTitle: 'Eventos',
        onAddPressed: _navigateToAddItems,
      ),
      child: _controller.isLoading
          ? Center(child: CupertinoActivityIndicator())
          : _controller.errorMessage.isNotEmpty
              ? Center(child: Text(_controller.errorMessage))
              : Scaffold(
                  body: CustomScrollView(
                    slivers: [
                      /// Pull-to-refresh control for updating event data
                      CupertinoSliverRefreshControl(
                        onRefresh: _refreshData,
                      ),

                      /// Main content sliver containing event details
                      SliverList(
                        delegate: SliverChildListDelegate([
                          /// Event header section (if event data is available)
                          if (_controller.event != null)
                            EventHeader(event: _controller.event),

                          /// List of items associated with the event
                          ItemsList(
                            items: _controller.items,
                            controller: _controller,
                            eventId: widget.eventId,
                            onDataRefresh: _loadData,
                          ),

                          /// Action buttons for event operations (edit/delete)
                          EventActions(
                            controller: _controller,
                            event: _controller.event,
                            onDeleteSuccess: _onDeleteSuccess,
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
    );
  }
}
