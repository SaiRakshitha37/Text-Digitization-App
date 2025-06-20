// class Profile {
//   final String name;
//   final String email;
//   final String avatarLetter;

//   Profile({
//     required this.name,
//     required this.email,
//     required this.avatarLetter,
//   });
// }

import 'package:hive/hive.dart';

part 'profile.g.dart';

@HiveType(typeId: 0)
class Profile {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String email;

  Profile({required this.name, required this.email});

  String get avatarLetter => name.isNotEmpty ? name[0].toUpperCase() : '?';
}
