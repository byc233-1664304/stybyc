import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:stybyc/Widgets/task_widget.dart';
import 'package:stybyc/model/taskAssort.dart';
import 'package:stybyc/model/taskManager.dart';
import 'package:stybyc/model/taskTypes.dart';

var _selected = TaskAssort.Unfinished;

class MyPovPage extends StatefulWidget {
  const MyPovPage({Key? key}) : super(key: key);

  @override
  State<MyPovPage> createState() => _MyPovPageState();
}

class _MyPovPageState extends State<MyPovPage> {
  final userUID = FirebaseAuth.instance.currentUser!.uid;
  final database = FirebaseDatabase.instance.ref();
  final tm = TaskManager();
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

  initInfo() {
    database.child(userUID).onValue.listen((event) {
      final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      setState(() {
        username = data['username'];
        background = data['background'];
        final language = data['language'];
        en = language.toString().startsWith('en');

        if (data['myDaily'] != null) {
          final dailyMap = Map<dynamic, dynamic>.from(data['myDaily']);
          dailyMap.forEach((key, value) {
            myDaily.add(tm.fromJson(value));
            //myTask.add(tm.fromJson(value));
          });
        }

        if (data['myTask'] != null) {
          final taskMap = Map<dynamic, dynamic>.from(data['myTask']);
          taskMap.forEach((key, value) {
            myTask.add(tm.fromJson(value));
          });
        }

        if (data['history'] != null) {
          final historyMap = Map<dynamic, dynamic>.from(data['history']);
          historyMap.forEach((key, value) {
            myHistory.add(tm.fromJson(value));
          });
        }
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

  String getAssortText(TaskAssort e) {
    switch (e) {
      case TaskAssort.Unfinished:
        return en ? 'My Tasks' : '我的任务';
      case TaskAssort.UnfinishedDaily:
        return en ? 'Daily Tasks' : '日常任务';
      case TaskAssort.Histroy:
        return en ? 'History' : '已完成';
      default:
        return en ? 'My Tasks' : '我的任务';
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
                const SizedBox(height: 25),
                getDailyTaskWidget(),
                const SizedBox(height: 12),
                getChartWidget(),
                const SizedBox(height: 25),
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
    int touchedIndex = -1;
    final total = myDaily.length + dailyTemp.length;
    final finished = dailyTemp.length;
    double percentage = finished / total;
    double showPercent = percentage * 100;

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
                SizedBox(height: 25),
                Text(en ? 'Your daily tasks' : '你的日常任务',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        decoration: TextDecoration.none)),
                SizedBox(height: 5),
                Text(
                  en
                      ? '$finished of $total task(s) completed'
                      : '已经完成了$total个任务中的$finished个了哦',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      decoration: TextDecoration.none),
                ),
                SizedBox(height: 25),
              ],
            ),
            SizedBox(width: 100),
            CircularPercentIndicator(
              radius: 25,
              lineWidth: 7,
              percent: percentage,
              progressColor: Color.fromARGB(255, 125, 77, 208),
              backgroundColor: Color.fromARGB(255, 189, 170, 226),
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              center: Text(
                '$showPercent%',
                style: TextStyle(fontSize: 10, color: Colors.deepPurple),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getChartWidget() {
    LineChartData(
      minX: 0,
      maxX: 11,
    );

    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25),
      child: Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Row(
            children: [
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  Text(en ? 'Score Chart' : '积分图表',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          decoration: TextDecoration.none)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Text('-',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              decoration: TextDecoration.none)),
                      Text(en ? 'Daily' : '日常任务',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              decoration: TextDecoration.none)),
                      const SizedBox(width: 15),
                      const Text('-',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              decoration: TextDecoration.none)),
                      Text(en ? ' Wishes' : ' 愿望分',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              decoration: TextDecoration.none)),
                      const SizedBox(width: 15),
                      const Text('-',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              decoration: TextDecoration.none)),
                      Text(en ? ' Surprises' : ' 惊喜分',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              decoration: TextDecoration.none)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const SizedBox(height: 15),
                ],
              ),
            ],
          )),
    );
  }

  Widget getTaskHeading() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        DropdownButton<TaskAssort>(
            value: _selected,
            icon: const Icon(Icons.arrow_drop_down),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              decoration: TextDecoration.none,
            ),
            alignment: Alignment.centerRight,
            onChanged: (TaskAssort? v) {
              _selected = v!;
              setState(() {});
            },
            items: [
              DropdownMenuItem(
                value: TaskAssort.Unfinished,
                child: Text(getAssortText(TaskAssort.Unfinished),
                    textAlign: TextAlign.end),
              ),
              DropdownMenuItem(
                value: TaskAssort.UnfinishedDaily,
                child: Text(getAssortText(TaskAssort.UnfinishedDaily),
                    textAlign: TextAlign.end),
              ),
              DropdownMenuItem(
                value: TaskAssort.Histroy,
                child: Text(getAssortText(TaskAssort.Histroy),
                    textAlign: TextAlign.end),
              ),
            ]),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget getNoTaskReminder() {
    if (en) {
      return const Text('You don\'t have any task yet');
    } else {
      return const Text('你暂时还没有任务哦');
    }
  }

  Widget getTaskList() {
    if (myTask.isEmpty) {
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
