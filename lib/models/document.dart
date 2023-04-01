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
  late String docNumber;

  @HiveField(4)
  late DateTime dateFrom;

  @HiveField(5)
  late DateTime dateTo;

  @HiveField(6)
  late String image;

  @HiveField(7)
  late String description;

  Document({
    required this.name,
    required this.type,
    required this.number,
    required this.docNumber,
    required this.dateFrom,
    required this.dateTo,
    required this.image,
    required this.description,
  });
}
