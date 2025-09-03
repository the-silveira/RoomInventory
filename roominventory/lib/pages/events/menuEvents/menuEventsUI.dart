import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/globalWidgets/appbar/appbar.dart';
import 'package:roominventory/pages/events/menuEvents/menuEventsController.dart';
import 'package:roominventory/pages/events/menuEvents/menuEventsWidgets.dart';

class menuEventosPage extends StatefulWidget {
  @override
  _menuEventosPageState createState() => _menuEventosPageState();
}

class _menuEventosPageState extends State<menuEventosPage> {
  final menuEventosController _controller = menuEventosController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await _controller.fetchData();
    setState(() {});
  }

  void _filterItems(String query) {
    setState(() {
      _controller.filterItems(query, _controller.events);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar(
        title: 'Eventos',
        previousPageTitle: 'Inventário',
        onAddPressed: () => _controller.navigateToAdd(context),
      ),
      child: Column(
        children: [
          EventSearchBar(
            controller: _searchController,
            onChanged: _filterItems,
          ),
          EventsListView(
            controller: _controller,
            searchController: _searchController,
          ),
        ],
      ),
    );
  }
}
