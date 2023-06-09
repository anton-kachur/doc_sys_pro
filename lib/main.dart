import 'package:doc_sys_pro/loginPage.dart';
import 'package:doc_sys_pro/models/document.dart';
import 'package:doc_sys_pro/models/folder.dart';
import 'package:doc_sys_pro/personsTab/personsTab.dart';
import 'package:doc_sys_pro/documentsTab/documentsTab.dart';
import 'package:doc_sys_pro/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  Hive.registerAdapter(DocumentAdapter());
  Hive.registerAdapter(FolderAdapter());

  var docsBox = await Hive.openBox('your_documents');
  docsBoxLength = docsBox.length;
  for (var i in docsBox.values) {
    print(i.toString());
  }
  docsBox.close();

  var foldersBox = await Hive.openBox('your_folders');

  for (var i in foldersBox.toMap().entries) {
    print('${i.key}\n${i.value.toString()}');
  }
  
  foldersBoxLength = foldersBox.length;

  foldersBox.close();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DocSysPro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      initialRoute: '/',
      home: LoginPage(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  Map<String, String?> userData;
  int currentIndex;

  HomeScreen(this.userData, {this.currentIndex = 0, Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map<String, String?> user;
  final _tabs = [];

  @override
  void initState() {
    super.initState();
    user = widget.userData;
    _tabs.add(PersonsTab(user));
    _tabs.add(DocumentsTab(user));
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('DocSysPro'),
        backgroundColor: const Color.fromARGB(255, 25, 25, 25),
      ),

      body: _tabs[widget.currentIndex],
      
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color.fromARGB(255, 246, 246, 246),
        unselectedItemColor: const Color.fromARGB(57, 246, 246, 246),
        backgroundColor: const Color.fromARGB(255, 40, 40, 40),
        currentIndex: widget.currentIndex,
        onTap: (index) {
          setState(() {
            widget.currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Акаунт',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Мої документи',
          ),
        ],
      ),
    );
  }
}
