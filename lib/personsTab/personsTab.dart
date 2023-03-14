import 'package:doc_sys_pro/personsTab/addPerson.dart';
import 'package:doc_sys_pro/personsTab/editPerson.dart';
import 'package:doc_sys_pro/personsTab/personDocs.dart';
import 'package:doc_sys_pro/utils.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:doc_sys_pro/models/person.dart';


class PersonsTab extends StatefulWidget {
  @override
  _PersonsTabState createState() => _PersonsTabState();
}


class _PersonsTabState extends State<PersonsTab> {
  late Box<Person> _personsBox;
  List<Person> _personsList = [];
  late Map<int, bool> _checkBoxValues = generateCheckBoxBitMap(mode: "persons");
  bool _isDeleteClicked = false;
  bool _isEditClicked = false;
  bool _isViewClicked = false;

  bool _checkBoxVisibility = false;


  Future getDataFromBox() async {
    _personsBox = await Hive.openBox('personas');
    _personsList = _personsBox.values.toList();
  }


  void _deletePerson(int index) {
    setState(() {
      _personsBox.deleteAt(index);
      _personsList.removeAt(index);
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
                    title: const Text('Особисті дані'),
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
                          Icons.person_remove, 
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
                          Icons.person_search_rounded, 
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
                      itemCount: _personsList.length,
                      itemBuilder: (context, index) {

                        if (_checkBoxVisibility) {
                          return CheckboxListTile(
                            title: Text(_personsList[index].firstName),
                            subtitle: Text(_personsList[index].lastName),
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
                            title: Text(_personsList[index].firstName),
                            subtitle: Text(_personsList[index].lastName),
                            controlAffinity: ListTileControlAffinity.leading,
                            children: [
                              SelectableText('Id в системі: ${_personsList[index].person_id}'),
                              SelectableText('Вік: ${_personsList[index].age}'),
                              SelectableText('Стать: ${_personsList[index].gender}'),
                              SelectableText('Адреса: ${_personsList[index].address}'),
                              SelectableText('Телефон: ${_personsList[index].phoneNumber}'),
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
                          if (entry.value == true) _deletePerson(entry.key);
                        }
                      } else if (_isEditClicked) {
                        for (MapEntry<int, bool> entry in _checkBoxValues.entries) {
                          if (entry.value == true) {
                            Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PersonSettings(index: entry.key)));
                            break;
                          }
                        }
                      } else if (_isViewClicked) {
                        for (MapEntry<int, bool> entry in _checkBoxValues.entries) {
                          if (entry.value == true) {
                            Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PersonDocs(index: entry.key)));
                            break;
                          }
                        } 
                      }else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddPerson()));
                      }
                    }
                  )
              );
            }
        });
  }
}
