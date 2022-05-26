import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stybyc/Pages/tab_page.dart';
import 'package:stybyc/auth/auth_page.dart';

class DecisionTree extends StatefulWidget {
  const DecisionTree({Key? key}) : super(key: key);

  @override
  State<DecisionTree> createState() => _DecisionTreeState();
}

class _DecisionTreeState extends State<DecisionTree> {
  User? user;

  @override
  void initState() {
    super.initState();
    onRefresh();
  }

  onRefresh() {
    FirebaseAuth.instance.authStateChanges().listen((currUser) async {
      setState(() {
        user = currUser;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return AuthPage();
    } else {
      return TabPage();
    }
  }
}
