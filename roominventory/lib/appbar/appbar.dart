import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title, icon;

  const MyAppBar({Key? key, required this.title, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(
      middle: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      leading: icon == "Drawer"
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.bars),
              onPressed: () {
                // Open the drawer
                Scaffold.of(context).openDrawer();
              },
            )
          : CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.back),
              onPressed: () {
                // Navigate back
                Navigator.of(context).pop();
              },
            ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
