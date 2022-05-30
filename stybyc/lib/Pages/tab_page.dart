import 'package:flutter/cupertino.dart';
import 'package:stybyc/Pages/partner_page.dart';
import 'package:stybyc/Pages/profile_page.dart';
import 'package:stybyc/Pages/redeem_page.dart';
import 'package:stybyc/Pages/myPov_page.dart';
import 'package:stybyc/model/authService.dart';
import 'package:stybyc/model/databaseService.dart';

class TabPage extends StatefulWidget {
  const TabPage({
    Key? key,
  }) : super(key: key);

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  late final language = getLanguage();

  Future getLanguage() async {
    return await AuthService().getLanguageSettings();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.heart_solid),
            label: language == 'en-US' ? 'Main Page' : '主页',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.doc_chart),
            label: language == 'en-US' ? 'Me' : '我的',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.doc_chart_fill),
            label: language == 'en-US' ? 'Partner' : 'TA',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.gift),
            label: language == 'en-US' ? "Redeem" : '兑换',
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
