import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabebi/cubits/auth/loginCubit.dart';
import 'package:tabebi/helper/colors.dart';
import 'package:tabebi/helper/constant.dart';
import 'package:tabebi/helper/generalMethods.dart';
import '../../cubits/appointment/drAppointmentCubit.dart';
import '../../cubits/appointment/labAppointmentCubit.dart';
import '../../helper/stringLables.dart';
import 'myAppointmentListPage.dart';
import 'noAppointmentWidget.dart';

class MyAppointmentMain extends StatefulWidget {
  final String? appointmentType;
  final int? initialIndex;
  const MyAppointmentMain(
      {Key? key, required this.appointmentType, this.initialIndex = 0})
      : super(key: key);

  @override
  MyAppointmentMainState createState() => MyAppointmentMainState();
}

class MyAppointmentMainState extends State<MyAppointmentMain>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  bool get wantKeepAlive => true;
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.initialIndex!);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Container(
          height: 45,
          decoration: BoxDecoration(boxShadow: <BoxShadow>[
            BoxShadow(
                color: lightGrey, blurRadius: 15.0, offset: Offset(0.0, 0.75))
          ], color: appbarColor),
          child: TabBar(
            controller: tabController,
            labelColor: primaryColor,
            unselectedLabelColor: grey,
            indicatorColor: primaryColor,
            tabs: [
              Tab(
                text: getLables(lblCurrent),
              ),
              Tab(
                text: getLables(lblPast),
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              tabBodyWidget(0),
              tabBodyWidget(1),
            ],
          ),
        ),
      ],
    );
  }

  tabBodyWidget(int tabindex) {
    return BlocBuilder<LogInCubit, LogInState>(
      builder: (context, state) {
        return Constant.session!.isUserLoggedIn()
            ? Padding(
                padding:
                    EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 8),
                child: tabindex == 0
                    ? appointmentListWidget(tabindex)
                    : MultiBlocProvider(providers: [
                        BlocProvider(
                            create: (context) => DoctorAppointmentCubit()),
                        BlocProvider(
                            create: (context) => LabAppointmentCubit()),
                      ], child: appointmentListWidget(tabindex)),
              )
            : NoAppointmentWidget();
      },
    );
  }

  appointmentListWidget(int tabindex) {
    return MyAppointmentListPage(
      tabindex: tabindex,
      appointmentType: widget.appointmentType!,
    );
  }
}
