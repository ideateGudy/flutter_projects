import 'package:flutter/material.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/components/my_habit_tile.dart';
import 'package:habit_tracker/components/my_heat_map.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/utils/habit_util.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    //read the database when the app starts
    context.read<HabitDatabase>().readHabits();
    super.initState();
  }

  //text controller
  final TextEditingController _habitController = .new();
  //create a new habit
  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Habit'),
        content: TextField(
          controller: _habitController,
          decoration: const InputDecoration(
            hintText: 'Type here',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
              _habitController.clear();
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          MaterialButton(
            onPressed: () {
              //get the habit text
              String habitText = _habitController.text;

              //save the habit to database
              context.read<HabitDatabase>().addHabit(habitText);

              //close the dialog
              Navigator.pop(context);

              //clear the text field
              _habitController.clear();
            },
            child: const Text('Save', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  //check habit on/off
  void checkHabitOnOff(bool? value, Habit habit) {
    //update the habit completion status in database
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  //edit habit
  void editHabit(Habit habit) {
    //set the current habit name to the text controller
    _habitController.text = habit.name;
    //show dialog to edit habit
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Habit'),
        content: TextField(
          controller: _habitController,
          decoration: const InputDecoration(hintText: 'Edit your habit'),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
              _habitController.clear();
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          MaterialButton(
            onPressed: () {
              //get the updated habit text
              String updatedHabitText = _habitController.text;

              //update the habit in database
              habit.name = updatedHabitText;
              context.read<HabitDatabase>().updateHabitName(
                habit.id,
                updatedHabitText,
              );

              //close the dialog
              Navigator.pop(context);

              //clear the text field
              _habitController.clear();
            },
            child: const Text('Update', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  //delete habit
  void deleteHabit(Habit habit) {
    //show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: const Text('Are you sure you want to delete this habit?'),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
          ),
          MaterialButton(
            onPressed: () {
              //delete the habit from database
              context.read<HabitDatabase>().deleteHabit(habit.id);

              //close the dialog
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      body: ListView(
        children: [
          //HEAT MAP
          _buildHeatMap(),

          //HABIT LIST
          _buildHabitList(),
        ],
      ),
    );
  }

  //build heat map
  Widget _buildHeatMap() {
    //get the habit database
    final habitDatabase = context.watch<HabitDatabase>();

    //get all habits
    List<Habit> habits = habitDatabase.habits;

    //return the heat map ui
    return FutureBuilder<DateTime?>(
      future: habitDatabase.getFirstLaunchDate(),
      builder: (context, snapshot) {
        //once data is available build the heat map
        if (snapshot.hasData) {
          return MyHeatMap(
            startDate: snapshot.data!,
            datasets: prepareHeatMapDatasets(habits),
          );
        }
        //handle case where no data is returned
        else {
          return Container();
        }
      },
    );
  }

  //build habit list
  Widget _buildHabitList() {
    //get the habit database
    final habitDatabase = context.watch<HabitDatabase>();

    //current habit list
    List<Habit> habits = habitDatabase.habits;

    //return a list for habits ui
    return ListView.builder(
      itemCount: habits.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        //get each habit
        final habit = habits[index];

        //check if the habit is completed today
        bool isCompleted = isHabitCompletedToday(habit.completedDays);

        //return a list tile for each habit
        return MyHabitTile(
          habitName: habit.name,
          isCompleted: isCompleted,
          onChanged: (value) => checkHabitOnOff(value, habit),
          editHabit: (context) => editHabit(habit),
          deleteHabit: (context) => deleteHabit(habit),
        );
      },
    );
  }
}
