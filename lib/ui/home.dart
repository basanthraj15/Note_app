import 'package:flutter/material.dart';
import 'package:note_app/services/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    print("Note added");
    _reloadNotes(); // to reload after adding
  }

  void showBottomSheetContent(int? id) async {
    _noteTitleController.clear();
    _noteDescriptionController.clear();
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
                          right: 15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextField(
                            controller: _noteTitleController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "Note Title"),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextField(
                            controller: _noteDescriptionController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "Description"),
                            maxLines: 5,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Center(
                            child: OutlinedButton(
                                onPressed: () async {
                                  _addNote();
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  "Add Note",
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w300),
                                )),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
      ),
      body: SafeArea(
          child: _isLoadingNote
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount: _allNotes.length,
                  itemBuilder: (context, index) => Card(
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
                              ),
                        ],
                      ),
                      subtitle: Text(
                        _allNotes[index]['description'],
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showBottomSheetContent(0);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
