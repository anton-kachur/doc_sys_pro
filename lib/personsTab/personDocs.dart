import 'package:doc_sys_pro/documentsTab/addDocument.dart';
import 'package:doc_sys_pro/documentsTab/editDocument.dart';
import 'package:doc_sys_pro/models/document.dart';
import 'package:doc_sys_pro/models/person.dart';
import 'package:doc_sys_pro/utils.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';


class PersonDocs extends StatefulWidget {
  final int index;

  PersonDocs({required this.index});

  @override
  _PersonDocsState createState() => _PersonDocsState();
}

class _PersonDocsState extends State<PersonDocs> {
  late Box<Document> _personsDocsBox;
  List<Document> _personsDocsList = [];
  String currentPerson = '';

  late Map<int, bool> _checkBoxValues = generateCheckBoxBitMap(mode: "documents");
  bool _isDeleteClicked = false;
  bool _isEditClicked = false;
  bool _isViewClicked = false;

  bool _checkBoxVisibility = false;


  Future getDataFromBox() async {
    // ALGORITHM: Get a current person's id -> check if there are documents marked with that id
    Box<Person> _personsBox = await Hive.openBox('personas');
    _personsDocsBox = await Hive.openBox('documents');
    
    currentPerson = _personsBox.getAt(widget.index)!.person_id;

    for (var item in _personsDocsBox.values) {
      if (currentPerson == item.number) {
        _personsDocsList.add(item);
      }
    }
  }

  void _deleteDocument(int index) {
    setState(() {
      _personsDocsBox.deleteAt(index);
      _personsDocsList.removeAt(index);
    });
  }

  IconData _createIcon() {
    // Creates icons for FloatingAction depending on mode (delete/edit/add)
    if (_isDeleteClicked) {
      return Icons.delete_forever; 
    } else if (_isEditClicked) { 
      return Icons.edit;
    } else if (_isViewClicked) { 
      return Icons.search_rounded;
    } else {
      return Icons.add_rounded;
    }
  }


  @override
  Widget build(BuildContext context) {
    var boxData = getDataFromBox();  // data retreived from database

    return FutureBuilder(
        future: boxData, 
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          
            if (snapshot.hasError) {
              return waitingOrErrorWindow('Помилка: ${snapshot.error}', context);
            } else {
              return Scaffold(
                
                  appBar: AppBar(
                    toolbarHeight: 60,
                    title: const Text('Ваші документи'),
                    backgroundColor: const Color.fromARGB(255, 40, 40, 40),
                    actions: [

                      // Edit button, changes color if clicked
                      IconButton(
                        splashColor: Colors.transparent,
                        alignment: Alignment.centerLeft,
                        icon: Icon(
                          Icons.edit_note_rounded, 
                          size: 30,
                          color: _isEditClicked ? const Color.fromARGB(255, 246, 246, 246) : const Color.fromARGB(57, 246, 246, 246)
                        ),

                        onPressed: () {
                          setState(() {
                            _isEditClicked = !_isEditClicked;
                            _isDeleteClicked = false;
                            _isViewClicked = false;
                            _checkBoxVisibility = !_checkBoxVisibility;
                          });
                        }
                      ),

                      // Delete button, changes color if clicked
                      IconButton(
                        splashColor: Colors.transparent,
                        alignment: Alignment.centerLeft,
                        icon: Icon(
                          Icons.playlist_remove_rounded, 
                          color: _isDeleteClicked ? const Color.fromARGB(255, 246, 246, 246) : const Color.fromARGB(57, 246, 246, 246)
                        ),

                        onPressed: () {
                          setState(() {
                            _isDeleteClicked = !_isDeleteClicked;
                            _isEditClicked = false;
                            _isViewClicked = false;
                            _checkBoxVisibility = !_checkBoxVisibility;
                          });
                        }),

                      // View person's profile button, changes color if clicked
                      IconButton(
                        splashColor: Colors.transparent,
                        alignment: Alignment.centerLeft,
                        icon: Icon(
                          Icons.manage_search_rounded, 
                          color: _isViewClicked ? const Color.fromARGB(255, 246, 246, 246) : const Color.fromARGB(57, 246, 246, 246)
                        ),

                        onPressed: () {
                          setState(() {
                            _isViewClicked = !_isViewClicked;
                            _isDeleteClicked = false;
                            _isEditClicked = false;
                            _checkBoxVisibility = !_checkBoxVisibility;
                          });
                        }),

                    ],
                  ),

                  body: _personsDocsList.length == 0 ? 
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      child: Text('У вас немає жодного документа'),
                    ) :
                    ListView.builder(
                      itemCount: _personsDocsList.length,
                      itemBuilder: (context, index) {
                          
                        return ExpansionTile(
                          backgroundColor: Color.fromARGB(70, 144, 144, 144),
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          expandedAlignment: Alignment.centerLeft,
                          childrenPadding: const EdgeInsets.fromLTRB(73, 0, 0, 20),
                          title: Text(_personsDocsList[index].name),
                          subtitle: Text(_personsDocsList[index].type),
                          controlAffinity: ListTileControlAffinity.leading,
                          children: [
                            SelectableText('Номер: ${_personsDocsList[index].number}'),
                            SelectableText('Дата: ${_personsDocsList[index].date}'),
                            SelectableText('Посилання: ${_personsDocsList[index].imagePath}'),
                          ],
                        );
                      }
                    ),

                  floatingActionButton: FloatingActionButton.large(
                    backgroundColor: const Color.fromARGB(255, 58, 58, 58),
                    child: Icon(_createIcon()),
                    onPressed: () {

                      if (_isDeleteClicked) {
                        for (MapEntry<int, bool> entry in _checkBoxValues.entries) {
                          if (entry.value == true) _deleteDocument(entry.key);
                        }
                      } else if (_isEditClicked) {
                        for (MapEntry<int, bool> entry in _checkBoxValues.entries) {
                          if (entry.value == true) {
                            Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    DocumentSettings(index: entry.key)));
                            break;
                          }
                        }
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddDocument(curr_id: currentPerson)));
                      }
                    }
                  )

              );
            }
        }
    );
  }
}