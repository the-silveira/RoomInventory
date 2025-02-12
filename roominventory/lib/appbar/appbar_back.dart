import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppBarBack extends StatelessWidget implements PreferredSizeWidget {
  const AppBarBack({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("Detalhes"),
      leading: IconButton(
        //icon: Icon(CupertinoIcons.line_horizontal_3),
        icon: Icon(CupertinoIcons.back),
        onPressed: () => Navigator.pop(context), // Use dynamic title
        //backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
