import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stybyc/auth/decision_tree.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //await UserPreferences.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DecisionTree(),
    );
  }
}