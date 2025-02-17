// custom_navigation_bar.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget implements ObstructingPreferredSizeWidget {
  final String title;

  const CustomNavigationBar({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(
      middle: Text(
        title,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      previousPageTitle: "Inventário CCO", // This will appear if the page is not the root
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  bool shouldFullyObstruct(BuildContext context) {
    return true;
  }
}
