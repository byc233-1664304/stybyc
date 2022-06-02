import 'package:flutter/material.dart';
import 'package:stybyc/auth/decision_tree.dart';
import 'package:stybyc/model/authService.dart';

class RedeemPage extends StatefulWidget {
  const RedeemPage({Key? key}) : super(key: key);

  @override
  State<RedeemPage> createState() => _RedeemPageState();
}

class _RedeemPageState extends State<RedeemPage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Text('HERE'),
      onTap: () async {
        await AuthService().logOut();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => DecisionTree()),
        );
      },
    );
  }
}
