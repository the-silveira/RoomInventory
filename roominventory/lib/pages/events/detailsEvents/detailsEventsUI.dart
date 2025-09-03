import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/globalWidgets/appbar/appbar.dart';
import 'package:roominventory/pages/events/detailsEvents/detailsEventsController.dart';
import 'package:roominventory/pages/events/detailsEvents/detailsEventsWidgets.dart';

class detailsEventsPage extends StatefulWidget {
  final String eventId;

  detailsEventsPage({required this.eventId});

  @override
  _detailsEventsPageState createState() => _detailsEventsPageState();
}

class _detailsEventsPageState extends State<detailsEventsPage> {
  final detailsEventsController _controller = detailsEventsController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await _controller.fetchData(widget.eventId);
    setState(() {});
  }

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

  void _navigateToAddItems() {
    _controller.navigateToAddItems(context, widget.eventId);
  }

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
                      CupertinoSliverRefreshControl(
                        onRefresh: _refreshData,
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate([
                          if (_controller.event != null)
                            EventHeader(event: _controller.event),
                          ItemsList(
                            items: _controller.items,
                            controller: _controller,
                            eventId: widget.eventId,
                            onDataRefresh: _loadData,
                          ),
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
