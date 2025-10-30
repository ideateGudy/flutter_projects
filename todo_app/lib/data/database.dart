import 'package:hive_flutter/hive_flutter.dart';

class TodoDatabase {
  List todoList = [];
  final _myBox = Hive.box('mybox');

  //Run if first time ever opening the app
  void createInitialData() {
    todoList = [
      ["My Todo", true],
      ["Click on the plus sign (+) to add a new todo", false],
      ["Double tap on a todo item to edit it", false],
      ["Swipe task left and click on delete to remove a task from list", false],
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
