import 'package:hive/hive.dart';

part 'folder.g.dart';

@HiveType(typeId: 3)
class Folder extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late String number;

  @HiveField(2)
  late List<Map<String, String>> docsInFolder;
  
  Folder({
    required this.name,
    required this.number,
    required this.docsInFolder
  });

  @override
  String toString() {
    return 'Name: $name, number: $number,\ndocuments: $docsInFolder\n';
  }
}
