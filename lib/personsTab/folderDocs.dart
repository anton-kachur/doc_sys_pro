import 'dart:io';

import 'package:doc_sys_pro/documentsTab/addDocument.dart';
import 'package:doc_sys_pro/documentsTab/editDocument.dart';
import 'package:doc_sys_pro/documentsTab/movePage.dart';
import 'package:doc_sys_pro/models/document.dart';
import 'package:doc_sys_pro/models/folder.dart';
import 'package:doc_sys_pro/utils.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';


/* Class which creates a Tab with user's documetns */
class FolderDocs extends StatefulWidget {
  final String folderIndex;
  Map<String, String?> userData;

  FolderDocs({super.key, required this.folderIndex, required this.userData});

  @override
  _FolderDocsState createState() => _FolderDocsState();
}

class _FolderDocsState extends State<FolderDocs> {
  late Box<Document> _documentsBox;
  List<Document> _documentsList = [];

  late Box<Folder> _foldersBox;
  late String _folderName;

  // Show documents, located in current folder
  Future getDataFromBoxes() async {
    _documentsBox = await Hive.openBox('your_documents');
    _foldersBox = await Hive.openBox('your_folders');

    // retreive folder from DB by its index
    var folder = _foldersBox.getAt(int.parse(widget.folderIndex));
    _folderName = folder!.name;

    for (var value in folder.docsInFolder) {
      for (var document in _documentsBox.values) {
        if (value['name'] == document.name && 
        value['number'] == document.number) {
          if (_documentsList.contains(document)) {
            break;
          } else {
            _documentsList.add(document);
          }
        }
      }
    }
  }

  // Delete document from folder and DB
  void _deleteDocument(int index) {
    setState(() {
      _documentsBox.deleteAt(index);
      _documentsList.removeAt(index);
    });
  }

  // Display scrollable list of documents in current folder
  Widget createItemsList(String mode) {
    return Flexible(
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color.fromARGB(255, 25, 25, 25),
              width: 0.7
            )
          )
        ),

        child: ListView.builder(
          itemCount: _documentsList.length,
          itemBuilder: (context, index) {
              
            return ListTileTheme(
              child: ExpansionTile(
                trailing: const Icon(Icons.description_rounded),
                backgroundColor: const Color.fromARGB(70, 144, 144, 144),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                expandedAlignment: Alignment.centerLeft,
                childrenPadding: const EdgeInsets.fromLTRB(73, 0, 0, 10),
                title: Text(_documentsList[index].name),
                subtitle: Text(_documentsList[index].type),
                controlAffinity: ListTileControlAffinity.leading,
                children: [
                  SelectableText('Номер документа: ${_documentsList[index].docNumber}'),
                  SelectableText('Виданий: ${_documentsList[index].dateFrom.day}-${_documentsList[index].dateFrom.month}-${_documentsList[index].dateFrom.year}'),
                  SelectableText('До: ${_documentsList[index].dateTo.day}-${_documentsList[index].dateTo.month}-${_documentsList[index].dateTo.year}'),
                  SelectableText('Опис: ${_documentsList[index].description}'),
                  
                  if (_documentsList[index].image != '')
                    Container(
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
                          _deleteDocument(index);  
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                DocumentSettings(index: index, userData: widget.userData)));
                        },
                      ),

                      const SizedBox(width: 10),

                      // Move document button
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

  @override
  Widget build(BuildContext context) {
    var boxData = getDataFromBoxes();  // data retreived from database

    return FutureBuilder(
        future: boxData, 
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          
            if (snapshot.hasError) {
              return waitingOrErrorWindow('Помилка: ${snapshot.error}', context);
            } else {
              return Scaffold(
                
                  appBar: AppBar(
                    toolbarHeight: 60,
                    title: Text(_folderName),
                    backgroundColor: const Color.fromARGB(255, 40, 40, 40),
                    actions: [
                      CircleAvatar(
                        backgroundImage: Image.network(widget.userData['avatar'] ?? '').image,
                        radius: 18,
                      ),

                      const SizedBox(width: 15),
                    ],
                  ),

                  body: _documentsList.isEmpty? 
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      child: Text('Тека порожня'),
                    ) :
                    
                    Column(
                      children: [
                        createItemsList('documents')
                      ],
                    ),

                  floatingActionButton: FloatingActionButton.large(
                    backgroundColor: const Color.fromARGB(255, 58, 58, 58),
                    child: const Icon(Icons.add_rounded),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddDocument(userData: widget.userData)));
                    }
                  )
              );
            }
        });
  }
}