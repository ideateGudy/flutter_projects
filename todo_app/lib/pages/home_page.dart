import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/components/dialog_box.dart';
import 'package:todo_app/components/todo_tile.dart';
import 'package:todo_app/data/database.dart';
import 'package:todo_app/theme/theme.dart';
import 'package:todo_app/theme/theme_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _myBox = Hive.box('mybox');
  TodoDatabase db = TodoDatabase();

  @override
  void initState() {
    //first time opening the app (nothing saved yet)
    if (_myBox.get("TODOLIST") == null) {
      db.createInitialData();
    } else {
      db.loadData();
    }
    
    super.initState();
  }

  final TextEditingController _myController = TextEditingController();

  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.todoList[index][1] = !db.todoList[index][1];
    });
    db.updateDatabase();
  }

  void saveNewTask() {
    if (_myController.text.isNotEmpty) {
      setState(() {
        db.todoList.add([_myController.text, false]);
        _myController.clear();
      });
      Navigator.of(context).pop();
      db.updateDatabase();
    }
  }

  void saveEditTask(int index) {
    if (_myController.text.isNotEmpty) {
      setState(() {
        db.todoList[index] = [_myController.text, false];
      });
      Navigator.of(context).pop();
      db.updateDatabase();
    }
  }

  void editTodoTask(int index) {
    _myController.text = db.todoList[index][0];
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _myController,
          onSave: () => saveEditTask(index),
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void createNewTask() {
    _myController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _myController,
          onSave: saveNewTask,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void deleteTask(int index) {
    setState(() {
      db.todoList.removeAt(index);
    });
    db.updateDatabase();
  }

  @override
  void dispose() {
    _myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    // Check if current theme is dark
    final bool isDarkMode = themeProvider.themeData == darkMode;
    return Scaffold(
      // backgroundColor: Colors.yellow[900],
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text("TO DO", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Row(
            children: [
              const Icon(Icons.light_mode),
              Switch(
                value: isDarkMode,
                onChanged: (value) {
                  context.read<ThemeProvider>().toggleTheme();
                },
              ),
              const Icon(Icons.dark_mode),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: db.todoList.length,
        itemBuilder: (context, index) {
          final taskName = db.todoList[index][0];
          final taskCompleted = db.todoList[index][1];
          return TodoTile(
            taskName: taskName,
            taskCompleted: taskCompleted,
            onChanged: (value) => checkBoxChanged(value, index),
            deleteFunction: (context) => deleteTask(index),
            editTodo: () => editTodoTask(index),
          );
        },
      ),
    );
  }
}
