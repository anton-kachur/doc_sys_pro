import 'package:doc_sys_pro/main.dart';
import 'package:doc_sys_pro/models/document.dart';
import 'package:doc_sys_pro/models/folder.dart';
import 'package:flutter/material.dart';

late int docsBoxLength;
late int foldersBoxLength;

// Check document number input value
String checkDocumentNumber(String string) {
  if (string.length < 9 || string == '') return 'len_error';

  int numOfDigits = 0;

  for (String char in string.split('')) {
    if (RegExp(r'[0-9]').hasMatch(char)) {
      numOfDigits += 1;
    }
  }

  if (numOfDigits < string.length) return 'symbol_error';
  
  return 'all_correct';
}

// Check document input when it is created
Map addDocInputCheck({ 
    required Map<String, Object> input, 
    required List<Document> documentsList,
    required List<String> dateFrom, 
    required List<String> dateTo
  }) {

  Map messages = {'all_correct' : false};

  var dateToParseResult = DateTime.tryParse('${dateTo.elementAt(2)}-${dateTo.elementAt(1)}-${dateTo.elementAt(0)}');
  var dateFromParseResult = DateTime.tryParse('${dateFrom.elementAt(2)}-${dateFrom.elementAt(1)}-${dateFrom.elementAt(0)}');

  for (Document document in documentsList) {
    if (document.name == input['name']) {
      input['name'] = '${document.name} (${documentsList.length - (documentsList.length - 1)})';
    }
    if (document.type == input['type']) {
      messages.addAll({
        'type_error' : '- Документ такого типу вже існує!',
      });
    }
    if (document.docNumber == input['docNumber']) {
      messages.addAll({
        'number_error' : '- Документ з таким номером вже існує!',
      });
    }
    
    String docNumberCheck = checkDocumentNumber('${input['docNumber']}');

    if (docNumberCheck == 'len_error') {
      messages.addAll({
        'doc_number_length_error' : '- Номер документа має складатися з 9 цифр!',
      });
    } 
    if (docNumberCheck == 'symbol_error') {
      messages.addAll({
        'wrong_symbols_in_number_error' : '- Номер документа має складатися з цифр!',
      });
    }
    
    if (dateFrom.length < 2 || dateFromParseResult == null) {
      messages.addAll({
        'dateFrom_error' : '- Неправильно введена дата видачі!',
      });
    }
    if (dateTo.length < 2 || dateToParseResult == null) {
      messages.addAll({
        'dateTo_error' : '- Неправильно введена дата закінчення!',
      });
    }
    if (dateFromParseResult != null && dateToParseResult != null) {
      if ((dateToParseResult.difference(dateFromParseResult)).inDays <= 0) {
        messages.addAll({
          'date_diff_error' : '- Дата видачі повинна бути менше дати закінчення!',
        });
      }
    }
  }

  messages['all_correct'] = messages.length == 1 ? true : false;

  return messages;
}

