import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget implements ObstructingPreferredSizeWidget {
  final String title, previousPageTitle;
  final VoidCallback? onAddPressed; // Callback for the add button

  const CustomNavigationBar({
    Key? key,
    required this.title,
    required this.previousPageTitle,
    this.onAddPressed, // Optional callback for the add button
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(
      middle: Text(
        title,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      previousPageTitle: previousPageTitle, // This will appear if the page is not the root
      trailing: onAddPressed != null
          ? CupertinoButton(
              padding: EdgeInsets.zero, // Remove default padding
              onPressed: onAddPressed, // Call the callback when the button is pressed
              child: Icon(
                CupertinoIcons.add, // Use the Cupertino add icon
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  bool shouldFullyObstruct(BuildContext context) {
    return true;
  }
}
