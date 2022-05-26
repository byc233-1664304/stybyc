import 'package:flutter/material.dart';

class IntroWidget extends StatelessWidget {
  final DateTime anniversary;
  final hasCouple;

  const IntroWidget({
    Key? key,
    String? couple,
    required this.anniversary,
    required this.hasCouple,
  }) : super(key: key);

  connect() {}

  @override
  Widget build(BuildContext context) {
    if (hasCouple) {
      throw UnimplementedError();
    } else {
      return Column(children: [
        Text('Your partner is on the way...'),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          GestureDetector(
            onTap: () => {
              connect(),
            },
            child: Text(
              'Connect ',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text("to your partner right now!"),
        ])
      ]);
    }
  }
}
