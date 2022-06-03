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

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'title': title,
        'description': description,
        'score': score,
        'type': typeToString(type),
      };
}
