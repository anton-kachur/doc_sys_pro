import 'package:doc_sys_pro/models/document.dart';
import 'package:doc_sys_pro/models/folder.dart';
import 'package:doc_sys_pro/utils.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';


class MovePage extends StatefulWidget {
  final int documentIndex;
  Map<String, String?> userData;

  MovePage({super.key, required this.documentIndex, required this.userData});

  @override
  _MovePageState createState() => _MovePageState();
}

class _MovePageState extends State<MovePage> {
  late Box<Document> _documentsBox;
  List<Document> _documentsList = [];
  
  late Box<Folder> _foldersBox;
  List<Folder> _foldersList = [];


  // Show documents, located in current folder
  Future getDataFromBoxes() async {
    _documentsBox = await Hive.openBox('your_documents');
    _foldersBox = await Hive.openBox('your_folders');

    for (var item in _documentsBox.values) {
      if (widget.userData['id'] == item.number) {
        if (_documentsList.contains(item)) {
          break;
        } else {
          _documentsList.add(item);
        }
      }
    }
    
    for (var item in _foldersBox.values) {
      if (widget.userData['id'] == item.number) {
        if (_foldersList.contains(item)) {
          break;
        } else {
          _foldersList.add(item);
        }
      }
    } 

  }

  // Create a new document with field values and add it to DB
  void _moveDocToFolder(int folderIndex, int documentIndex) {
    _foldersBox.putAt(
      folderIndex,
      Folder(
        name: _foldersBox.getAt(folderIndex)!.name,
        number: widget.userData['id'] ?? '',
        docsInFolder: [
          {
            'name' : _documentsList.elementAt(documentIndex).name,
            'type' : _documentsList.elementAt(documentIndex).type,
            'number' : _documentsList.elementAt(documentIndex).number,
          }
        ]
      ));

      redirect(context: context, userData: widget.userData);
  }

  // Display scrollable list of documents in current folder
  Widget createFoldersList() {
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
          itemCount: _foldersList.length,
          itemBuilder: (context, index) {
              
            return ListTileTheme(
              child: ExpansionTile(
                trailing: const Icon(Icons.description_rounded),
                backgroundColor: const Color.fromARGB(70, 144, 144, 144),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                expandedAlignment: Alignment.centerLeft,
                childrenPadding: const EdgeInsets.fromLTRB(73, 0, 0, 10),
                title: Text(_foldersList[index].name),
                controlAffinity: ListTileControlAffinity.leading,
                children: [
                  SelectableText('Id користувача: ${_foldersList[index].number}'),
                  
                  // Move button
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
                      _moveDocToFolder(index, widget.documentIndex);
                    },
                  ),
                  
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
                  title: const Text('Перемістити'),
                  backgroundColor: const Color.fromARGB(255, 40, 40, 40),
                  actions: [
                    CircleAvatar(
                      backgroundImage: Image.network(widget.userData['avatar'] ?? '').image,
                      radius: 18,
                    ),

                    const SizedBox(width: 15),
                  ],
                ),

                body: Column(
                  children: [
                    createFoldersList()
                  ],
                ),
              );
            }
        });
  }
}