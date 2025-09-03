import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/globalWidgets/calendar/calendar.dart';
import 'package:roominventory/pages/menu/menuController.dart';

class NavigationSection extends StatelessWidget {
  final MenuPageController controller;
  final BuildContext context;

  const NavigationSection({
    Key? key,
    required this.controller,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      children: [
        _buildListTile(
          context: context,
          title: 'Eventos',
          icon: CupertinoIcons.list_dash,
          onTap: () => controller.navigateToEventos(context),
        ),
        _buildListTile(
          context: context,
          title: 'Itens',
          icon: CupertinoIcons.cube_box_fill,
          onTap: () => controller.navigateToItens(context),
        ),
        _buildListTile(
          context: context,
          title: 'Locais',
          icon: CupertinoIcons.map_fill,
          onTap: () => controller.navigateToLocais(context),
        ),
        _buildListTile(
          context: context,
          title: 'Dimmers',
          icon: CupertinoIcons.cube_box_fill,
          onTap: () => controller.navigateToDimmers(context),
        ),
      ],
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return CupertinoListTile.notched(
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      leading: Icon(
        icon,
        color: CupertinoColors.systemBlue,
      ),
      trailing: CupertinoListTileChevron(),
      onTap: onTap,
    );
  }
}

class PreferencesSection extends StatelessWidget {
  final MenuPageController controller;
  final BuildContext context;

  const PreferencesSection({
    Key? key,
    required this.controller,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
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
          onTap: () => controller.navigateToDefinicoes(context),
        ),
      ],
    );
  }
}

class CalendarSection extends StatelessWidget {
  const CalendarSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      children: [
        Container(
          height: 700,
          child: CalendarWidget(),
        ),
      ],
    );
  }
}
