import 'package:flutter/cupertino.dart';
import '/eventos/eventos.dart';
import '/itens/itens.dart';
import '/locais/locais.dart';
import '/definicoes/definicoes.dart';

import 'package:flutter/material.dart';

class OptionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          // Large title navigation bar
          CupertinoSliverNavigationBar(
            largeTitle: Text(
              "Inventário CCO",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
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
                    CupertinoIcons.calendar,
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
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
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

          // Third Section: About
        ],
      ),
    );
  }
}
