import 'package:isar/isar.dart';

part 'app_setting.g.dart';

@Collection()
class AppSetting {
  Id id = Isar.autoIncrement;
  DateTime? firstLaunchDate;
}