// Check document input when it is edited
Map editDocInputCheck({ 
    required Map<String, Object> input, 
    required List<Document> documentsList,
    required List<String> dateFrom, 
    required List<String> dateTo
  }) {

  Map messages = {'all_correct' : false};
  
  var dateToParseResult = input['dateTo'] == '' ? null : DateTime.tryParse('${dateTo.elementAt(2)}-${dateTo.elementAt(1)}-${dateTo.elementAt(0)}');
  var dateFromParseResult = input['dateFrom'] == '' ? null : DateTime.tryParse('${dateFrom.elementAt(2)}-${dateFrom.elementAt(1)}-${dateFrom.elementAt(0)}');
  
  for (Document document in documentsList) {
    if (document.name == input['name'] && input['name'] != '') {
      input['name'] = '${document.name} (${documentsList.length - (documentsList.length - 1)})';
    }
    if (document.type == input['type'] && input['type'] != '') {
      messages.addAll({
        'type_error' : '- Документ такого типу вже існує!',
      });
    }
    if (document.docNumber == input['docNumber'] && input['docNumber'] != '') {
      messages.addAll({
        'number_error' : '- Документ з таким номером вже існує!',
      });
    }
    
    String docNumberCheck =  input['docNumber'] == ''? '' : checkDocumentNumber('${input['docNumber']}');

    if (docNumberCheck == 'len_error') {
      messages.addAll({
        'doc_number_length_error' : '- Номер документа має складатися з 9 цифр!',
      });
    } 
    if (docNumberCheck == 'symbol_error') {
      messages.addAll({
        'wrong_symbols_in_number_error' : '- Номер документа має складатися з цифр!',
      });
    }
    
    if (input['dateFrom'] != '') {
      if ((dateFrom.length < 2 || dateFromParseResult == null)) {
        messages.addAll({
          'dateFrom_error' : '- Неправильно введена дата видачі!',
        });
      }
    }
    
    if (input['dateFrom'] != '') {
      if ((dateTo.length < 2 || dateToParseResult == null)) {
        messages.addAll({
          'dateTo_error' : '- Неправильно введена дата закінчення!',
        });
      }
    }

    if (dateFromParseResult != null && dateToParseResult != null) {
      if ((dateToParseResult.difference(dateFromParseResult)).inDays <= 0) {
        messages.addAll({
          'date_diff_error' : '- Дата видачі повинна бути менше дати закінчення!',
        });
      }
    }
  }

  messages['all_correct'] = messages.length == 1 ? true : false;

  return messages;
}

// Check if folder already exists
Map folderIsInDB({
  required List<Folder> foldersList,
  required String name
  }) {

  Map message = {'all_correct' : true};

  for (Folder folder in foldersList) {
    if (folder.name == name) {
      message['all_correct'] = false;
    }
  }

  return message;
}

// Returns true if document already exists in any of available folders
bool isInAnyFolder({
  required Document document, 
  required List<Folder> foldersList
}) {
  for (Folder folder in foldersList) {
    for (Map<String, String> fd in folder.docsInFolder) {
      if (
        fd['name'] == document.name && 
        fd['number'] == document.number &&
        fd['type'] == document.type
      ) {
        return true;
      }
    }
  }

  return false;
}

// Redirect user back to documents' tab on home page
void redirect({required BuildContext context, required Map<String, String?> userData}) {
  Navigator.pop(context, false);
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => HomeScreen(userData, currentIndex: 1)));
}

// Create false values for checkboxes (documents and folders)
Map<int, bool> generateCheckBoxBitMap({String? mode}) {
  Map<int, bool> map = {};
  for (int i = 0; i<(mode == "folders" ? foldersBoxLength : docsBoxLength); i++) {
    map[i] = false;
  }

  return map;
}

// Window which appears when it is error or loading
Widget waitingOrErrorWindow(var text, var context) {
  return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            130, MediaQuery.of(context).size.height / 2, 0.0, 0.0),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 20,
              decoration: TextDecoration.none,
              color: Colors.black),
        ),
      ));
}

OutlineInputBorder textFieldStyle = OutlineInputBorder(
  borderRadius: const BorderRadius.all(Radius.circular(4.0)),
  borderSide: BorderSide(color: Colors.grey.shade700, width: 1.5),
);

// Alert in case of error
void alert(BuildContext context, Map messages) {

  int height = (messages.length - 1)*50;

  showDialog(
    context: context,
    builder: (context) =>  
      AlertDialog(
        title: Text('Помилк${messages.length-1 > 0 ? 'и' : 'а'} вводу'),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        content: Container(
          height: height.toDouble(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var entry in messages.entries)
                if (entry.key != 'all_correct')
                  Text(entry.value)
            ],
          ),
        ),

        actions: [
          MaterialButton(
            color: const Color.fromARGB(255, 25, 25, 25),
            textColor: Colors.white,
            child: const Text('Прийняти'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      )
  );
}

// Search for documents in DB by name
List<Document> searchForDocs(String value, List documentsList) {
  List<Document> results = [];

  for (Document document in documentsList) {
    if (document.name == value) {
      results.add(document);
    }
  }

  print("DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD: ${results}");
  return results;
}