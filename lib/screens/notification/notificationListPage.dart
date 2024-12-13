import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tabebi/app/routes.dart';
import 'package:tabebi/cubits/appointment/labAppointmentCubit.dart';
import 'package:tabebi/helper/colors.dart';
import 'package:tabebi/helper/designConfig.dart';
import 'package:tabebi/helper/stringLables.dart';

import '../../cubits/appointment/drAppointmentCubit.dart';
import '../../cubits/notificationCubit.dart';
import '../../helper/apiParams.dart';
import '../../helper/constant.dart';
import '../../helper/generaWidgets.dart';
import '../../helper/generalMethods.dart';
import '../../helper/readMoreText.dart';
import '../../models/notificationData.dart';
import '../mainHome/mainPage.dart';
import '../myRecords/myRecordsMain.dart';

NotificationData? selectedNotification;

class NotificationListPage extends StatefulWidget {
  const NotificationListPage({Key? key}) : super(key: key);

  @override
  NotificationListPageState createState() => NotificationListPageState();
}

class NotificationListPageState extends State<NotificationListPage> {
  final scrollController = ScrollController();

  List<NotificationData> loadedlist = [];
  int loadedpage = 1, loadedoffset = 0;
  @override
  void initState() {
    super.initState();
    print("init===****Notification");
    setupScrollController(context);
    loadPage();
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadPage({bool isSetInitial = false, Map<String, String>? parameter}) {
    parameter ??= {};
    print(
        "currpage=${BlocProvider.of<NotificationCubit>(context).offset}==$isSetInitial");
    /* if (isSetInitial) {
      BlocProvider.of<NotificationCubit>(context).setInitialState();
    } */
    BlocProvider.of<NotificationCubit>(context)
        .loadPosts(context, parameter, isSetInitial: isSetInitial);
  }

  setupScrollController(context) {
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels != 0) {
          loadPage();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralWidgets.setAppbar(getLables(lblNotifications), context),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          return contentWidget(state);
        },
      ),
    );
  }

  contentWidget(NotificationState state) {
    if (state is NotificationProgress && state.isFirstFetch) {
      return GeneralWidgets.loadingIndicator();
    } else if (state is NotificationFailure) {
      return GeneralWidgets.msgWithTryAgain(
          state.errorMessage, () => loadPage(isSetInitial: true));
    }
    return listContent(state);
  }

  NotificationWidget(NotificationData post, BuildContext context, int index) {
    return GestureDetector(
        onTap: () {
          redirectToPage(post);

          /*if (!post.isRead!) {
            post.isRead = true;
            loadedlist.removeAt(index);
            loadedlist.insert(index, post);

            BlocProvider.of<NotificationCubit>(context)
                .setOldList(loadedoffset, loadedpage, loadedlist);
          }*/
        },
        child: GeneralWidgets.cardBoxWidget(
            celevation: 0,
            cpadding:
                EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 8),
            cshape: DesignConfig.setRoundedBorder(5, false),
            //cshape: DesignConfig.setRoundedBorder(5, !post.isRead!,bordercolor: post.isRead! ? Colors.transparent : primaryColor,bwidth: post.isRead! ? 0 : 1.5),
            childWidget: Row(children: [
              if (post.image != null && post.image!.trim().isNotEmpty)
                GeneralWidgets.cardBoxWidget(
                    cmargin: EdgeInsetsDirectional.only(end: 10),
                    cpadding: EdgeInsetsDirectional.zero,
                    childWidget: GeneralWidgets.setNetworkImg(post.image,
                        height: 50, width: 50, boxFit: BoxFit.fill)),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .apply(color: primaryColor),
                      ),
                      ReadMoreText(
                        post.message,
                        trimLines: 2,
                        colorClickableText: primaryColor,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: ' ${getLables(lblReadmore)} ',
                        trimExpandedText: ' ${getLables(lblReadless)} ',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .apply(color: primaryColor),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        DateFormat("hh:mm a, dd MMM yyyy",
                                Constant.session!.getCurrLangCode())
                            .format(Constant.backendDateParser
                                .parse(post.createdAt!)),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: grey),
                      )
                    ]),
              )
            ])));
  }

  redirectToPage(NotificationData notification) {
    String type = notification.type!;
    Map data = notification.data!;

    if (type == Constant.notificationAddVisitAppointment ||
        type == Constant.notificationRescheduleAppointment ||
        type == Constant.notificationCancelAppointment ||
        type == Constant.notificationDoctorAppointmentReminder) {
      /* String apitime = ApiParams.current;
      if (data.isNotEmpty) {
        final now = DateTime.now();
        DateTime todayDate = DateTime(now.year, now.month, now.day);
        DateTime aDate = Constant.backendDateFormat.parse(data[ApiParams.date]);
        print("adate=>$aDate");
        apitime =
            aDate.isBefore(todayDate) ? ApiParams.past : ApiParams.current;
      }
      context.read<DoctorAppointmentCubit>().loadPosts(context,
          {ApiParams.time: apitime, ApiParams.type: Constant.appointmentDoctor},
          isSetInitial: true);
      myAppointmentSelectedtype = Constant.appointmentDoctor;
      myAppointmentInitialTab = apitime == ApiParams.current ? 0 : 1;
      if (Routes.currentRoute == Routes.mainPage) {
        mainPagestate!.currentState!.onBottomItemTapped(1);
      } else {
        GeneralMethods.killPreviousPages(context, Routes.mainPage,
            args: "appointment==$myAppointmentSelectedtype");
      }*/
      goToAppointmentPage(Constant.appointmentDoctor,
          context.read<DoctorAppointmentCubit>(), data);
    } else if (type == Constant.notificationLabAppointment ||
        type == Constant.notificationLabAppointmentReminder) {
      goToAppointmentPage(
          Constant.appointmentLab, context.read<LabAppointmentCubit>(), data);
    } else if (type == Constant.notificationMyReport) {
      if (Routes.currentRoute == Routes.mainPage) {
        if (myrecordstate != null && myrecordstate!.currentState != null) {
          myrecordstate!.currentState!.loadPage(isSetInitial: true);
        }
        mainPagestate!.currentState!.onBottomItemTapped(2);
      } else {
        GeneralMethods.killPreviousPages(context, Routes.mainPage,
            args: "myreport==");
      }
    } else {
      selectedNotification = notification;
      Future.delayed(Duration.zero, () {
        GeneralMethods.goToNextPage(
            Routes.notificationDetailPage, context, false);
      });
    }
  }

  goToAppointmentPage(String appointmenttype, var cubit, Map otherdata) {
    String apitime = ApiParams.current;
    if (otherdata.isNotEmpty) {
      final now = DateTime.now();
      DateTime todayDate = DateTime(now.year, now.month, now.day);
      DateTime aDate =
          Constant.backendDateFormat.parse(otherdata[ApiParams.date]);

      apitime = aDate.isBefore(todayDate) ? ApiParams.past : ApiParams.current;
    }
    cubit.loadPosts(
        context, {ApiParams.time: apitime, ApiParams.type: appointmenttype},
        isSetInitial: true);

    /* bcontext.read<DoctorAppointmentCubit>().loadPosts(
          bcontext, {ApiParams.time: apitime, ApiParams.type: Constant.appointmentDoctor},
          isSetInitial: true); */

    myAppointmentSelectedtype = appointmenttype;
    myAppointmentInitialTab = apitime == ApiParams.current ? 0 : 1;
    if (Routes.currentRoute == Routes.mainPage) {
      mainPagestate!.currentState!.onBottomItemTapped(1);
    } else {
      GeneralMethods.killPreviousPages(context, Routes.mainPage,
          args: "appointment==$myAppointmentSelectedtype");
    }
  }

  listContent(NotificationState state) {
    List<NotificationData> posts = [];
    bool isLoading = false;
    int currpage = 1;
    int curroffset = 0;
    if (state is NotificationProgress) {
      posts = state.oldNotificationList;
      isLoading = true;
      currpage = state.currPage;
      curroffset = state.currOffset;
    } else if (state is NotificationSuccess) {
      posts = state.NotificationList;
      currpage = state.currPage;
      curroffset = state.currOffset;
    }

    if (posts.isNotEmpty) {
      loadedpage = currpage;
      loadedoffset = curroffset;
      loadedlist = [];
      loadedlist = posts;
    }

    return RefreshIndicator(
      onRefresh: refreshList,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        controller: scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (index < posts.length)
            return NotificationWidget(posts[index], context, index);
          else {
            Timer(Duration(milliseconds: 30), () {
              scrollController
                  .jumpTo(scrollController.position.maxScrollExtent);
            });

            return GeneralWidgets.loadingIndicator();
          }
        },
        itemCount: posts.length + (isLoading ? 1 : 0),
      ),
    );
  }

  Future<void> refreshList() async {
    loadPage(isSetInitial: true);
  }
}
