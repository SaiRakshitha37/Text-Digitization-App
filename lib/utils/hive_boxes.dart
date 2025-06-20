import 'package:hive/hive.dart';
import '../models/text_model.dart';

class HiveBoxes {
  static Box<TextModel> getTextModelBox() => Hive.box<TextModel>('text_model');
}
