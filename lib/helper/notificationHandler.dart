import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabebi/cubits/appointment/labAppointmentCubit.dart';
import 'package:tabebi/screens/myRecords/myRecordsMain.dart';

import '../app/routes.dart';
import '../cubits/appointment/drAppointmentCubit.dart';
import '../cubits/notificationCubit.dart';
import '../screens/mainHome/mainPage.dart';
import 'api.dart';
import 'apiParams.dart';
import 'constant.dart';
import 'generalMethods.dart';
import 'sessionManager.dart';

bool isshownotification = false;
late BuildContext bcontext;

@pragma('vm:entry-point')
void onBackgroundMessageLocal(NotificationResponse message) async {
  await Firebase.initializeApp();
  //print("notification bg--${message.data}");
/*   Map<String, dynamic> data = jsonDecode(message.payload!);
  String type = data['type']; */
}

@pragma('vm:entry-point')
Future<void> onBackgroundMessageFirebase(RemoteMessage message) async {
  await Firebase.initializeApp();
  //print("notification bg--${message.data}");
  var data = message.data;
}

class NotificationHandler {
  final _firebaseMessaging = FirebaseMessaging.instance;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late AndroidNotificationChannel channel;
  bool isFlutterLocalNotificationsInitialized = false;

  setNotificationsConfigs(BuildContext mcontext) async {
    print("notification-setNotificationsConfigs-->");
    bcontext = mcontext;
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessageFirebase);

