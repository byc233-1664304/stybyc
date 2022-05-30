import 'package:flutter/cupertino.dart';
import 'package:stybyc/Pages/partner_page.dart';
import 'package:stybyc/Pages/profile_page.dart';
import 'package:stybyc/Pages/redeem_page.dart';
import 'package:stybyc/Pages/myPov_page.dart';

class TabPage extends StatefulWidget {
  const TabPage({
    Key? key,
  }) : super(key: key);

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.heart_solid),
            label: 'Main Page',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.doc_chart),
            label: 'Me',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.doc_chart_fill),
            label: 'Partner',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.gift),
            label: "Redeem",
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
