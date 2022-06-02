import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:stybyc/model/task.dart';
import 'package:stybyc/model/taskTypes.dart';

class DatabaseService {
  final String uid;

  DatabaseService({required this.uid});

  setDefaultInfo(String username, String email) async {
    bool en = Platform.localeName == 'en-US';
    String task1 = en ? 'Say Good Morning' : '和TA说早安';
    String task2 = en ? 'Drink a Cup of Water' : '喝一杯水';
    String task3 = en ? 'Say Goodnight' : '和TA说晚安';
    final t1 = Task(task1, '', 5, TaskType.Daily);
    final t2 = Task(task2, '', 5, TaskType.Daily);
    final t3 = Task(task3, '', 5, TaskType.Daily);

    try {
      await FirebaseDatabase.instance.ref().child(uid).set({
        'username': username,
        'email': email,
        'uid': uid,
        'profilePath':
            'https://i.pinimg.com/474x/fa/54/1b/fa541b60cccf4b85f25d97bf49d1d57c.jpg',
        'birthday': DateFormat('yMd').format(DateTime.now()),
        'anniversary': DateFormat('yMd').format(DateTime.now()),
        'partner': 'NA',
        'background':
            'https://www.leesharing.com/wp-content/uploads/2019/10/40.jpg',
        'allowConnection': true,
        'language': Platform.localeName,
        'score': 0,
      });
    } catch (e) {
      print(e.toString());
    }

    addDailyTask(t1);
    addDailyTask(t2);
    addDailyTask(t3);
  }

  Future updateAnniversary(String partner, String anniversary) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    await ref.update({
      '$uid/anniversary': anniversary,
      '$partner/anniversary': anniversary,
    });
  }

  Future switchLanguage() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('$uid/language');
    ref.onValue.listen((event) async {
      if (event.toString().startsWith('en')) {
        await ref.update({
          'language': 'zh',
        });
      } else {
        await ref.update({
          'language': 'en',
        });
      }
    });
  }

  Future connect(String partnerUID) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    await ref.update({
      '$uid/partner': partnerUID,
      '$uid/anniversary': DateFormat('yMd').format(DateTime.now()),
      '$partnerUID/partner': uid,
      '$partnerUID/anniversary': DateFormat('yMd').format(DateTime.now()),
    });
  }

  Future disconnect(String partnerUID) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    await ref.update({
      '$uid/partner': 'NA',
      '$uid/anniversary': DateFormat('yMd').format(DateTime.now()),
      '$partnerUID/partner': 'NA',
      '$partnerUID/anniversary': DateFormat('yMd').format(DateTime.now()),
    });
  }

  Future updateInfo(
      String username, String birthday, bool allowConnection) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref(uid);
    await ref.update({
      'username': username,
      'birthday': birthday,
      'allowConnection': allowConnection,
    });
  }

  Future addDailyTask(Task t) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref(uid).child('myDaily');
    await ref.push().set(t.toJson());
  }

  Future deleteuser() {
    return FirebaseDatabase.instance.ref(uid).remove();
  }
}
