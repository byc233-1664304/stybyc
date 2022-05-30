import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stybyc/model/authService.dart';

class DatabaseService {
  final String uid;

  DatabaseService({required this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  Future setDefaultUser(String username, String email) {
    return FirebaseFirestore.instance.collection("users").doc(uid).set({
      "uid": uid,
      'username': username,
      'email': email,
      'profilePath':
          'https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg',
      'birthday': DateTime.now(),
      'anniversary': DateTime.now(),
      'couple': 'NA',
      'background':
          'https://i.pinimg.com/564x/72/53/d1/7253d19fdce28f4a297e0838abe1fcc4.jpg',
      'allowConnection': true,
      'language': Platform.localeName,
    });
  }

  Future updateAnniversary(DateTime anniversary) {
    return FirebaseFirestore.instance.collection('users').doc(uid).update(
      {'anniversary': anniversary},
    );
  }

  Future switchLanguage() async {
    String currLanguage = await AuthService().getLanguageSettings();
    if (currLanguage == 'en-US') {
      return FirebaseFirestore.instance.collection('users').doc(uid).update({
        'language': 'zh',
      });
    } else {
      return FirebaseFirestore.instance.collection('users').doc(uid).update({
        'language': 'en-US',
      });
    }
  }

  Future connect(String coupleUID) {
    return FirebaseFirestore.instance.collection('users').doc(uid).update({
      'couple': coupleUID,
      'anniversary': DateTime.now(),
    });
  }

  Future disconnect() {
    return FirebaseFirestore.instance.collection('users').doc(uid).update(
      {
        'couple': 'NA',
        'anniversary': DateTime.now(),
      },
    );
  }

  Future updateInfo(String username, DateTime birthday, bool allowConnection) {
    return FirebaseFirestore.instance.collection('users').doc(uid).update(
      {
        'username': username,
        'birthday': birthday,
        'allowConnection': allowConnection,
      },
    );
  }

  Future deleteuser() {
    return userCollection.doc(uid).delete();
  }
}
