import 'package:doc_sys_pro/main.dart';
import 'package:doc_sys_pro/models/document.dart';
import 'package:doc_sys_pro/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';


class AddDocument extends StatefulWidget {
  String curr_id;
  Map<String, String?> userData;

  AddDocument({this.curr_id = '', required this.userData});

  @override
  _AddDocumentState createState() => _AddDocumentState();
}

class _AddDocumentState extends State<AddDocument> {
  late Box<Document> _documentsBox;
  Map<String, Object> fieldValues = {
    'type': '',
    'number': '',
    'docNumber': '',
    'dateFrom': '',
    'dateTo': '',
    'image': '',
    'description': ''
  };

  Future _getDataFromBox() async {
    _documentsBox = await Hive.openBox('your_documents');
  }

  void _addDocument() {
    List<String> formattedDateFrom = '${fieldValues['dateFrom']}'.split('-');
    List<String> formattedDateTo = '${fieldValues['dateTo']}'.split('-');

    _documentsBox.add(
        Document(
            name: '${fieldValues['name']}',
            type: '${fieldValues['type']}',
            number: widget.curr_id,
            docNumber: '${fieldValues['docNumber']}',
            dateFrom: DateTime(
              int.parse(formattedDateFrom.elementAt(2)),
              int.parse(formattedDateFrom.elementAt(1)),
              int.parse(formattedDateFrom.elementAt(0)),
            ),
            dateTo: DateTime(
              int.parse(formattedDateTo.elementAt(2)),
              int.parse(formattedDateTo.elementAt(1)),
              int.parse(formattedDateTo.elementAt(0)),
            ),
            image: '${fieldValues['image']}',
            description: '${fieldValues['description']}'
        ));
  }

  void redirect() {
    Navigator.pop(context, false);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => HomeScreen(widget.userData)));
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
                  TextInputAction.next, 
                  'Тип документу', 
                  null, 
                  null,
                  TextInputType.text, 
                  null, 
                  String,
                  inputValue: 'type'),
              
              const SizedBox(height: 8),
              
              textField(
                TextInputAction.next,
                'Номер',
                null,
                null,
                TextInputType.text,
                null,
                String,
                inputValue: 'docNumber'),
              
              const SizedBox(height: 8),
              
              textField(
                  TextInputAction.next, 
                  'Дата видачі (дд-мм-рррр)', 
                  null, 
                  null,
                  TextInputType.text,
                  null,
                  String,
                  inputValue: 'dateFrom'),
              
              const SizedBox(height: 8),
              
              textField(
                  TextInputAction.next, 
                  'Дійсний до (дд-мм-рррр)', 
                  null, 
                  null,
                  TextInputType.text,
                  null,
                  String,
                  inputValue: 'dateTo'),
              
              const SizedBox(height: 8),

              textField(
                  TextInputAction.newline, 
                  'Опис', 
                  null, 
                  null,
                  TextInputType.multiline, 
                  null, 
                  String,
                  inputValue: 'description'),

              const SizedBox(height: 8),
              
              textField(
                  TextInputAction.done, 
                  'Посилання на фото', 
                  null, 
                  null,
                  TextInputType.text, 
                  null, 
                  String,
                  inputValue: 'image'),              
              
              const SizedBox(height: 8),
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
            maxLines: (inputValue == 'description') ? null : 1,
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
