import 'package:doc_sys_pro/documentsTab/addDocument.dart';
import 'package:doc_sys_pro/documentsTab/editDocument.dart';
import 'package:doc_sys_pro/models/document.dart';
import 'package:doc_sys_pro/utils.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';


class DocumentsTab extends StatefulWidget {
  Map<String, String?> userData;

  DocumentsTab(this.userData);

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
    _documentsBox = await Hive.openBox('your_documents');

    for (var item in _documentsBox.values) {
      if (widget.userData['id'] == item.number) {
        if (_documentsList.contains(item)) {
          break;
        } else {
          _documentsList.add(item);
        }
      }
    }
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
                    automaticallyImplyLeading: false,
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

                  body: _documentsList.length == 0 ? 
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      child: Text('У вас немає жодного документа'),
                    ) :
                    ListView.builder(
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
                            backgroundColor: const Color.fromARGB(70, 144, 144, 144),
                            expandedCrossAxisAlignment: CrossAxisAlignment.start,
                            expandedAlignment: Alignment.centerLeft,
                            childrenPadding: const EdgeInsets.fromLTRB(73, 0, 0, 20),
                            title: Text(_documentsList[index].name),
                            subtitle: Text(_documentsList[index].type),
                            controlAffinity: ListTileControlAffinity.leading,
                            children: [
                              SelectableText('Id користувача: ${_documentsList[index].number}'),
                              SelectableText('Номер документа: ${_documentsList[index].docNumber}'),
                              SelectableText('Виданий: ${_documentsList[index].dateFrom.day}-${_documentsList[index].dateFrom.month}-${_documentsList[index].dateFrom.year}'),
                              SelectableText('До: ${_documentsList[index].dateTo.day}-${_documentsList[index].dateTo.month}-${_documentsList[index].dateTo.year}'),
                              SelectableText('Опис: ${_documentsList[index].description}'),
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
                                    DocumentSettings(index: entry.key, userData: widget.userData)));
                            break;
                          }
                        }
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddDocument(userData: widget.userData)));
                      }
                    }
                  )
              );
            }
        });
  }
}
