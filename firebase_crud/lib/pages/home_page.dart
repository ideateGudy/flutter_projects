import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crud/services/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //firestore service instance
  final FirestoreService _firestoreService = FirestoreService();
  //text controller for note input
  final TextEditingController _noteController = TextEditingController();
  //open note box
  void openNoteBox({String? docId}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(docId == null ? 'Add Note' : 'Edit Note'),
        content: TextField(
          controller: _noteController,
          decoration: InputDecoration(
            hintText: docId == null
                ? 'Enter your note here'
                : 'Edit your note here',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Add note to Firestore
              if (docId != null) {
                //update existing note
                _firestoreService.updateNote(docId, _noteController.text);
              } else {
                //add new note
                _firestoreService.addNote(_noteController.text);
              }

              _noteController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes'), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getNotes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final notes = snapshot.data!.docs;
            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                //get each individual document
                DocumentSnapshot document = notes[index];
                String docId = document.id;

                //get note from each document
                Map<String, dynamic> noteData =
                    document.data() as Map<String, dynamic>;
                String noteText = noteData['note'];

                //display as list tile for ui
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blueAccent.shade100),
                  ),
                  child: ListTile(
                    title: Text(noteText),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //update button
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.blue),
                          onPressed: () => openNoteBox(docId: docId),
                        ),
                        //delete button
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _firestoreService.deleteNote(docId),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          //no data found
          else {
            return const Center(child: Text('No notes found.'));
          }
        },
      ),
    );
  }
}
