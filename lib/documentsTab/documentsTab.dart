import 'dart:io';

import 'package:doc_sys_pro/documentsTab/addDocument.dart';
import 'package:doc_sys_pro/documentsTab/editDocument.dart';
import 'package:doc_sys_pro/documentsTab/movePage.dart';
import 'package:doc_sys_pro/main.dart';
import 'package:doc_sys_pro/models/document.dart';
import 'package:doc_sys_pro/models/folder.dart';
import 'package:doc_sys_pro/personsTab/folderDocs.dart';
import 'package:doc_sys_pro/utils.dart';
import 'package:flutter/material.dart';
import 'package:folding_menu/folding_menu.dart';
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

  late Box<Folder> _foldersBox;
  List<Folder> _foldersList = [];

  final TextEditingController _textFieldController = TextEditingController();
  bool openMenu = false;

  // Retreive all avalialbe user's documents and folders
  Future _getDataFromBoxes() async {
    _documentsBox = await Hive.openBox('your_documents');
    _foldersBox = await Hive.openBox('your_folders');

    for (var item in _foldersBox.values) {
      if (widget.userData['id'] == item.number) {
        if (_foldersList.contains(item)) {
          break;
        } else {
          _foldersList.add(item);
        }
      }
    }
    
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

  // Create new folder's name
  void _addFolder() {

    Map isAllCorrect = folderIsInDB(foldersList: _foldersList, name: 'Нова тека');
    
    _foldersBox.add(
      Folder(
        name: isAllCorrect['all_correct'] == true ? 'Нова тека' : 'Нова тека',
        number: widget.userData['id'] as String,
        docsInFolder: [{}]  
    ));

    redirect(context: context, userData: widget.userData);
  }

  // Delete document from DB
  void _deleteDocument(int index) {
    setState(() {
      _documentsBox.deleteAt(index);
      _documentsList.removeAt(index);
    });
  }

  // Delete folder from DB
  void _deleteFolder(int index) {
    setState(() {
      _foldersBox.deleteAt(index);
      _foldersList.removeAt(index);
    });
  }

  // Save new folder's name
  void _saveChanges(int folderIndex) {
    _foldersBox.putAt(
        folderIndex,
        Folder(
            name: _textFieldController.text == ''
                ? _foldersBox.getAt(folderIndex)!.name
                : _textFieldController.text,
            number: _foldersBox.getAt(folderIndex)!.number,
            docsInFolder: _foldersBox.getAt(folderIndex)!.docsInFolder  
      ));
  }

  // Change name of some folder via alert dialog with textfield
  Future<void> changeFolderName(BuildContext context, int folderIndex) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          content: TextField(
            onChanged: (value) {
              setState(() {
                _foldersList[folderIndex].name = value;
              });
            },
            controller: _textFieldController,
            decoration: InputDecoration(
              labelText: 'Введіть нову назву папки',
              hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              labelStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.fromLTRB(9, 0, 0, 0),
              focusedBorder: textFieldStyle,
              enabledBorder: textFieldStyle,
            ),
          ),

          actions: [

            // Cancel button
            MaterialButton(
              color: const Color.fromARGB(255, 25, 25, 25),
              textColor: Colors.white,
              child: const Text('Відмінити'),
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
            ),

            // Accept button
            MaterialButton(
              color: const Color.fromARGB(255, 25, 25, 25),
              textColor: Colors.white,
              child: const Text('Прийняти'),
              onPressed: () {
                setState(() {
                  _saveChanges(folderIndex);
                  Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => HomeScreen(widget.userData, currentIndex: 1)));
                });
              },
            ),

          ],
        );
      });
  }

  // Display scrollable list of user's folders and documents
  Widget createItemsList(String mode) {
    return Flexible(
      child: Container(
        
        child: ListView.builder(
          itemCount: mode == 'folders' ? _foldersList.length : _documentsList.length,
          itemBuilder: (context, index) {
              
            return ListTileTheme(
              child: ExpansionTile(
                trailing: Icon(mode == 'folders' ? Icons.folder_rounded : Icons.description_rounded),
                backgroundColor: const Color.fromARGB(70, 144, 144, 144),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                expandedAlignment: Alignment.centerLeft,
                childrenPadding: const EdgeInsets.fromLTRB(73, 0, 0, 10),
                title: Text(mode == 'folders' ? _foldersList[index].name : _documentsList[index].name),
                subtitle: Text(mode == 'folders' ? '' : _documentsList[index].type),
                controlAffinity: ListTileControlAffinity.leading,
                children: [
                  if (mode == 'documents') SelectableText('Номер документа: ${_documentsList[index].docNumber}'),
                  if (mode == 'documents') SelectableText('Виданий: ${_documentsList[index].dateFrom.day}-${_documentsList[index].dateFrom.month}-${_documentsList[index].dateFrom.year}'),
                  if (mode == 'documents') SelectableText('До: ${_documentsList[index].dateTo.day}-${_documentsList[index].dateTo.month}-${_documentsList[index].dateTo.year}'),
                  if (mode == 'documents') SelectableText('Опис: ${_documentsList[index].description}'),
                  if (mode == 'documents') 
                    if (_documentsList[index].image != '')
                      SizedBox(
                        height: 200,
                        width: 308,
                        child: Image.file(
                          File(_documentsList[index].image),
                          fit: BoxFit.cover,
                        ),
                      ),

                  Row(
                    children: [
                      
                      // Delete button
                      ActionChip(
                        backgroundColor: const Color.fromARGB(255, 62, 62, 62),
                        label: const Text(
                          'Видалити', 
                          style: TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.normal
                          )
                        ),

                        onPressed: () {
                          mode == 'folders' ? _deleteFolder(index) : _deleteDocument(index);  
                        },
                      ),  

                      const SizedBox(width: 10),

                      // Edit button
                      ActionChip(
                        backgroundColor: const Color.fromARGB(255, 62, 62, 62),
                        label: const Text(
                          'Редагувати', 
                          style: TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.normal
                          )
                        ),
                        
                        onPressed: () {
                          if (mode == 'folders') {
                            changeFolderName(context, index);
                          } else {
                            Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                DocumentSettings(index: index, userData: widget.userData)));
                          }
                        },
                      ),

                      const SizedBox(width: 10),

                      // View button (for folders)
                      if (mode == 'folders')
                        ActionChip(
                          backgroundColor: const Color.fromARGB(255, 62, 62, 62),
                          label: const Text(
                            'Відкрити', 
                            style: TextStyle(
                              color: Colors.white, 
                              fontWeight: FontWeight.normal
                            )
                          ),
                          
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => 
                                FolderDocs(folderIndex: '$index', userData: widget.userData)
                              )
                            );
                          },
                        ),

                      // Move document button
                      if (mode == 'documents')
                        ActionChip(
                          backgroundColor: const Color.fromARGB(255, 62, 62, 62),
                          label: const Text(
                            'Перемістити', 
                            style: TextStyle(
                              color: Colors.white, 
                              fontWeight: FontWeight.normal
                            )
                          ),
                          
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => 
                                MovePage(documentIndex: index, userData: widget.userData)
                              )
                            );
                          },
                        ),
                    ],
                  )

                ],
              )
            );
          }
        ),
      )
    );
  }  

  // Search bar for documents
  Widget searchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      width: 300,
      child: TextFormField(
        autofocus: false,
        textInputAction: TextInputAction.search,
        keyboardType: TextInputType.text,
        maxLines: 1,
        autocorrect: true,
        enableSuggestions: true,
        cursorRadius: const Radius.circular(9.0),
        cursorColor: Colors.black,
        
        decoration: InputDecoration(
          labelText: "Шукати документ...",
          hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          labelStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          contentPadding: const EdgeInsets.fromLTRB(9, 0, 0, 0),
          focusedBorder: textFieldStyle,
          enabledBorder: textFieldStyle,
        ),
        
        onFieldSubmitted: (String value) {
          setState(() {
            _documentsList = searchForDocs(value, _documentsList);
          });  
        },
      )
    );
  }


  @override
  Widget build(BuildContext context) {
    var boxData = _getDataFromBoxes();  // data retreived from database

    return FutureBuilder(
        future: boxData, 
        builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return waitingOrErrorWindow('Помилка: ${snapshot.error}', context);
            } else {
              return Scaffold(
                  appBar: AppBar(
                    toolbarHeight: 60,
                    title: const Text('Мої документи'),
                    backgroundColor: const Color.fromARGB(255, 40, 40, 40),
                    
                    actions: [

                      IconButton(
                        icon: const Icon(Icons.add_box_rounded),
                        onPressed: () {
                          setState(() {
                            openMenu = !openMenu;
                          });
                        }
                      ),

                      const SizedBox(width: 15),

                      CircleAvatar(
                        backgroundImage: Image.network(widget.userData['avatar'] ?? '').image,
                        radius: 18,
                      ),

                      const SizedBox(width: 15),
                    ],
                  ),

                  drawer: Drawer(
                    child: Column(
                      children: [
                        searchBar(),
                        _documentsList.isNotEmpty ? createItemsList('documents') : const Text(''),
                      ],
                    )
                  ),
                  
                  body: _documentsList.isEmpty && _foldersList.isEmpty ? 
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      child: Text('У вас немає жодного документа'),
                    ) :
                    
                    Column(
                      children: [

                        // Show list of folders
                        _foldersList.isNotEmpty ? createItemsList('folders') : const Text(''),
                        //_documentsList.isNotEmpty ? createItemsList('documents') : const Text(''),
                        
                        // Dropdown menu with options "Add document" & "Add folder"
                        FoldingMenu(
                          duration: Duration(milliseconds: 900), 
                          shadowColor: Colors.transparent, 
                          animationCurve: Curves.decelerate, 
                          folded: openMenu, 
                          
                          children: [
                            // Add document button
                            Padding(
                              padding: const EdgeInsets.fromLTRB(180, 15, 15, 10),
                              child: FloatingActionButton.extended(
                                label: const Text('Створити документ'),
                                splashColor: Colors.transparent,
                                backgroundColor: const Color.fromARGB(255, 58, 58, 58),
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddDocument(userData: widget.userData)));
                                }
                              ),
                            ),


                            // Add folder button TODO
                            Padding(
                              padding: const EdgeInsets.fromLTRB(220, 15, 15, 10),
                              child: FloatingActionButton.extended(
                                
                                label: const Text('Створити теку'),
                                splashColor: Colors.transparent,
                                backgroundColor: const Color.fromARGB(255, 58, 58, 58),
                                icon: const Icon(Icons.create_new_folder_rounded),

                                onPressed: () {
                                  _addFolder();
                                }
                              )
                            ),
                          ]
                        ),

                      ],
                    ),

              );
            }
        });
  }
}
