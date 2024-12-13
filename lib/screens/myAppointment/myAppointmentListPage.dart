import 'package:flutter/material.dart';
import 'package:tabebi/helper/colors.dart';
import 'package:tabebi/helper/constant.dart';
import 'package:tabebi/helper/generalMethods.dart';
import 'package:tabebi/screens/myAppointment/drAppointmentList.dart';
import 'package:tabebi/screens/myAppointment/labAppointmentList.dart';
import '../../helper/generaWidgets.dart';
import '../../helper/stringLables.dart';

class MyAppointmentListPage extends StatefulWidget {
  final int tabindex;
  final String appointmentType;
  const MyAppointmentListPage(
      {Key? key, required this.tabindex, required this.appointmentType})
      : super(key: key);

  @override
  MyAppointmentListPageState createState() => MyAppointmentListPageState();
}

class MyAppointmentListPageState extends State<MyAppointmentListPage>
    with AutomaticKeepAliveClientMixin {
  bool get wantKeepAlive => true;
  int selectedTab = 0;
  @override
  void initState() {
    super.initState();
    if (widget.appointmentType == Constant.appointmentLab) {
      selectedTab = 1;
    }
    print(
        "my--type->$selectedTab===${widget.appointmentType}===${widget.appointmentType == Constant.appointmentLab}");
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        btnWidget(),
        const SizedBox(height: 8),
        Expanded(
            child: IndexedStack(index: selectedTab, children: [
          DrAppointmentList(tabindex: widget.tabindex),
          LabAppointmentList(
            tabindex: widget.tabindex,
          )
        ]))
      ],
    );
  }

  btnWidget() {
    return Row(
      children: [
        Expanded(child: btnitemWidget(0, lblDoctorAppointment)),
        const SizedBox(width: 8),
        Expanded(child: btnitemWidget(1, lblLabAppointment)),
      ],
    );
  }

  btnitemWidget(int tab, String lbl) {
    return GeneralWidgets.textButtonWidget(
        selectedTab == tab, getLables(lbl), context, () {
      if (selectedTab != tab) {
        setState(() {
          selectedTab = tab;
        });
      }
    },
        unselectedcolor: appbarColor,
        tpadding: EdgeInsetsDirectional.symmetric(vertical: 10));
  }
}
