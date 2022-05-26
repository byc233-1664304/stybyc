import 'package:cloud_firestore/cloud_firestore.dart';

class UserInfo {
  String username;
  String email;
  String profilePath;
  DateTime birthday;
  DateTime anniversary;
  String couple;

  UserInfo(
    this.username,
    this.email,
    this.profilePath,
    this.birthday,
    this.anniversary,
    this.couple,
  );

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'profilePath': profilePath,
        'birthday': birthday,
        'anniversary': anniversary,
        'couple': couple,
      };

  UserInfo.fromSnapshot(DocumentSnapshot snapshot)
      : username = snapshot['username'],
        email = snapshot['email'],
        profilePath = snapshot['profilePath'],
        birthday = snapshot['birthday'].toDate(),
        anniversary = snapshot['anniversary'].toDate(),
        couple = snapshot['couple'];
}
