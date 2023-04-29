import 'package:doc_sys_pro/models/document.dart';
import 'package:doc_sys_pro/models/folder.dart';
import 'package:doc_sys_pro/utils.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';


class AddDocument extends StatefulWidget {
  Map<String, String?> userData;

  AddDocument({required this.userData});

  @override
  _AddDocumentState createState() => _AddDocumentState();
}

class _AddDocumentState extends State<AddDocument> {
  late Box<Document> _documentsBox;
  List<Document> _documentsList = [];

  late Box<Folder> _foldersBox;

  Map<String, Object> fieldValues = {
    'name': '',
    'type': '',
    'docNumber': '',
    'dateFrom': '',
    'dateTo': '',
    'description': '',
    'image': '',
  }; // user input values

  // Get all user's documents from DB (Open boxes with documents and folders -->    
  // check if document id is similar to user id --if true--> add document to 
  // _documentList which will be used to represent documents)
  Future _getDataFromBox() async {
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
  }  
  
  // Create a new document with user inputs and add it to DB
  void _addDocument() {
    List<String> formattedDateFrom = '${fieldValues['dateFrom']}'.split('-');
    List<String> formattedDateTo = '${fieldValues['dateTo']}'.split('-');

    Map isAllCorrect = addDocInputCheck(
      input: fieldValues, 
      documentsList: _documentsList,
      dateFrom: formattedDateFrom, 
      dateTo: formattedDateTo
    ); // check if user inputs are correct

    if (isAllCorrect['all_correct'] == false) {
      alert(context, isAllCorrect);
    } else { // if user inputs are correct, then add document to DB
      _documentsBox.add(
        Document(
          name: '${fieldValues['name']}',
          type: '${fieldValues['type']}',
          number: widget.userData['id'] ?? '',
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

        List<Map<String, String>> docsInFolder = _foldersBox.get('unsorted')!.docsInFolder;
        docsInFolder.add(
          {
            'name' : '${fieldValues['name']}',
            'type' : '${fieldValues['type']}',
            'number' : widget.userData['id'] ?? '',
          }
        );

        _foldersBox.put(
          'unsorted',
          Folder(
            name: 'Невідсортоване',
            number: widget.userData['id'] ?? '',
            docsInFolder: docsInFolder
          )); // add document to 'unsorted folder'

        redirect(context: context, userData: widget.userData); // redirect to 'My documents' tab
    }
  }

  // Get doc image from gallery
  void _getFromGallery() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxHeight: 1800,
      maxWidth: 1800,
    );

    if (pickedFile != null) {
      fieldValues['image'] = pickedFile.path;
    }
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
                    }
                  )
                   
              );
            }
          }
        });
  }

  // Group text fields in one column
  Widget textFieldsBlock() {
    List<String> inputFieldText = [
      'Назва', 'Тип документу', 'Номер','Дата видачі (дд-мм-рррр)', 
      'Дійсний до (дд-мм-рррр)', 'Опис']; // hint text for text fields
      
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, 
      children: [
        Column(
            children: [
              // generate text fields
              for (int i = 0; i < inputFieldText.length; i++)
                textField(
                  {
                    'textInputAction' : TextInputAction.next,
                    'labelText' : inputFieldText[i],
                    'keyboardType' : inputFieldText[i] == 'Опис' ? TextInputType.multiline  : TextInputType.text,
                    'inputValue' : fieldValues.entries.elementAt(i).key
                  }
                ),
              
              ElevatedButton(
                onPressed: () {
                  _getFromGallery();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 25, 25, 25),
                ),
                child: const Text('Вибрати зображення'),
              ), // button, which picks image from gallery       
              
            ]
          ),
    ]);
  }

  // Text field widget with formatters and decorations
  Widget textField(Map args) {
    
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        width: 320,
        child: TextFormField(
          autofocus: false,
          textInputAction: args['textInputAction'],
          keyboardType: args['keyboardType'],
          maxLines: (args['inputValue'] == 'description') ? null : 1,
          autocorrect: true,
          enableSuggestions: true,
          cursorRadius: const Radius.circular(9.0),
          cursorColor: Colors.black,
          
          decoration: InputDecoration(
            labelText: args['labelText'],
            hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            labelStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            contentPadding: const EdgeInsets.fromLTRB(9, 0, 0, 0),
            focusedBorder: textFieldStyle,
            enabledBorder: textFieldStyle,
          ),
          
          onChanged: (String value) {
            fieldValues[args['inputValue']] = value;
          }
      )
    );
  }
  
}
