import 'package:hive/hive.dart';

part 'document.g.dart';

@HiveType(typeId: 0)
class Document extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late String type;

  @HiveField(2)
  late String number;

  @HiveField(3)
  late DateTime date;

  @HiveField(4)
  late String imagePath;

  Document({
    required this.name,
    required this.type,
    required this.number,
    required this.date,
    required this.imagePath,
  });
}
