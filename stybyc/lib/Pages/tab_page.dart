import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:stybyc/Pages/partner_page.dart';
import 'package:stybyc/Pages/profile_page.dart';
import 'package:stybyc/Pages/redeem_page.dart';
import 'package:stybyc/Pages/myPov_page.dart';
import 'package:stybyc/model/databaseService.dart';

class TabPage extends StatefulWidget {
  const TabPage({
    Key? key,
  }) : super(key: key);

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  late final en;

  Future getEn() async {
    final userUID = FirebaseAuth.instance.currentUser!.uid;
    final snapshot =
        await FirebaseDatabase.instance.ref('$userUID/language').get();
    setState(() {
      en = snapshot.value.toString().startsWith('en');
    });
  }

  @override
  void initState() {
    super.initState();
    getEn();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.heart_solid),
            label: en ? 'Main Page' : '主页',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.doc_chart),
            label: en ? 'Me' : '我的',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.doc_chart_fill),
            label: en ? 'Partner' : 'TA',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.gift),
            label: en ? "Redeem" : '兑换',
          ),
        ],
      ),
      tabBuilder: (context, i) {
        switch (i) {
          case 0:
            return ProfilePage();
          case 1:
            return MyPovPage();
          case 2:
            return PartnerPage();
          case 3:
            return RedeemPage();
          default:
            return ProfilePage();
        }
      },
    );
  }
}
