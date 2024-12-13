import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabebi/app/routes.dart';
import 'package:tabebi/cubits/specialityCubit.dart';
import 'package:tabebi/helper/api.dart';
import 'package:tabebi/helper/apiParams.dart';
import 'package:tabebi/helper/constant.dart';
import 'package:tabebi/helper/generaWidgets.dart';
import 'package:tabebi/screens/mainHome/homePage.dart';
import 'package:tabebi/screens/myAppointment/myAppointmentMain.dart';
import 'package:tabebi/screens/myRecords/myRecordsMain.dart';
import '../../cubits/auth/loginCubit.dart';
import '../../cubits/hospital/subscribedHospitalCubit.dart';
import '../../helper/generalMethods.dart';
import '../../helper/notificationHandler.dart';
import '../../helper/sessionManager.dart';
import '../../helper/stringLables.dart';
import 'drawerWidget.dart';

StreamController<bool>? currentUserCity;
StreamController<bool>? settingController;
String myAppointmentSelectedtype = Constant.appointmentDoctor;
int myAppointmentInitialTab = 0;
GlobalKey<MainPageState>? mainPagestate;

class MainPage extends StatefulWidget {
  final String from;
  const MainPage({super.key, required this.from});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int currPageIndex = 0;

  @override
  void initState() {
    super.initState();
    mainPagestate = GlobalKey<MainPageState>();
    currentUserCity = StreamController<bool>.broadcast();
    settingController = StreamController<bool>.broadcast();
    print("mainfrom=>${widget.from}");
    Future.delayed(Duration.zero, () {
      setConfig();
    });
    //printIps();
  }

/*   Future printIps() async {
    for (var interface in await NetworkInterface.list()) {
      print('== Interface: ${interface.name} ==');
      for (var addr in interface.addresses) {
        print(
            'ip-chk=>addr=${addr.address}=host=${addr.host}=loopback=${addr.isLoopback} ${addr.rawAddress} ${addr.type.name}');
      }
    }
  } */

  setConfig() async {
    loadData();
    if (mounted) {
      Future.delayed(Duration.zero, () {
        NotificationHandler().setNotificationsConfigs(context);
      });
    }
    Future.delayed(Duration.zero, () {
      redirectToPage();
    });
    GeneralMethods.setRecentList();
  }

  loadData() {
    bool isLogin = Constant.session!.isUserLoggedIn();
    if (isLogin) {
      Api.getUserInfo(context);
    }
    //context.read<SubscribeHospitalCubit>().getHospitalList(context, {});

    context
        .read<SubscribeHospitalCubit>()
        .loadPosts(context, {ApiParams.isSubscribe: "1"}, isloadlocal: true);
    context.read<SpecialityCubit>().loadPosts(context, {}, isloadlocal: true);
    //
    /* List<String> fromdata = widget.from.split("==");
    String key = fromdata.first;
    if (isLogin && key == "splash") {
      context.read<DoctorAppointmentCubit>().loadPosts(
          context,
          {
            ApiParams.time: ApiParams.current,
            ApiParams.type: Constant.appointmentDoctor
          },
          isSetInitial: true);
    }*/
    //
  }

  redirectToPage() {
    List<String> fromdata = widget.from.split("==");
    String key = fromdata.first;
    String value = fromdata.last;

    print("deeplinkparams-->$key==initial-$value");
    if (key == "splash" &&
        Constant.session!.isUserLoggedIn() &&
        Constant.session!.getData(SessionManager.keyName).trim().isEmpty) {
      GeneralMethods.goToNextPage(Routes.editProfilePage, context, false,
          args: true);
    } else if (key == "doctor") {
      GeneralMethods.goToNextPage(Routes.doctorDetailPage, context, false,
          args: {"drId": value});
    } else if (key == "lab") {
      GeneralMethods.goToNextPage(Routes.labDetailPage, context, false,
          args: {"labId": value, "fromSelectTest": false});
    } else if (key == "appointment") {
      myAppointmentSelectedtype = value;
      onBottomItemTapped(1);
    } else if (key == "myreport") {
      onBottomItemTapped(2);
    } else if (key == "notification") {
      goToNotificationPage();
    }
  }

  @override
  void dispose() {
    currentUserCity!.close();
    settingController!.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: appbarWidget(),
      drawer: DrawerWidget(
        scaffoldKey: _scaffoldKey,
        indexChangeCallback: onBottomItemTapped,
      ),
      bottomNavigationBar: bottomNavigationbarWidget(),
      body: bodyContent(),
    );
  }

  bodyContent() {
    return IndexedStack(index: currPageIndex, children: [
      HomePage(
        indexChangeCallback: onBottomItemTapped,
      ),
      MyAppointmentMain(
        appointmentType: myAppointmentSelectedtype,
        initialIndex: myAppointmentInitialTab,
      ),
      MyRecordsMain()
    ]);
  }

  bottomNavigationbarWidget() {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Padding(
              padding: const EdgeInsets.only(bottom: 5, top: 5),
              child: GeneralWidgets.setSvg("home")),
          activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: 5, top: 5),
              child: GeneralWidgets.setSvg("active_home")),
          label: getLables(lblHome),
        ),
        BottomNavigationBarItem(
          icon: Padding(
              padding: const EdgeInsets.only(bottom: 5, top: 5),
              child: GeneralWidgets.setSvg("appointment")),
          activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: 5, top: 5),
              child: GeneralWidgets.setSvg("active_appointment")),
          label: getLables(lblMyAppointment),
        ),
        BottomNavigationBarItem(
          icon: Padding(
              padding: const EdgeInsets.only(bottom: 5, top: 5),
              child: GeneralWidgets.setSvg("records")),
          activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: 5, top: 5),
              child: GeneralWidgets.setSvg("active_records")),
          label: getLables(lblMyRecords),
        ),
      ],
      currentIndex: currPageIndex,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      onTap: onBottomItemTapped,
      type: BottomNavigationBarType.fixed,
    );
  }

  void onBottomItemTapped(int index) {
    setState(() {
      currPageIndex = index;
    });
  }

  goToNotificationPage() {
    GeneralMethods.goToNextPage(Routes.notificationListPage, context, false);
  }

  appbarTitle() {
    return currPageIndex == 0
        ? GeneralWidgets.setSvg("homelogo")
        : Text(getLables(currPageIndex == 1 ? lblMyAppointment : lblMyRecords));
  }

  appbarWidget() {
    return GeneralWidgets.setAppbar(getLables(appName), context,
        titleWidget: appbarTitle(),
        elevation: currPageIndex == 0 ? 4 : 0,
        leadingwidget: IconButton(
            onPressed: () {
              _scaffoldKey.currentState!.openDrawer();
            },
            icon: GeneralWidgets.setSvg("sidemenu")),
        actions: [notificationIconWidget()]);
  }

  notificationIconWidget() {
    return BlocBuilder<LogInCubit, LogInState>(
      builder: (context, state) {
        return Constant.session!.isUserLoggedIn()
            ? IconButton(
                onPressed: () {
                  goToNotificationPage();
                },
                icon: GeneralWidgets.setSvg("notification"))
            : SizedBox.shrink();
      },
    );
  }
}
