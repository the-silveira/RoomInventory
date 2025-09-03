import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide SearchBar;
import 'package:roominventory/globalWidgets/appbar/appbar.dart';

import 'package:roominventory/pages/places/addPlaces/addPlacesUI.dart';
import 'package:roominventory/pages/places/addZones/addZonesUI.dart';
import 'package:roominventory/pages/places/places/placesController.dart';
import 'package:roominventory/pages/places/places/placesWidgets.dart';

class PlacesPage extends StatefulWidget {
  @override
  _PlacesPageState createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage> {
  final PlacesController _controller = PlacesController();
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

  void _filterPlaces(String query) {
    setState(() {
      _controller.filterPlaces(query);
    });
  }

  void _navigateToAdd() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => AddOptionsSheet(
        onAddPlace: () {
          Navigator.pop(context);
          _navigateToAddPlace();
        },
        onAddZone: () {
          Navigator.pop(context);
          _navigateToAddZone();
        },
      ),
    );
  }

  void _navigateToAddPlace() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => AddPlacePage()),
    ).then((_) => _loadData());
  }

  void _navigateToAddZone() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => AddZonePage()),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CustomNavigationBar(
        title: 'Places',
        previousPageTitle: 'Inventário',
        onAddPressed: _navigateToAdd,
      ),
      child: SafeArea(
        child: Column(
          children: [
            SearchBar(
              controller: _searchController,
              onChanged: _filterPlaces,
            ),
            Expanded(
              child: _controller.isLoading
                  ? Center(child: CupertinoActivityIndicator())
                  : _controller.filteredPlaces.isEmpty
                      ? EmptyState()
                      : ListView.builder(
                          itemCount: _controller.filteredPlaces.length,
                          itemBuilder: (context, placeIndex) {
                            var place = _controller.filteredPlaces[placeIndex];
                            return PlaceSection(place: place);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
