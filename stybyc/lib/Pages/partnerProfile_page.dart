import 'dart:io';

import 'package:emojis/emojis.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stybyc/Pages/tab_page.dart';
import 'package:stybyc/Widgets/profile_widget.dart';
import 'package:stybyc/model/databaseService.dart';

class PartnerProfilePage extends StatefulWidget {
  const PartnerProfilePage({
    Key? key,
  }) : super(key: key);

  @override
  _PartnerProfilePageState createState() => _PartnerProfilePageState();
}

class _PartnerProfilePageState extends State<PartnerProfilePage> {
  final userUID = FirebaseAuth.instance.currentUser!.uid;
  final database = FirebaseDatabase.instance.ref();
  late final partnerUID;
  late final profilePath;
  late final partnerName;
  late final birthday;
  late final en;

  @override
  initState() {
    super.initState();
    initInfo();
  }

  initInfo() async {
    database.child(userUID).onValue.listen((event) {
      final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      setState(() {
        partnerUID = data['partner'];
        en = data['language'].toString().startsWith('en');
        initPartnerInfo();
      });
    });
  }

  Future initPartnerInfo() async {
    final ppsnapshot =
        await database.child(partnerUID).child('profilePath').get();
    profilePath = ppsnapshot.value.toString();

    final nsnapshot = await database.child(partnerUID).child('username').get();
    partnerName = nsnapshot.value.toString();

    final bsnapshot = await database.child(partnerUID).child('birtday').get();
    birthday = bsnapshot.value.toString();
  }

  Future disconnect() async {
    await DatabaseService(uid: userUID).disconnect(partnerUID);
    setState(() {});
  }

  nextBirthday() {
    DateTime bd = DateFormat('yMd').parse(birthday);
    String thisYear = DateTime.now().year.toString();
    String birthDate = DateFormat('MM-dd').format(bd);
    DateTime birthdayThisYear = DateTime.parse('$thisYear-$birthDate');
    if (DateTime.now().month == bd.month && DateTime.now().day == bd.day) {
      return 0;
    } else if (DateTime.now().isBefore(birthdayThisYear)) {
      return birthdayThisYear.difference(DateTime.now()).inDays;
    } else {
      DateTime birthdayNextYear =
          DateTime.parse('${int.parse(thisYear) + 1}-$birthDate');
      return birthdayNextYear.difference(DateTime.now()).inDays;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // back navigation bar
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: CupertinoNavigationBarBackButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => TabPage())))),

      //content
      body: Column(children: <Widget>[
        const SizedBox(height: 120),
        getProfile(),
        const SizedBox(height: 35),
        getPartnerName(),
        getBirthday(),
        const SizedBox(height: 50),
        getBirthdayReminder(),
        const SizedBox(height: 50),
        getBreakupButton(),
      ]),
    );
  }

  Widget getProfile() {
    return ProfileWidget(
      path: profilePath,
      onClicked: () {},
    );
  }

  Widget getPartnerName() {
    return Container(
      color: Colors.grey.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.only(top: 10, left: 25, bottom: 10),
        child: Row(
          children: <Widget>[
            Text(
              en ? 'User Name' : '用户名',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                decoration: TextDecoration.none,
                color: Colors.black,
              ),
            ),
            SizedBox(width: en ? 192 : 228),
            Text(partnerName, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget getBirthday() {
    return Padding(
      padding: EdgeInsets.only(top: 10, left: 25, bottom: 10),
      child: Row(
        children: <Widget>[
          Text(
            en ? 'Birthday' : '生日',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              decoration: TextDecoration.none,
              color: Colors.black,
            ),
          ),
          SizedBox(width: en ? 185 : 220),
          Text(
            birthday,
            style: TextStyle(
                decoration: TextDecoration.none,
                color: Colors.black,
                fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget getBirthdayReminder() {
    final difference = nextBirthday();
    if (en) {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('It\'s ', style: GoogleFonts.indieFlower(fontSize: 28)),
            Text('$difference',
                style:
                    GoogleFonts.indieFlower(fontSize: 28, color: Colors.blue)),
            Text(' days left', style: GoogleFonts.indieFlower(fontSize: 28)),
          ],
        ),
        Text(
          'to $partnerName\'s birthday!',
          style: GoogleFonts.indieFlower(fontSize: 28),
        ),
      ]);
    } else {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('距离$partnerName的生日', style: TextStyle(fontSize: 28)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('还有 ', style: TextStyle(fontSize: 28)),
            Text('$difference',
                style: TextStyle(fontSize: 28, color: Colors.blue)),
            Text(' 天哦', style: TextStyle(fontSize: 28)),
          ],
        ),
      ]);
    }
  }

  Widget getBreakupButton() {
    return CupertinoButton(
      child: Text(
          en ? 'Break Up ${Emojis.brokenHeart}' : '分手${Emojis.brokenHeart}',
          style: TextStyle(color: Colors.red)),
      onPressed: () async {
        // disconnect
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(en ? 'Break Up?' : '分手？'),
                  content: Text(en
                      ? 'Are you sure you want to break up with your partner?'
                      : '你确定要和TA分手吗？'),
                  actions: [
                    TextButton(
                      child: Text(en ? 'Yes :(' : '确定 :('),
                      onPressed: () {
                        disconnect();
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => TabPage(),
                        ));
                      },
                    ),
                    TextButton(
                        child: Text(en ? 'Nevermind' : '算了'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        })
                  ],
                ));
      },
    );
  }
}
