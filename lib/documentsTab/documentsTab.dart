import 'package:doc_sys_pro/documentsTab/addDocument.dart';
import 'package:doc_sys_pro/documentsTab/editDocument.dart';
import 'package:doc_sys_pro/models/document.dart';
import 'package:doc_sys_pro/personsTab/addPerson.dart';
import 'package:doc_sys_pro/personsTab/editPerson.dart';
import 'package:doc_sys_pro/utils.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:doc_sys_pro/models/person.dart';


class DocumentsTab extends StatefulWidget {
  @override
  _DocumentsTabState createState() => _DocumentsTabState();
}


class _DocumentsTabState extends State<DocumentsTab> {
  late Box<Document> _documentsBox;
  List<Document> _documentsList = [];
  late Map<int, bool> _checkBoxValues = generateCheckBoxBitMap(mode: "documents");
  bool _isDeleteClicked = false;
  bool _isEditClicked = false;
  bool _isViewClicked = false;

  bool _checkBoxVisibility = false;


  Future getDataFromBox() async {
    _documentsBox = await Hive.openBox('documents');
    _documentsList = _documentsBox.values.toList();
  }


  void _deleteDocument(int index) {
    setState(() {
      _documentsBox.deleteAt(index);
      _documentsList.removeAt(index);
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
                    title: const Text('Документи'),
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

                  body: ListView.builder(
                      itemCount: _documentsList.length,
                      itemBuilder: (context, index) {

                        if (_checkBoxVisibility) {
                          return CheckboxListTile(
                            title: Text(_documentsList[index].name),
                            subtitle: Text(_documentsList[index].type),
                            value: _checkBoxValues[index],
                            
                            shape: const Border(
                              bottom: BorderSide(color: Color.fromARGB(184, 0, 0, 0)),
                            ),

                            onChanged: (value) {
                              setState(() {
                                _checkBoxValues[index] = value!;
                              });
                            },
                          );
                          
                        } else {
                          
                          return ExpansionTile(
                            backgroundColor: Color.fromARGB(70, 144, 144, 144),
                            expandedCrossAxisAlignment: CrossAxisAlignment.start,
                            expandedAlignment: Alignment.centerLeft,
                            childrenPadding: const EdgeInsets.fromLTRB(73, 0, 0, 20),
                            title: Text(_documentsList[index].name),
                            subtitle: Text(_documentsList[index].type),
                            controlAffinity: ListTileControlAffinity.leading,
                            children: [
                              SelectableText('Номер: ${_documentsList[index].number}'),
                              SelectableText('Дата: ${_documentsList[index].date}'),
                              SelectableText('Посилання: ${_documentsList[index].imagePath}'),
                            ],
                          );

                        }

                      }),

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
                                builder: (context) => AddDocument()));
                      }
                    }
                  )
              );
            }
        });
  }
}
