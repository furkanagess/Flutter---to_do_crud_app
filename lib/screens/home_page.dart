import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:to_do_crud_app/db/database.dart';
import 'package:to_do_crud_app/screens/add_note_screen.dart';

import '../models/note_model.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Note>> _noteList;
  final DateFormat _dateFormatter = DateFormat("MMM dd, yyyy");
  DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _updateNoteList();
  }

  _updateNoteList() {
    _noteList = DatabaseHelper.instance.getNoteList();
  }

  Widget _buildNote(Note note) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          ListTile(
            title: Text(
              note.title!,
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                decoration: note.status == 0
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
              ),
            ),
            subtitle: Text(
              '${_dateFormatter.format(note.date!)} - ${note.priority}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                decoration: note.status == 0
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
              ),
            ),
            trailing: Checkbox(
              onChanged: (value) {
                note.status = value! ? 1 : 0;
                DatabaseHelper.instance.updateNote(note);
                _updateNoteList();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomePage(),
                  ),
                );
              },
              activeColor: Color(0xFFa3fda1),
              checkColor: Colors.black,
              value: note.status == 1 ? true : false,
            ),
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => AddNoteScreen(
                    updateNoteList: _updateNoteList(),
                    note: note,
                  ),
                ),
              );
            },
          ),
          Divider(
            height: 5,
            color: Color(0xFF925FF0),
            thickness: 3,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B0B0B),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFa3fda1),
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => AddNoteScreen(
                updateNoteList: _updateNoteList,
              ),
            ),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
      body: FutureBuilder<dynamic>(
        future: _noteList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final int completeNoteCount = snapshot.data!
              .where((Note note) => note.status == 1)
              .toList()
              .length;

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 80),
            itemCount: int.parse(snapshot.data!.length.toString()) + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "My notes",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "${completeNoteCount} of ${snapshot.data.length}",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return _buildNote(snapshot.data![index - 1]);
            },
          );
        },
      ),
    );
  }
}
