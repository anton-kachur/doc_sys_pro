import 'package:doc_sys_pro/main.dart';
import 'package:doc_sys_pro/models/document.dart';
import 'package:doc_sys_pro/models/person.dart';
import 'package:doc_sys_pro/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';


class AddDocument extends StatefulWidget {
  String curr_id;

  AddDocument({this.curr_id = ''});

  @override
  _AddDocumentState createState() => _AddDocumentState();
}

class _AddDocumentState extends State<AddDocument> {
  late Box<Document> _documentsBox;
  Map<String, Object> fieldValues = {
    'name': '',
    'type': '',
    'number': '',
    'date': '',
    'imagePath': '',
  };

  Future _getDataFromBox() async {
    _documentsBox = await Hive.openBox('documents');
  }

  void _addDocument() {
    List<String> formattedDate = '${fieldValues['date']}'.split('-');
    _documentsBox.add(
        Document(
            name: '${fieldValues['name']}',
            type: '${fieldValues['type']}',
            number: widget.curr_id == ''? '${fieldValues['number']}' : widget.curr_id,
            date: DateTime(
              int.parse(formattedDate.elementAt(2)),
              int.parse(formattedDate.elementAt(1)),
              int.parse(formattedDate.elementAt(0)),
            ),
            imagePath: '${fieldValues['imagePath']}'));
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
                    title: const Text('Додати документ'),
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
                    child: const Icon(Icons.add_rounded),
                    onPressed: () {
                      _addDocument();
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
                  'Назва',
                  TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  TextInputType.text,
                  null,
                  String,
                  inputValue: 'name'),
              
              const SizedBox(height: 8),
              
              textField(
                  TextInputAction.newline, 
                  'Тип документу', 
                  null, 
                  null,
                  TextInputType.multiline, 
                  null, 
                  String,
                  inputValue: 'type'),
              
              const SizedBox(height: 8),
              
              if (widget.curr_id == '')
                textField(
                    TextInputAction.next,
                    'Номер',
                    null,
                    null,
                    TextInputType.text,
                    null,
                    String,
                    inputValue: 'number'),
              
              const SizedBox(height: 8),
              
              textField(
                  TextInputAction.next, 
                  'Дата (дд-мм-рррр)', 
                  null, 
                  null,
                  TextInputType.text,
                  null,
                  String,
                  inputValue: 'date'),
              
              const SizedBox(height: 8),
              
              textField(
                  TextInputAction.done, 
                  'Посилання', 
                  null, 
                  null,
                  TextInputType.text, 
                  null, 
                  String,
                  inputValue: 'imagePath'),
              
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
            maxLines: inputValue == 'type' ? null : 1,
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
