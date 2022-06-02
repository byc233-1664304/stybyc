import 'package:stybyc/Widgets/task_widget.dart';
import 'package:stybyc/model/taskTypes.dart';

class Task {
  String title;
  String description;
  int score;
  TaskType type;

  Task(this.title, this.description, this.score, this.type);

  getTaskWidget() {
    return TaskWidget(
        title: title, description: description, score: score, type: type);
  }

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

  String typeToString(TaskType tt) {
    switch (tt) {
      case TaskType.Daily:
        return 'Daily';
      case TaskType.Wish:
        return 'Wish';
      case TaskType.Surprise:
        return 'Surprise';
      case TaskType.Punishment:
        return 'Punishment';
      default:
        return 'Wish';
    }
  }

  Task fromJson(Map<dynamic, dynamic> json) {
    String t = json['title'] as String;
    String d = json['description'] as String;
    int s = json['score'] as int;
    TaskType tt = stringToType(json['type'] as String);

    return Task(t, d, s, tt);
  }

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'title': title,
        'description': description,
        'score': score,
        'type': typeToString(type),
      };
}
