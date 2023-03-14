import 'package:doc_sys_pro/models/document.dart';
import 'package:doc_sys_pro/models/person.dart';
import 'package:doc_sys_pro/personsTab/personsTab.dart';
import 'package:doc_sys_pro/documentsTab/documentsTab.dart';
import 'package:doc_sys_pro/utils.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;


void main() async {
  // Ініціалізація Hive
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory =
      await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);

  // Реєстрація адаптерів для моделей
  Hive.registerAdapter(PersonAdapter());
  Hive.registerAdapter(DocumentAdapter());

  // Відкриття бази даних та завантаження даних 
  // !!! for is only for test cases. delete before release
  var personBox = await Hive.openBox('personas');
  if (personBox.isEmpty || personBox.length <= 2) {
    for (int i = 0; i < 5; i++) {
      personBox.put(
        'person$i',
        Person(
            firstName: 'Андрій',
            lastName: 'Клименко',
            age: 33,
            gender: 'Чол.',
            address: 'вул. Хрещатик, 12',
            phoneNumber: '+380999999999',
            person_id: generate_id()
        )
      );
    }
     
  } else {
    personsBoxLength = personBox.length;
    print('Persons\' box is not empty!');
  }

  personBox.close();

  var docsBox = await Hive.openBox('documents');
  if (docsBox.isEmpty) {
    docsBox.put(
        'document0',
        Document(
          name: 'Наказ',
          type: 'Наказ щодо ...',
          number: '12245-4124',
          date: DateTime(2023, 1, 1),
          imagePath: '...',
        ));
  } else {
    docsBoxLength = docsBox.length;
    print('Docs box is not empty!');
  }

  docsBox.close();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocSysPro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      initialRoute: '/',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _tabs = [
    PersonsTab(),
    DocumentsTab(),
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('DocSysPro'),
        backgroundColor: Color.fromARGB(255, 25, 25, 25),
      ),

      body: _tabs[_currentIndex],
      
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color.fromARGB(255, 246, 246, 246),
        unselectedItemColor: Color.fromARGB(57, 246, 246, 246),
        backgroundColor: Color.fromARGB(255, 40, 40, 40),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Особи',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Документи',
          ),
        ],
      ),
    );
  }
}
