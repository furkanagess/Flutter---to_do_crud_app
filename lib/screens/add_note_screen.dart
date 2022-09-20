import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:to_do_crud_app/db/database.dart';
import 'package:to_do_crud_app/models/note_model.dart';
import 'package:to_do_crud_app/screens/home_page.dart';

class AddNoteScreen extends StatefulWidget {
  final Note? note;
  final Function? updateNoteList;

  AddNoteScreen({this.note, this.updateNoteList});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _dateController = TextEditingController();
  DateTime _date = DateTime.now();
  String _priority = "Low";
  String btnText = "Add Note";
  String _title = "";
  String titleText = "Add Note";

  final DateFormat _dateFormatter = DateFormat("MMM dd, yyyy");
  final List<String> _priorities = ["Low", "Medium", "High"];

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _title = widget.note!.title!;
      _date = widget.note!.date!;
      _priority = widget.note!.priority!;

      setState(() {
        btnText = "Update Note";
        titleText = "Update Note";
      });
    } else {
      setState(() {
        btnText = "Add Note";
        titleText = "Add Note";
      });
    }
    _dateController.text = _dateFormatter.format(_date);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  _handleDatePicker() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2121),
    );
    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
      _dateController.text = _dateFormatter.format(date);
    }
  }

  _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Note note = Note(title: _title, date: _date, priority: _priority);

      if (widget.note == null) {
        note.status = 0;
        DatabaseHelper.instance.insertNote(note);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(),
          ),
        );
      } else {
        note.id = widget.note!.id;
        note.status = widget.note!.status;
        DatabaseHelper.instance.updateNote(note);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(),
          ),
        );
      }
    } else {
      widget.updateNoteList!();
    }
  }

  _delete() {
    DatabaseHelper.instance.deleteNote(widget.note!.id!);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(),
      ),
    );
    if (widget.updateNoteList != null) {
      widget.updateNoteList!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B0B0B),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => HomePage()));
                  },
                  child: Icon(
                    Icons.arrow_back,
                    size: 30,
                    color: Color(0xFFa3fda1),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  titleText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: TextFormField(
                          style: TextStyle(fontSize: 18, color: Colors.white),
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Color(0xFF925FF0),
                              ),
                            ),
                            fillColor: Colors.green,
                            labelText: "Enter a Title",
                            labelStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.white54,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.green),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Color(0xFF925FF0)),
                            ),
                          ),
                          validator: (input) => input!.trim().isEmpty
                              ? "Please enter a note title"
                              : null,
                          onSaved: (input) => _title = input!,
                          initialValue: _title,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: TextFormField(
                          readOnly: true,
                          controller: _dateController,
                          style: TextStyle(fontSize: 18, color: Colors.white),
                          onTap: _handleDatePicker,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Color(0xFF925FF0),
                              ),
                            ),
                            labelText: "Date",
                            labelStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.white54,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.green),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Color(0xFF925FF0)),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: DropdownButtonFormField(
                          isDense: true,
                          dropdownColor: Color(0xFF0B0B0B),
                          icon: Icon(Icons.arrow_drop_down_circle),
                          iconSize: 22,
                          iconEnabledColor: Color(0xFFa3fda1),
                          items: _priorities.map((String priority) {
                            return DropdownMenuItem(
                              value: priority,
                              child: Text(
                                priority,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }).toList(),
                          style: TextStyle(
                            fontSize: 18,
                          ),
                          decoration: InputDecoration(
                            labelText: "Priority",
                            labelStyle:
                                TextStyle(fontSize: 18, color: Colors.white54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.green),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Color(0xFF925FF0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Color(0xFF925FF0)),
                            ),
                          ),
                          validator: (input) => _priority == null
                              ? "Please select a priority level"
                              : null,
                          onChanged: (value) {
                            setState(() {
                              _priority = value.toString();
                            });
                          },
                          value: _priority,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20),
                        height: 50,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Color(0xFFa3fda1),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: ElevatedButton(
                          onPressed: _submit,
                          child: Text(
                            "Update",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFFa3fda1),
                          ),
                        ),
                      ),
                      widget.note != null
                          ? Container(
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              height: 50,
                              width: 150,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Color.fromARGB(255, 200, 50, 50),
                                ),
                                child: Text(
                                  "Delete ",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                                onPressed: _delete,
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
