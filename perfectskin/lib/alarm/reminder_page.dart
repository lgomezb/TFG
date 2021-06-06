import 'package:fluttertoast/fluttertoast.dart';
import 'package:perfectskin/utils/MyLocalizationsDelegate.dart';
import 'package:perfectskin/utils/Size_config.dart';

import 'reminder_helper.dart';
import 'reminder_colors.dart';
import 'reminder_info.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import '../main.dart';

class AlarmPage extends StatefulWidget {
  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  DateTime _alarmTime;
  String _alarmTimeString;
  AlarmHelper _alarmHelper = AlarmHelper();
  Future<List<AlarmInfo>> _alarms;
  List<AlarmInfo> _currentAlarms;

  @override
  void initState() {
    _alarmTime = DateTime.now();
    _alarmHelper.initializeDatabase().then((value) {
      loadAlarms();
    });
    super.initState();
  }

  void loadAlarms() {
    _alarms = _alarmHelper.getAlarms();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          MyLocalizations
              .of(context)
              .getText('remindertitle'),
          style: TextStyle(
              color: CustomColors.primaryTextColor,
     ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.only(left: 32, right: 30, bottom: 64, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: FutureBuilder<List<AlarmInfo>>(
                future: _alarms,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _currentAlarms = snapshot.data;
                    return ListView(
                      children: snapshot.data.map<Widget>((alarm) {
                        var alarmTime =
                            DateFormat('hh:mm aa').format(alarm.alarmDateTime);
                        var gradientColor = GradientTemplate
                            .gradientTemplate[alarm.gradientColorIndex].colors;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 22),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gradientColor,
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: gradientColor.last.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                                offset: Offset(4, 4),
                              ),
                            ],
                            borderRadius: BorderRadius.all(Radius.circular(24)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.label,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      Text(
                                        " " + alarm.title,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'avenir'),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                      icon: Icon(Icons.delete),
                                      color: Colors.white,
                                      onPressed: () {
                                        deleteAlarm(alarm.id);
                                      }),
                                ],
                              ),
                              Text(
                                MyLocalizations
                                    .of(context)
                                    .getText('hour'),
                                style: TextStyle(
                                    color: Colors.white, fontFamily: 'avenir'),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    alarmTime,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'avenir',
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Container(padding: EdgeInsets.only(bottom: 50)),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).followedBy([
                        if (_currentAlarms.length < 5)
                          DottedBorder(
                            strokeWidth: 2,
                            color: Colors.blue,
                            borderType: BorderType.RRect,
                            radius: Radius.circular(24),
                            dashPattern: [5, 4],
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: CustomColors.clockBG,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(24)),
                              ),
                              child: FlatButton(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                                onPressed: () {
                                  _alarmTimeString = DateFormat('HH:mm')
                                      .format(DateTime.now());
                                  showModalBottomSheet(
                                    useRootNavigator: true,
                                    context: context,
                                    clipBehavior: Clip.antiAlias,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(24),
                                      ),
                                    ),
                                    builder: (context) {
                                      return StatefulBuilder(
                                        builder: (context, setModalState) {
                                          return Container(
                                            padding: const EdgeInsets.all(32),
                                            child: Column(
                                              children: [
                                                FlatButton(
                                                  onPressed: () async {
                                                    var selectedTime =
                                                        await showTimePicker(
                                                      context: context,
                                                      initialTime:
                                                          TimeOfDay.now(),
                                                    );
                                                    if (selectedTime != null) {
                                                      final now =
                                                          DateTime.now();
                                                      var selectedDateTime =
                                                          DateTime(
                                                              now.year,
                                                              now.month,
                                                              now.day,
                                                              selectedTime.hour,
                                                              selectedTime
                                                                  .minute);
                                                      _alarmTime =
                                                          selectedDateTime;
                                                      setModalState(() {
                                                        _alarmTimeString =
                                                            DateFormat('HH:mm')
                                                                .format(
                                                                    selectedDateTime);
                                                      });
                                                    }
                                                  },
                                                  child: Text(
                                                    _alarmTimeString,
                                                    style:
                                                        TextStyle(fontSize: 32),
                                                  ),
                                                ),
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 5)),
                                                Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    MyLocalizations
                                                        .of(context)
                                                        .getText('writealarm'),
                                                    style:
                                                        TextStyle(fontSize: 19),
                                                  ),
                                                ),
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 5)),
                                                Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          CustomColors.clockBG,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  24)),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20),
                                                    child: Column(children: [
                                                      VerticalSpacing(),
                                                      TextField(
                                                        maxLength: 20,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 15.0),
                                                        controller:
                                                            nameController,
                                                        textCapitalization:
                                                            TextCapitalization
                                                                .words,
                                                        decoration:
                                                            InputDecoration
                                                                .collapsed(
                                                          hintText: MyLocalizations
                                                                  .of(context)
                                                              .getText(
                                                                  'writename'),
                                                          hintStyle: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ),
                                                    ])),
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 10)),
                                                FloatingActionButton.extended(
                                                  onPressed: () {
                                                    if (nameController.text.trim() != "")
                                                    onSaveAlarm(
                                                        nameController.text);
                                                    else
                                                      Fluttertoast.showToast(
                                                        msg: MyLocalizations
                                                            .of(context)
                                                            .getText('writename'),
                                                      );
                                                  },
                                                  icon: Icon(Icons.alarm),
                                                  label: Text(MyLocalizations
                                                      .of(context)
                                                      .getText(
                                                      'save'),),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                  // scheduleAlarm();
                                },
                                child: Column(
                                  children: <Widget>[
                                    Image.asset(
                                      'assets/img/add_alarm.png',
                                      scale: 1.5,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                        MyLocalizations
                                            .of(context)
                                            .getText(
                                            'addalarm'),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'avenir'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          Center(
                              child: Text(
                                MyLocalizations
                                    .of(context)
                                    .getText('only5'),
                            style: TextStyle(color: Colors.white),
                          )),
                      ]).toList(),
                    );
                  }
                  return Center(
                    child: Text(
                        MyLocalizations
                            .of(context)
                            .getText(
                            'loading'),
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void scheduleAlarm(
      DateTime scheduledNotificationDateTime, AlarmInfo alarmInfo) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'alarm_notif',
      'alarm_notif',
      'Channel for Alarm notification',
      icon: 'codex_logo',
      sound: RawResourceAndroidNotificationSound('a_long_cold_sting'),
      largeIcon: DrawableResourceAndroidBitmap('codex_logo'),
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(

        presentAlert: true,
        presentBadge: true,
        presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.schedule(0, 'PerfectSkin Alarm', alarmInfo.title,
        scheduledNotificationDateTime, platformChannelSpecifics);
  }

  void onSaveAlarm(String name) {
    DateTime scheduleAlarmDateTime;
    if (_alarmTime.isAfter(DateTime.now()))
      scheduleAlarmDateTime = _alarmTime;
    else
      scheduleAlarmDateTime = _alarmTime.add(Duration(days: 1));

    var alarmInfo = AlarmInfo(
      alarmDateTime: scheduleAlarmDateTime,
      gradientColorIndex: _currentAlarms.length,
      title: name,
    );
    _alarmHelper.insertAlarm(alarmInfo);
    scheduleAlarm(scheduleAlarmDateTime, alarmInfo);
    Navigator.pop(context);
    loadAlarms();
  }

  void deleteAlarm(int id) {
    _alarmHelper.delete(id);
    //unsubscribe for notification
    loadAlarms();
  }
}
