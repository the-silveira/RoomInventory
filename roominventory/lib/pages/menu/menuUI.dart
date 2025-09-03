import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roominventory/pages/menu/menuController.dart';
import 'package:roominventory/pages/menu/menuWidgets.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final MenuPageController _controller = MenuPageController();
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

          // Navigation Section
          SliverToBoxAdapter(
            child: NavigationSection(
              controller: _controller,
              context: context,
            ),
          ),

          // Preferences Section
          SliverToBoxAdapter(
            child: PreferencesSection(
              controller: _controller,
              context: context,
            ),
          ),

          // Calendar Section
          SliverToBoxAdapter(
            child: CalendarSection(),
          ),
        ],
      ),
    );
  }
}
