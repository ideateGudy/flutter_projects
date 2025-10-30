import 'package:hive_flutter/hive_flutter.dart';

class TodoDatabase {
  List todoList = [];
  final _myBox = Hive.box('mybox');

  //Run if first time ever opening the app
  void createInitialData() {
    todoList = [
      ["My Todo", true],
      ["Second Todo", false],
      ["Testing", true],
    ];
  }

  //load the data
  void loadData() {
    todoList = _myBox.get("TODOLIST");
  }

  //update the database
  void updateDatabase() {
    _myBox.put("TODOLIST", todoList);
  }
}
