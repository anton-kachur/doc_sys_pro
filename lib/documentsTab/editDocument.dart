import 'package:doc_sys_pro/models/document.dart';
import 'package:doc_sys_pro/utils.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';


class DocumentSettings extends StatefulWidget {
  final int index;
  Map<String, String?> userData;

  DocumentSettings({required this.index, required this.userData});

  @override
  _DocumentSettingsState createState() => _DocumentSettingsState();
}

class _DocumentSettingsState extends State<DocumentSettings> {
  late Box<Document> _documentsBox;
  List<Document> _documentsList = [];

  Map<String, Object> fieldValues = {
    'name': '',
    'type': '',
    'docNumber': '',
    'dateFrom': '',
    'dateTo': '',
    'description': '',
    'image': '',
  };

  // Get all user's documents from DB
  Future _getDataFromBox() async {
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

  // Edit an existing document and save changes to DB
  void _editDocument() {
    List<String> formattedDateFrom = '${fieldValues['dateFrom']}'.split('-');
    List<String> formattedDateTo = '${fieldValues['dateTo']}'.split('-');
    Map isAllCorrect = editDocInputCheck(
      input: fieldValues, 
      documentsList: _documentsList,
      dateFrom: formattedDateFrom, 
      dateTo: formattedDateTo
    );

    if (isAllCorrect['all_correct'] == false ) {
      alert(context, isAllCorrect);
    } else {
      _documentsBox.putAt(
        widget.index,
        Document(
            name: fieldValues['name'] == ''
                ? _documentsBox.getAt(widget.index)!.name
                : '${fieldValues['name']}',
            type: fieldValues['type'] == ''
                ? _documentsBox.getAt(widget.index)!.type
                : '${fieldValues['type']}',
            number: _documentsBox.getAt(widget.index)!.number,
            docNumber: fieldValues['docNumber'] == ''
                ? _documentsBox.getAt(widget.index)!.docNumber
                : '${fieldValues['docNumber']}',
            dateFrom: fieldValues['dateFrom'] == ''
                ? _documentsBox.getAt(widget.index)!.dateFrom
                : DateTime(
                  int.parse(formattedDateFrom.elementAt(2)),
                  int.parse(formattedDateFrom.elementAt(1)),
                  int.parse(formattedDateFrom.elementAt(0)),
                ),
            dateTo: fieldValues['dateTo'] == ''
                ? _documentsBox.getAt(widget.index)!.dateTo
                : DateTime(
                  int.parse(formattedDateTo.elementAt(2)),
                  int.parse(formattedDateTo.elementAt(1)),
                  int.parse(formattedDateTo.elementAt(0)),
                ),
            image: fieldValues['image'] == ''
                ? _documentsBox.getAt(widget.index)!.image
                : '${fieldValues['image']}',
            description: fieldValues['description'] == ''
                ? _documentsBox.getAt(widget.index)!.description
                : '${fieldValues['description']}'
      ));

      redirect(context: context, userData: widget.userData);
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
                  title: const Text('Редагувати документ'),
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
                    _editDocument();
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
      'Дійсний до (дд-мм-рррр)', 'Опис'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, 
      children: [
        Column(
            children: [
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
              ), 

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