    channel = const AndroidNotificationChannel(
      'com.app.tabebiuser',
      'Tabebi',
      description: 'Tabebi',
      importance: Importance.high,
    );
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: true,
      //
      // onDidReceiveLocalNotification:
      //     (int id, String? title, String? body, String? payload) async {
      //   /*didReceiveLocalNotificationStream.add(
      //     ReceivedNotification(
      //       id: id,
      //       title: title,
      //       body: body,
      //       payload: payload,
      //     ),
      //   );*/
      // },
      notificationCategories: [],
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            onSelectNotification(notificationResponse.payload!);
            break;
          /*case NotificationResponseType.selectedNotificationAction:
            if (notificationResponse.actionId == navigationActionId) {
              selectNotificationStream.add(notificationResponse.payload);
            }
            break;*/
          case NotificationResponseType.selectedNotificationAction:
            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: onBackgroundMessageLocal,
    );
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.instance.getInitialMessage().then((value) {
      if (value != null) {
        print(
            "notification-initial-data--${value.messageId}->${value.data.toString()}");
        onSelectNotification(jsonEncode(value.data));
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(
          "notification-listen-data--${message.messageId}->${message.data.toString()}");
      // onSelectNotification(jsonEncode(message.data));
      setNotificationData(message.data, isRedirect: true);
    });

    NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    //print( "notification-launch-notification--->${notificationAppLaunchDetails!.didNotificationLaunchApp}");
    //print( "notification-launch-notification-payload-->${notificationAppLaunchDetails.payload}");

    if (notificationAppLaunchDetails!.didNotificationLaunchApp &&
        notificationAppLaunchDetails.notificationResponse != null &&
        notificationAppLaunchDetails
                .notificationResponse!.notificationResponseType ==
            NotificationResponseType.selectedNotification) {
      onSelectNotification(jsonEncode(
          notificationAppLaunchDetails.notificationResponse!.payload));
    }
    FirebaseMessaging.onMessage.listen((message) async {
      print("notification-onmsg-data->${message.data.toString()}");

      /*RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;*/
      showNotification(message.data, message.messageId);
    });
    try {
      await _firebaseMessaging.getToken().then((value) {
        print("notification-fcmtoken=>token->$value");
        if (Constant.session!.isUserLoggedIn()) {
          setDeviceToken(value);
        }
      });
    } catch (e) {
      print("notification-fcmtoken=>err->${e.toString()}");
    }
    isFlutterLocalNotificationsInitialized = true;
  }

  onSelectNotification(String? payload, {bool isRedirect = true}) async {
    Map<String, dynamic> data = jsonDecode(payload!);
    print("notification-select-notification-->$data");
//supportNotificationType
    String type = data[ApiParams.type];
    if (type == Constant.notificationAddVisitAppointment ||
        type == Constant.notificationRescheduleAppointment ||
        type == Constant.notificationCancelAppointment ||
        type == Constant.notificationDoctorAppointmentReminder) {
      goToAppointmentPage(data, isRedirect, Constant.appointmentDoctor,
          bcontext.read<DoctorAppointmentCubit>());
    } else if (type == Constant.notificationLabAppointment ||
        type == Constant.notificationLabAppointmentReminder) {
      goToAppointmentPage(data, isRedirect, Constant.appointmentLab,
          bcontext.read<LabAppointmentCubit>());
    } else if (type == Constant.notificationMyReport) {
      if (Routes.currentRoute == Routes.mainPage) {
        if (isRedirect)
          mainPagestate!.currentState!.onBottomItemTapped(2);
        else if (myrecordstate != null && myrecordstate!.currentState != null) {
          myrecordstate!.currentState!.loadPage(isSetInitial: true);
        }
      } else if (isRedirect) {
        GeneralMethods.killPreviousPages(bcontext, Routes.mainPage,
            args: "myreport==");
      }
    } else if (type == Constant.notificationAdmin) {
      if (Routes.currentRoute == Routes.notificationListPage) {
        bcontext
            .read<NotificationCubit>()
            .loadPosts(bcontext, {}, isSetInitial: true);
      } else if (isRedirect) {
        GeneralMethods.goToNextPage(
          Routes.notificationListPage,
          bcontext,
          false,
        );
      }
    }
  }

  goToAppointmentPage(Map<String, dynamic> data, bool isRedirect,
      String appointmenttype, var cubit) {
    Map otherdata = json.decode(data["other_data"]);
    String apitime = ApiParams.current;
    if (otherdata.isNotEmpty) {
      final now = DateTime.now();
      DateTime todayDate = DateTime(now.year, now.month, now.day);
      DateTime aDate =
          Constant.backendDateFormat.parse(otherdata[ApiParams.date]);

      apitime = aDate.isBefore(todayDate) ? ApiParams.past : ApiParams.current;
    }
    cubit.loadPosts(
        bcontext, {ApiParams.time: apitime, ApiParams.type: appointmenttype},
        isSetInitial: true);

    /* bcontext.read<DoctorAppointmentCubit>().loadPosts(
          bcontext, {ApiParams.time: apitime, ApiParams.type: Constant.appointmentDoctor},
          isSetInitial: true); */

    if (isRedirect) {
      myAppointmentSelectedtype = appointmenttype;
      myAppointmentInitialTab = apitime == ApiParams.current ? 0 : 1;
      if (Routes.currentRoute == Routes.mainPage) {
        if (mainPagestate!.currentState == null) {
          mainPagestate = GlobalKey<MainPageState>();
        }
        mainPagestate!.currentState!.onBottomItemTapped(1);
      } else {
        GeneralMethods.killPreviousPages(bcontext, Routes.mainPage,
            args: "appointment==$myAppointmentSelectedtype");
      }
    }
  }

  setDeviceToken(var fcmtoken) async {
    print("notification-fcmtoken->$fcmtoken");

    try {
      if (Constant.session!.getData(SessionManager.keyFcmToken) != fcmtoken) {
        Map<String, String> body = {
          ApiParams.fcmId: fcmtoken,
        };

        var response = await Api.sendApiRequest(
            ApiParams.apiUpdateProfile, body, true, bcontext);
        final res = json.decode(response);
        if (res[ApiParams.error]) {
          Constant.session!.setData(SessionManager.keyFcmToken, fcmtoken);
        }
      }
    } on Exception catch (_) {}
  }

  showNotification(Map<String, dynamic> data, String? messageId) async {
    // do not show no
    if (!Constant.session!.isUserLoggedIn()) return;

    bool isshownotification = setNotificationData(data);
    print("notification->isshownotification-$isshownotification");
    print("notification->data-$data");
    if (isshownotification) {
      final prefs = await SharedPreferences.getInstance();

      // check message ID is valid or not
      prefs.setBool('hasMsgId', messageId != null ? true : false);

      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          channel.id, channel.name,
          channelDescription: channel.description,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true);

      var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();

      var platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
          data.hashCode, data['title'], data['body'], platformChannelSpecifics,
          payload: jsonEncode(data));
    }
  }

  setNotificationData(Map<String, dynamic> data, {bool isRedirect = false}) {
    //print("notification-show==${Constant.userdata!.id}--$data");
    isshownotification = true;

    onSelectNotification(jsonEncode(data), isRedirect: isRedirect);

    return isshownotification;
  }
}
