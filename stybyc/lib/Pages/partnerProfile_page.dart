import 'package:emojis/emojis.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stybyc/Pages/tab_page.dart';
import 'package:stybyc/Widgets/profile_widget.dart';
import 'package:stybyc/model/authService.dart';
import 'package:stybyc/model/databaseService.dart';

class PartnerProfilePage extends StatefulWidget {
  const PartnerProfilePage({
    Key? key,
  }) : super(key: key);

  @override
  _PartnerProfilePageState createState() => _PartnerProfilePageState();
}

class _PartnerProfilePageState extends State<PartnerProfilePage> {
  late final profilePath;
  late final coupleName;
  late final birthday;
  late final coupleUID;

  @override
  initState() {
    super.initState();
    initPartnerInfo();
  }

  initPartnerInfo() async {
    Map<String, dynamic> data =
        await AuthService().getCoupleData() as Map<String, dynamic>;
    profilePath = data['profilePath'];
    coupleName = data['username'];
    birthday = data['birthday'].toDate();
    coupleUID = data['uid'];
    setState(() {});
  }

  Future disconnect() async {
    final currUser = await FirebaseAuth.instance.currentUser;
    await DatabaseService(uid: currUser!.uid).disconnect();
    await DatabaseService(uid: coupleUID).disconnect();

    setState(() {});
  }

  nextBirthday() {
    String thisYear = DateTime.now().year.toString();
    String birthDate = DateFormat('MM-dd').format(birthday);
    DateTime birthdayThisYear = DateTime.parse('$thisYear-$birthDate');
    if (DateTime.now().month == birthday.month &&
        DateTime.now().day == birthday.day) {
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
    final difference = nextBirthday();
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
        ProfileWidget(
          path: profilePath,
          onClicked: () {},
        ),
        const SizedBox(height: 35),
        // user name
        Container(
          color: Colors.grey.withOpacity(0.1),
          child: Padding(
            padding: EdgeInsets.only(top: 10, left: 25, bottom: 10),
            child: Row(
              children: <Widget>[
                Text(
                  'User Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    decoration: TextDecoration.none,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 192),
                Text(coupleName, style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ),
        // birthday
        Padding(
          padding: EdgeInsets.only(top: 10, left: 25, bottom: 10),
          child: Row(
            children: <Widget>[
              Text(
                'Birthday',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  decoration: TextDecoration.none,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 185),
              Text(
                DateFormat('MM/dd/yyyy').format(birthday),
                style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.black,
                    fontSize: 18),
              ),
            ],
          ),
        ),
        const SizedBox(height: 50),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('It\'s ', style: GoogleFonts.indieFlower(fontSize: 28)),
              Text('$difference',
                  style: GoogleFonts.indieFlower(
                      fontSize: 28, color: Colors.blue)),
              Text(' days left', style: GoogleFonts.indieFlower(fontSize: 28)),
            ],
          ),
          Text(
            'to $coupleName\'s birthday!',
            style: GoogleFonts.indieFlower(fontSize: 28),
          ),
        ]),
        const SizedBox(height: 50),
        CupertinoButton(
          child: Text('Break Up ${Emojis.brokenHeart}',
              style: TextStyle(color: Colors.red)),
          onPressed: () async {
            // disconnect
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: Text('Break Up?'),
                      content: Text(
                          'Are you sure you want to break up with your partner?'),
                      actions: [
                        TextButton(
                          child: Text('Yes :('),
                          onPressed: () {
                            disconnect();
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => TabPage(),
                            ));
                          },
                        ),
                        TextButton(
                            child: Text('Nevermind'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            })
                      ],
                    ));
          },
        ),
      ]),
    );
  }
}