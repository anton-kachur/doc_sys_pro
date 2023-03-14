import 'package:hive/hive.dart';

part 'person.g.dart';

@HiveType(typeId: 2)
class Person extends HiveObject {
  @HiveField(0)
  late String firstName;

  @HiveField(1)
  late String lastName;

  @HiveField(2)
  late int age;

  @HiveField(3)
  late String gender;

  @HiveField(4)
  late String address;

  @HiveField(5)
  late String phoneNumber;

  @HiveField(6)
  late String person_id;

  Person({
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.gender,
    required this.address,
    required this.phoneNumber,
    required this.person_id
  });
}
