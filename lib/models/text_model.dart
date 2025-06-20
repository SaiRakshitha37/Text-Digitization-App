

// import 'package:hive/hive.dart';

// part 'text_model.g.dart';

// @HiveType(typeId: 0)
// class TextModel extends HiveObject {
//   @HiveField(0)
//   String name;

//   @HiveField(1)
//   String content;

//   @HiveField(2)
//   DateTime dateTime;

//   @HiveField(3)
//   bool isDeleted;

//   TextModel({
//     required this.name,
//     required this.content,
//     required this.dateTime,
//     this.isDeleted = false,
//   });

//   // JSON deserialization
//   factory TextModel.fromJson(Map<String, dynamic> json) {
//     return TextModel(
//       name: json['name'] ?? json['title'] ?? 'Unnamed', // fallback for 'title'
//       content: json['content'] ?? '',
//       dateTime: DateTime.tryParse(json['dateTime'] ?? '') ?? DateTime.now(),
//       isDeleted: json['isDeleted'] ?? false,
//     );
//   }

//   // JSON serialization
//   Map<String, dynamic> toJson() => {
//         'name': name,
//         'content': content,
//         'dateTime': dateTime.toIso8601String(),
//         'isDeleted': isDeleted,
//       };

//   // Override save method to handle isDeleted flag (Hive functionality)
//   Future<void> save() async {
//     if (isDeleted) {
//       // If document is deleted, we just mark it
//       this.save();
//     } else {
//       // Otherwise, save as a normal object
//       this.save();
//     }
//   }
// }
import 'package:hive/hive.dart';

part 'text_model.g.dart';

@HiveType(typeId: 0)
class TextModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String content;

  @HiveField(2)
  DateTime dateTime;

  @HiveField(3)
  bool isDeleted;

  TextModel({
    required this.name,
    required this.content,
    required this.dateTime,
    this.isDeleted = false,
  });

  factory TextModel.fromJson(Map<String, dynamic> json) {
    return TextModel(
      name: json['name'] ?? json['title'] ?? 'Unnamed',
      content: json['content'] ?? '',
      dateTime: DateTime.tryParse(json['dateTime'] ?? '') ?? DateTime.now(),
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'content': content,
        'dateTime': dateTime.toIso8601String(),
        'isDeleted': isDeleted,
      };
}
