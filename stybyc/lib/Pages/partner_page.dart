import 'package:flutter/material.dart';
import 'package:stybyc/model/task.dart';
import 'package:stybyc/model/taskTypes.dart';

class PartnerPage extends StatefulWidget {
  const PartnerPage({Key? key}) : super(key: key);

  @override
  State<PartnerPage> createState() => _PartnerPageState();
}

class _PartnerPageState extends State<PartnerPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final scoreController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: Text('Editing your wish...'),
                          content: Column(children: [
                            TextField(
                              controller: titleController,
                              decoration: InputDecoration(
                                hintText: 'Title',
                              ),
                            ),
                            TextField(
                              controller: descriptionController,
                              decoration: InputDecoration(
                                hintText: 'Description (optional)',
                              ),
                            ),
                            TextField(
                              controller: scoreController,
                              decoration: InputDecoration(hintText: 'Score'),
                            ),
                          ]),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Task wish = Task(
                                      titleController.text.trim(),
                                      descriptionController.text.trim(),
                                      int.parse(scoreController.text.trim()),
                                      TaskType.Wish);
                                },
                                child: Text('Confirm')),
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Cancel'))
                          ],
                        ));
              },
              child: Text('Add Wish'))
        ],
      ),
    );
  }
}
