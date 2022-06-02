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
        return Colors.blue.withOpacity(0.5);
      case TaskType.Wish:
        return Colors.pink.withOpacity(0.5);
      case TaskType.Surprise:
        return Colors.deepPurple.withOpacity(0.5);
      case TaskType.Punishment:
        return Colors.grey.withOpacity(0.5);
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
