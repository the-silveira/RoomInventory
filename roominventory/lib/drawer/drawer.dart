import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/dimmers/dimmerPage.dart';
import 'calendar.dart';
import '/eventos/eventos.dart';
import '/itens/itens.dart';
import '/locais/locais.dart';
import '/definicoes/definicoes.dart';

class OptionsPage extends StatefulWidget {
  @override
  _OptionsPageState createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            largeTitle: Text(
              "Inventário",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),

          // First Section: Navigation
          SliverToBoxAdapter(
            child: CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile.notched(
                  title: Text(
                    'Eventos',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  leading: Icon(
                    CupertinoIcons.list_dash,
                    color: CupertinoColors.systemBlue,
                  ),
                  trailing: CupertinoListTileChevron(),
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (context) => EventosPage()),
                    );
                  },
                ),
                CupertinoListTile.notched(
                  title: Text(
                    'Itens',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  leading: Icon(
                    CupertinoIcons.cube_box_fill,
                    color: CupertinoColors.systemBlue,
                  ),
                  trailing: CupertinoListTileChevron(),
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (context) => ItemsPage()),
                    );
                  },
                ),
                CupertinoListTile.notched(
                  title: Text(
                    'Locais',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  leading: Icon(
                    CupertinoIcons.map_fill,
                    color: CupertinoColors.systemBlue,
                  ),
                  trailing: CupertinoListTileChevron(),
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (context) => LocaisPage()),
                    );
                  },
                ),
                CupertinoListTile.notched(
                  title: Text(
                    'Dimmers',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  leading: Icon(
                    CupertinoIcons.cube_box_fill,
                    color: CupertinoColors.systemBlue,
                  ),
                  trailing: CupertinoListTileChevron(),
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (context) => DMXConfigPage()),
                    );
                  },
                ),
              ],
            ),
          ),

          // Second Section: Preferences
          SliverToBoxAdapter(
            child: CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile.notched(
                  title: Text(
                    'Definições',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                  leading: Icon(
                    CupertinoIcons.settings,
                    color: CupertinoColors.systemBlue,
                  ),
                  trailing: CupertinoListTileChevron(),
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: CupertinoListSection.insetGrouped(
              children: [
                Container(
                  height: 700, // Set a fixed height for the calendar
                  child: CalendarWidget(),
                  // Use the extracted calendar widget
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
