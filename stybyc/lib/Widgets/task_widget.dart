import 'package:flutter/material.dart';
import 'package:stybyc/model/taskTypes.dart';

class TaskWidget extends StatelessWidget {
  String title;
  String? description;
  int score;
  TaskType type;

  TaskWidget({
    required this.title,
    this.description,
    required this.score,
    required this.type,
  });

  getColor() {
    switch (type) {
      case TaskType.Daily:
        return Color.fromARGB(255, 138, 184, 221).withOpacity(0.5);
      case TaskType.Wish:
        return Color.fromARGB(255, 221, 146, 171).withOpacity(0.5);
      case TaskType.Surprise:
        return Color.fromARGB(255, 179, 154, 224).withOpacity(0.5);
      case TaskType.Punishment:
        return Color.fromARGB(255, 190, 189, 189).withOpacity(0.5);
      default:
        return Colors.white.withOpacity(0.5);
    }
  }

  getScoreText() {
    switch (type) {
      case TaskType.Punishment:
        return Text('-' + score.toString(),
            style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                decoration: TextDecoration.none));
      default:
        return Text(score.toString(),
            style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                decoration: TextDecoration.none));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: getColor(),
      ),
      child: description == ''
          ? ListTile(
              title: Text(title,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      decoration: TextDecoration.none)),
              trailing: getScoreText())
          : ListTile(
              title: Text(title,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      decoration: TextDecoration.none)),
              subtitle: Text(description!,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      decoration: TextDecoration.none)),
              trailing: getScoreText()),
    );
  }
}
