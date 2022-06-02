import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stybyc/Widgets/task_widget.dart';
import 'package:stybyc/model/authService.dart';
import 'package:stybyc/model/databaseService.dart';
import 'package:stybyc/model/taskTypes.dart';

class MyPovPage extends StatefulWidget {
  const MyPovPage({Key? key}) : super(key: key);

  @override
  State<MyPovPage> createState() => _MyPovPageState();
}

class _MyPovPageState extends State<MyPovPage> {
  final userUID = FirebaseAuth.instance.currentUser!.uid;
  final database = FirebaseDatabase.instance.ref();
  late final en;
  late final username;
  late final background;
  var myTask = [];
  var myDaily = [];
  var myHistory = [];
  var dailyTemp = [];

  @override
  initState() {
    super.initState();
    initInfo();
  }

  initInfo() async {
    database.child(userUID).onValue.listen((event) {
      final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      setState(() {
        username = data['username'];
        background = data['background'];
        final language = data['language'];
        en = language.toString().startsWith('en');
        //final dailyData = data['myDaily'];
      });
    });
  }

  String getTodayString() {
    if (en) {
      int day = DateTime.now().day;
      String surfix = 'th';
      if (day % 10 == 1) {
        surfix = 'st';
      } else if (day % 10 == 2) {
        surfix = 'nd';
      } else if (day % 10 == 3) {
        surfix = 'rd';
      }

      return 'the ' +
          day.toString() +
          surfix +
          ' of ' +
          DateFormat('MMMM').format(DateTime.now());
    } else {
      return DateTime.now().month.toString() +
          '月' +
          DateTime.now().day.toString() +
          '日';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            constraints: const BoxConstraints.expand(),
            decoration: BoxDecoration(
                image: DecorationImage(
              image: NetworkImage(background),
              fit: BoxFit.cover,
            )),
            child: ListView(
              padding: const EdgeInsets.only(top: 90),
              children: [
                getHello(),
                SizedBox(height: 25),
                getDailyTaskWidget(),
                SizedBox(height: 12),
                getChartWidget(),
                SizedBox(height: 25),
                getTaskHeading(),
                getTaskList(),
              ],
            )));
  }

  Widget getHello() {
    return Column(children: [
      Text(
        en ? '$username, how are you doing?' : '$username, 今天肿么样呀？',
        style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            decoration: TextDecoration.none,
            fontWeight: FontWeight.bold),
      ),
      Text(
        en ? 'Today is ' + getTodayString() : '今天是' + getTodayString() + '哦',
        style: TextStyle(
            fontSize: 14, color: Colors.black, decoration: TextDecoration.none),
      ),
    ]);
  }

  Widget getDailyTaskWidget() {
    return Padding(
      padding: EdgeInsets.only(left: 25, right: 25),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Row(
          children: [
            SizedBox(width: 15),
            Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(en ? 'Your daily tasks' : '你的日常任务',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        decoration: TextDecoration.none)),
                SizedBox(height: 5),
                Text(
                  en ? 'x of x task(s) completed' : '已经完成了x个任务中的x个了哦',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      decoration: TextDecoration.none),
                ),
                SizedBox(height: 20),
              ],
            ),
            // add a pie graph
          ],
        ),
      ),
    );
  }

  Widget getChartWidget() {
    return Padding(
      padding: EdgeInsets.only(left: 25, right: 25),
      child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Row(
            children: [
              SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15),
                  Text(en ? 'Score Chart' : '积分图表',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          decoration: TextDecoration.none)),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Text('-',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              decoration: TextDecoration.none)),
                      Text(en ? 'Daily' : '日常任务',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              decoration: TextDecoration.none)),
                      SizedBox(width: 15),
                      Text('-',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              decoration: TextDecoration.none)),
                      Text(en ? ' Wishes' : ' 愿望分',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              decoration: TextDecoration.none)),
                      SizedBox(width: 15),
                      Text('-',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              decoration: TextDecoration.none)),
                      Text(en ? ' Surprises' : ' 惊喜分',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              decoration: TextDecoration.none)),
                    ],
                  ),
                  // add bar chart
                  SizedBox(height: 15),
                ],
              ),
            ],
          )),
    );
  }

  Widget getTaskHeading() {
    return Row(
      children: [
        SizedBox(width: 288),
        Text(en ? 'My Tasks' : '我的任务',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.none))
      ],
    );
  }

  Widget getNoTaskReminder() {
    if (en) {
      return Text('You don\'t have any task');
    } else {
      return Text('你没有任务哦');
    }
  }

  Widget getTaskList() {
    if (myTask == null) {
      return getNoTaskReminder();
    } else {
      return Expanded(
          child: ListView.separated(
              padding: EdgeInsets.only(top: 12, left: 20, right: 20),
              shrinkWrap: true,
              itemCount: 3,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  child: Center(child: testList[index]),
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 5)));
    }
  }

  List testList = [
    TaskWidget(
        title: 'Title 1', description: '', score: 10, type: TaskType.Wish),
    TaskWidget(
        title: 'Title 2', description: '', score: 20, type: TaskType.Surprise),
    TaskWidget(
        title: 'Title 3',
        description: '',
        score: 10,
        type: TaskType.Punishment),
  ];
}
