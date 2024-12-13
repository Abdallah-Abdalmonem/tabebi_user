import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabebi/cubits/myRecordCubit.dart';
import 'package:tabebi/screens/myRecords/noDataWidget.dart';

import '../../cubits/auth/loginCubit.dart';
import '../../helper/colors.dart';
import '../../helper/constant.dart';
import '../../helper/generalMethods.dart';
import '../../helper/stringLables.dart';
import 'myRecordListPage.dart';

GlobalKey<MyRecordListPageState>? myrecordstate;

class MyRecordsMain extends StatefulWidget {
  const MyRecordsMain({Key? key}) : super(key: key);

  @override
  MyRecordsMainState createState() => MyRecordsMainState();
}

class MyRecordsMainState extends State<MyRecordsMain>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  bool get wantKeepAlive => true;
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
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
              getTabWidget(lblMyReports),
              getTabWidget(lblDrPrescriptions),
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

  getTabWidget(String lbl) {
    return Tab(
      text: getLables(lbl),
    );
  }

  tabBodyWidget(int tabindex) {
    return BlocBuilder<LogInCubit, LogInState>(
      builder: (context, state) {
        print("recordinit======login==${Constant.session!.isUserLoggedIn()}");
        if (Constant.session!.isUserLoggedIn() && tabindex == 0) {
          myrecordstate = GlobalKey<MyRecordListPageState>();
        }
        return Constant.session!.isUserLoggedIn()
            ? BlocProvider(
                create: (context) => MyRecordCubit(),
                child: Padding(
                  padding: EdgeInsetsDirectional.symmetric(
                      horizontal: 8, vertical: 8),
                  child: MyRecordListPage(tabindex: tabindex),
                ),
              )
            : noDataWidget(tabindex == 0, context, null, null);
      },
    );
  }
}
