import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_model.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Center(
        child: CupertinoSwitch(
          value: Provider.of<ThemeModel>(context).isDarkMode,
          onChanged: (value) =>
              Provider.of<ThemeModel>(context, listen: false).toggleTheme(),
        ),
      ),
    );
  }
}
