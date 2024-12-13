import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabebi/helper/constant.dart';

import '../../cubits/doctor/favouriteDoctorCubit.dart';
import '../../helper/colors.dart';
import '../../helper/generaWidgets.dart';
import '../../helper/generalMethods.dart';
import '../../helper/stringLables.dart';
import 'favDoctorListPage.dart';

class FavouriteMain extends StatefulWidget {
  const FavouriteMain({Key? key}) : super(key: key);

  @override
  FavouriteMainState createState() => FavouriteMainState();
}

class FavouriteMainState extends State<FavouriteMain>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: GeneralWidgets.setAppbar(getLables(lblMyFavorite), context,
            bottomwidget: tabbarWidget()),
        body: TabBarView(
          controller: tabController,
          children: [
            tabBodyWidget(Constant.appointmentDoctor),
            tabBodyWidget(Constant.appointmentLab),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  tabbarWidget() {
    return TabBar(
      controller: tabController,
      labelColor: primaryColor,
      unselectedLabelColor: grey,
      indicatorColor: primaryColor,
      tabs: [
        getTabWidget(lblDoctors),
        getTabWidget(lblLabs),
      ],
    );
  }

  getTabWidget(String lbl) {
    return Tab(
      text: getLables(lbl),
    );
  }

  tabBodyWidget(String type) {
    return BlocProvider(
      create: (context) => FavDoctorCubit(),
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 8),
        child: FavDoctorListPage(type: type),
      ),
    );
  }
}
