import 'package:flutter/material.dart';
import 'package:habbit_app/database/habit_database.dart';
import 'package:habbit_app/theme/theme_model.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //initialize DB
  await HabitDatabase.initialize();
  await HabitDatabase().saveFirstLaunchDate();

  runApp(
    MultiProvider(
      providers: [
        //habit provider
        ChangeNotifierProvider(create: (context) => HabitDatabase()),

        //theme provider
        ChangeNotifierProvider(create: (context) => ThemeModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Homepage(),
      theme: Provider.of<ThemeModel>(context).themeData,
    );
  }
}
