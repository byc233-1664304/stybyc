import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  late final language = Platform.localeName;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReste() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(language.startsWith('en')
                  ? 'Password reset link sent! Check your email.'
                  : '重置密码的链接已经发送到您的邮箱了哦，去康康吧！'),
            );
          });
    } on FirebaseAuthException catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[200],
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            language.startsWith('en') ? 'Please enter your email' : '请输入您的邮箱',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
          Text(
            language.startsWith('en')
                ? 'we will send you a password reset link'
                : '我们会给您发送重置密码的邮件哦',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple),
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: language.startsWith('en') ? 'Email' : '邮箱',
                fillColor: Colors.grey[200],
                filled: true,
              ),
            ),
          ),
          SizedBox(height: 10),
          MaterialButton(
            onPressed: () => passwordReste(),
            child: Text(language.startsWith('en') ? 'Reset Password' : '重置密码'),
            color: Colors.deepPurple[200],
          ),
        ],
      ),
    );
  }
}
