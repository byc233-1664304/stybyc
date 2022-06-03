import 'package:stybyc/model/task.dart';
import 'package:stybyc/model/taskTypes.dart';

class TaskManager {
  TaskManager();

  TaskType stringToType(String typeStr) {
    switch (typeStr) {
      case 'Daily':
        return TaskType.Daily;
      case 'Wish':
        return TaskType.Wish;
      case 'Surprise':
        return TaskType.Surprise;
      case 'Punishment':
        return TaskType.Punishment;
      default:
        return TaskType.Wish;
    }
  }

  Task fromJson(Map<dynamic, dynamic> json) {
    String t = json['title'] as String;
    String d = json['description'] as String;
    int s = json['score'] as int;
    TaskType tt = stringToType(json['type'] as String);

    return Task(t, d, s, tt);
  }
}
