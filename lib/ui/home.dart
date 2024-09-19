import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:note_app/services/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  HomeScreen({super.key, required this.onThemeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDarkMode = false;

  Future<void> _loadThemePreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = pref.getBool('isDarkMode') ?? false;
    });
  }

  //toggle theme
  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
      widget.onThemeChanged(_isDarkMode);
    });
  }

  final TextEditingController _noteTitleController = TextEditingController();
  final TextEditingController _noteDescriptionController =
      TextEditingController();

  List<Map<String, dynamic>> _allNotes = [];
  bool _isLoadingNote = true;

  @override
  void initState() {
    super.initState();
    _reloadNotes();
  }

  //get all notes
  void _reloadNotes() async {
    final note = await QueryHelper.getAllNotes();
    setState(() {
      _allNotes = note;
      _isLoadingNote = false;
    });
  }

  //add notes

  Future<void> _addNote() async {
    await QueryHelper.createNote(
        _noteTitleController.text, _noteDescriptionController.text);
    print("Note added successfully!");
    _reloadNotes(); // to reload after adding
  }

//update notes

  Future<void> _updateNote(int id) async {
    await QueryHelper.updateNote(
        id, _noteTitleController.text, _noteDescriptionController.text);
    _reloadNotes();
  }

  //delete notes

  void _deleteNote(int id) async {
    await QueryHelper.deleteNote(id);
    showSnackbar(context, "Note has been deleted Successfully",
        const Color.fromARGB(255, 107, 29, 163));
    _reloadNotes();
  }

  //delete all notes

  void _deleteAllNotes() async {
    final noteCount = await QueryHelper.getNoteCount();
    if (noteCount > 0) {
      await QueryHelper.deleteAllNotes();
      _reloadNotes();
      showSnackbar(context, "All notes Deleted!",
          _isDarkMode ? Colors.white : const Color.fromARGB(255, 107, 29, 163));
    } else {
      showSnackbar(context, "No notes to Delete!",
          _isDarkMode ? Colors.white : const Color.fromARGB(255, 107, 29, 163));
    }
  }

//snackbar
  void showSnackbar(BuildContext context, String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void ShowDeleteAllPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete all Notes!"),
          content:
              Text("Are you sure you want to delete all the existing notes?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("No"),
            ),
            TextButton(
                onPressed: () {
                  _deleteAllNotes();
                  Navigator.of(context).pop();
                },
                child: Text("Yes", style: const TextStyle(color: Colors.red))),
          ],
        );
      },
    );
  }

  void showBottomSheetContent(int? id) async {
    if (id != null) {
      final currentNote = _allNotes.firstWhere(
        (element) => element['id'] == id,
        orElse: () => {},
      );

      if (currentNote.isNotEmpty) {
        _noteTitleController.text = currentNote['title'];
        _noteDescriptionController.text = currentNote['description'];
      } else {
        print("Note with ID $id not found.");
        _noteTitleController.text = "";
        _noteDescriptionController.text = "";
      }
    } else {
      _noteTitleController.text = "";
      _noteDescriptionController.text = "";
    }

    showModalBottomSheet(
      elevation: 2.0,
      isScrollControlled: true,
      context: context,
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                  top: 15,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 15,
                  right: 15,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      controller: _noteTitleController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Note Title",
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _noteDescriptionController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Description",
                      ),
                      maxLines: 5,
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: OutlinedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 47, 6, 54)),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white),
                        ),
                        onPressed: () async {
                          if (id == null) {
                            await _addNote();
                          } else {
                            await _updateNote(id);
                          }
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          id == null ? "Add Note" : "Update Note",
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w300),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "NOTE APP",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Transform.scale(
            scale: 0.7,
            child: Switch(
                value: _isDarkMode,
                onChanged: (value) {
                  _toggleTheme(value);
                }),
          ),
          Tooltip(
            message: "Delete all Notes",
            child: IconButton(
                onPressed: () {
                  ShowDeleteAllPopup(context);
                },
                icon: Icon(Icons.delete_forever_outlined)),
          ),
          Tooltip(
            message: "Exit App",
            child: IconButton(
                onPressed: () {
                  _exitApp();
                },
                icon: Icon(
                  Icons.exit_to_app_outlined,
                  color: Colors.red,
                )),
          )
        ],
      ),
      body: SafeArea(
          child: _isLoadingNote
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount: _allNotes.length,
                  itemBuilder: (context, index) => Card(
                    elevation: 4.0,
                    margin: EdgeInsets.all(16),
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              _allNotes[index]['title'],
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          )),
                          Row(
                            //add delete edit option

                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Tooltip(
                                message: "Edit note",
                                child: IconButton(
                                    onPressed: () {
                                      showBottomSheetContent(
                                          _allNotes[index]['id']);
                                    },
                                    icon: Icon(Icons.edit)),
                              ),
                              SizedBox(width: 5),
                              IconButton(
                                  onPressed: () {
                                    _deleteNote(_allNotes[index]['id']);
                                  },
                                  icon: Icon(Icons.delete))
                            ],
                          ),
                        ],
                      ),
                      subtitle: Text(
                        _allNotes[index]['description'],
                        style:
                            TextStyle(fontSize: 20, fontFamily: 'DancingScript'),
                      ),
                    ),
                  ),
                )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showBottomSheetContent(null);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _exitApp() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Exit App"),
            content: Text("Are you sure you want to exit the app?"),
            actions: [
              OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("No")),
              OutlinedButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: Text(
                    "Yes",
                    style: TextStyle(color: Colors.red),
                  ))
            ],
          );
        });
  }
}
