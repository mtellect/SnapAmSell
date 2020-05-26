import 'package:Strokes/preinit.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';

import 'AppEngine.dart';
import 'assets.dart';
import 'main.dart';

class AlarmTest extends StatefulWidget {
  @override
  _AlarmTestState createState() => _AlarmTestState();
}

void printMessage(String msg) => print('[${DateTime.now()}] $msg');

void printPeriodic() => printMessage("Periodic John!");
void printOneShot() => printMessage("One shot!");

class _AlarmTestState extends State<AlarmTest> {
  @override
  void initState() {
    // TODO: implement initState
    setup();
    super.initState();
  }

  setup() async {
    await AndroidAlarmManager.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: white,
        child: Center(
            child: Container(
          height: 30,
          color: blue0,
          child: FlatButton(
              onPressed: () async {
                await AndroidAlarmManager.oneShotAt(DateTime.now(), 4, () {
                  print('[${DateTime.now()}] Hot John');
                  runApp(PreInit());
                }, wakeup: true);
              },
              child: Text(
                "Set Alarm",
                style: textStyle(true, 12, white),
              )),
        )));
    ;
  }
}
