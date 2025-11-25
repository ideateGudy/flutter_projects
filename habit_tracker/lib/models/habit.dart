import 'package:isar/isar.dart';

// Run the command to generate the code:
// run: dart run build_runner build
part 'habit.g.dart';
@Collection()
class Habit {
  //habit id
  Id id = Isar.autoIncrement;

  //habit name
  late String name;

  //completed days
  List<DateTime> completedDays = [
    // DateTime (year, month, day)
  ];
}
