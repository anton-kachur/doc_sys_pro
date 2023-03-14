import 'package:doc_sys_pro/main.dart';
import 'package:doc_sys_pro/models/person.dart';
import 'package:doc_sys_pro/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';


class PersonSettings extends StatefulWidget {
  final int index;

  PersonSettings({required this.index});

  @override
  _PersonSettingsState createState() => _PersonSettingsState();
}

class _PersonSettingsState extends State<PersonSettings> {
  late Box<Person> _personsBox;
  Map<String, Object> fieldValues = {
    'firstName': '',
    'lastName': '',
    'age': '',
    'gender': '',
    'address': '',
    'phoneNumber': '',
  };

  Future _getDataFromBox() async {
    _personsBox = await Hive.openBox('personas');
  }

  void _addPerson(Person person) {
    setState(() {
      _personsBox.add(person);
    });
  }

  void _editPerson() {
    _personsBox.putAt(
        widget.index,
        Person(
            firstName: fieldValues['firstName'] == ''
                ? _personsBox.getAt(widget.index)!.firstName
                : '${fieldValues['firstName']}',
            lastName: fieldValues['lastName'] == ''
                ? _personsBox.getAt(widget.index)!.lastName
                : '${fieldValues['lastName']}',
            age: fieldValues['age'] == ''
                ? _personsBox.getAt(widget.index)!.age
                : int.parse('${fieldValues['age']}'),
            gender: fieldValues['gender'] == ''
                ? _personsBox.getAt(widget.index)!.gender
                : '${fieldValues['gender']}',
            address: fieldValues['address'] == ''
                ? _personsBox.getAt(widget.index)!.address
                : '${fieldValues['address']}',
            phoneNumber: fieldValues['phoneNumber'] == ''
                ? _personsBox.getAt(widget.index)!.phoneNumber
                : '${fieldValues['phoneNumber']}',
            person_id: _personsBox.getAt(widget.index)!.person_id
        ));
  }

  void redirect() {
    Navigator.pop(context, false);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    var boxData = _getDataFromBox();

    return FutureBuilder(
        future: boxData, // data retreived from database
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return waitingOrErrorWindow('Зачекайте...', context);
          } else {
            if (snapshot.hasError) {
              return waitingOrErrorWindow(
                  'Помилка: ${snapshot.error}', context);
            } else {
              return Scaffold(
                  appBar: AppBar(
                    toolbarHeight: 60,
                    title: const Text('Редагувати дані'),
                    centerTitle: true,
                    backgroundColor: const Color.fromARGB(255, 40, 40, 40),
                  ),
                  
                  body: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        textFieldsBlock(),
                      ]
                    ),
                  ),

                  floatingActionButton: FloatingActionButton.large(
                    backgroundColor: const Color.fromARGB(255, 58, 58, 58),
                    child: const Icon(Icons.edit_rounded),
                    onPressed: () {
                      _editPerson();
                      redirect();
                    }
                  )
              );
            }
          }
        });
  }

  Widget textFieldsBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, 
      children: [
        Column(
            children: [
              
              textField(
                  TextInputAction.next,
                  'Ім\'я',
                  TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  TextInputType.text,
                  null,
                  String,
                  inputValue: 'firstName'),
              
              const SizedBox(height: 8),
              
              textField(TextInputAction.next, 'Прізвище', null, null,
                  TextInputType.text, null, String,
                  inputValue: 'lastName'),
              
              const SizedBox(height: 8),
              
              textField(
                  TextInputAction.next,
                  'Вік',
                  null,
                  null,
                  TextInputType.number,
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  String,
                  inputValue: 'age'),
              
              const SizedBox(height: 8),
              
              textField(TextInputAction.next, 'Стать', null, null,
                  TextInputType.text, null, String,
                  inputValue: 'gender'),
              
              const SizedBox(height: 8),
              
              textField(TextInputAction.newline, 'Адреса', null, null,
                  TextInputType.multiline, null, String,
                  inputValue: 'address'),
              
              const SizedBox(height: 8),

              textField(TextInputAction.done, 'Номер телефона', null, null,
                  TextInputType.phone, null, String,
                  inputValue: 'phoneNumber'),
            ]
          ),
    ]);
  }


  Widget textField(
      TextInputAction? textInputAction,
      String labelText,
      TextStyle? hintStyle,
      TextStyle? labelStyle,
      TextInputType? keyboardType,
      TextInputFormatter? inputFormatters,
      Type? parseType,
      {required String inputValue}
    ) {
    
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        width: 320,
        child: TextFormField(
            autofocus: false,
            textInputAction: textInputAction,
            keyboardType: keyboardType,
            inputFormatters: [if (inputFormatters != null) inputFormatters],
            maxLines: inputValue == 'address' ? null : 1,
            autocorrect: true,
            enableSuggestions: true,
            cursorRadius: const Radius.circular(9.0),
            cursorColor: Colors.black,
            
            decoration: InputDecoration(
              labelText: labelText,
              hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              labelStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.fromLTRB(9, 0, 0, 0),
              focusedBorder: textFieldStyle,
              enabledBorder: textFieldStyle,
            ),
            
            onChanged: (String value) {
              fieldValues[inputValue] = value;
            }
        )
    );
  }
}
