import 'package:flutter/cupertino.dart';
import 'package:habbit_app/models/app_setting.dart';
import 'package:habbit_app/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

  //Initialize database
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar =
        await Isar.open([HabitSchema, AppSettingSchema], directory: dir.path);
  }

  //save first date of app startup (for heatmap)
  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSetting()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  //Get first date of app startup (for heatmap)
  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  //CRUD
  //habit list
  final List<Habit> currentHabits = [];

  //create (add new habits)
  Future<void> addHabit(String habitName) async {
    //create new habbit
    final newHabit = Habit()..name = habitName;

    //save db
    await isar.writeTxn(() => isar.habits.put(newHabit));

    //re-read from db
    readHabits();
  }

  //read (read saved habits from db)
  Future<void> readHabits() async {
    //fetch all habits from db
    List<Habit> fetchedHabits = await isar.habits.where().findAll();

    //give to current habits
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);

    //update UI
    notifyListeners();
  }

  //update (check habit on and off)
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    //find spesific habit
    final habit = await isar.habits.get(id);

    //update completion status
    if (habit != null) {
      await isar.writeTxn(() async {
        //if habit is completed add the current date
        if (isCompleted && !habit.completedDays.contains(DateTime.now())) {
          //today
          final today = DateTime.now();

          //ad the current date if it's not alredy in the list
          habit.completedDays.add(
            DateTime(
              today.year,
              today.month,
              today.day,
            ),
          );
        }
        //if habit is not completed remove the current date
        else {
          //remove current date
          habit.completedDays.removeWhere(
            (date) =>
                date.year == DateTime.now().year &&
                date.month == DateTime.now().month &&
                date.day == DateTime.now().day,
          );
        }
        //save the updated habitd back to the db
        await isar.habits.put(habit);
      });
    }

    //re-read from db
    readHabits();
  }

  //Update (edit habit name)
  Future<void> updateHabitName(int id, String newName) async {
    //find the specific habit
    final habit = await isar.habits.get(id);

    //update habit name
    if (habit != null) {
      await isar.writeTxn(() async {
        habit.name = newName;
        //save back to db
        await isar.habits.put(habit);
      });
    }

    //re-read
    readHabits();
  }

  //Delete habit
  Future<void> deleteHabit(int id) async {
    //perform delete
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });

    //re-read
    readHabits();
  }
}
