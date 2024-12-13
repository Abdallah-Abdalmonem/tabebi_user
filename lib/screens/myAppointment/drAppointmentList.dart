import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tabebi/helper/apiParams.dart';
import 'package:tabebi/helper/constant.dart';
import 'package:tabebi/screens/myAppointment/appointmentBtnWidgets.dart';
import 'package:tabebi/screens/myAppointment/noAppointmentWidget.dart';
import '../../cubits/appointment/drAppointmentCubit.dart';
import '../../helper/colors.dart';
import '../../helper/generaWidgets.dart';
import '../../models/appointment.dart';

class DrAppointmentList extends StatefulWidget {
  final int tabindex;
  const DrAppointmentList({Key? key, required this.tabindex}) : super(key: key);

  @override
  DrAppointmentListState createState() => DrAppointmentListState();
}

class DrAppointmentListState extends State<DrAppointmentList>
    with AutomaticKeepAliveClientMixin {
  List<Appointment> loadedlist = [];
  int loadedpage = 1, loadedoffset = 0;
  final scrollController = ScrollController();
  Map<String, String> apiparams = {};
  @override
  void initState() {
    super.initState();
    apiparams = {
      ApiParams.time: widget.tabindex == 0 ? ApiParams.current : ApiParams.past,
      ApiParams.type: Constant.appointmentDoctor
    };
    setupScrollController(context);
    print(
        "loaddrstate--${BlocProvider.of<DoctorAppointmentCubit>(context).state}");
    //if (BlocProvider.of<DoctorAppointmentCubit>(context).state is! DoctorAppointmentLoaded) {
    print("loadstate==dr");
    if (context.read<DoctorAppointmentCubit>().state
            is DoctorAppointmentInitial ||
        context.read<DoctorAppointmentCubit>().state
            is DoctorAppointmentFailure) {
      loadPage(isSetInitial: true);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadPage({bool isSetInitial = false}) {
    context
        .read<DoctorAppointmentCubit>()
        .loadPosts(context, apiparams, isSetInitial: isSetInitial);

    print("currpage=${BlocProvider.of<DoctorAppointmentCubit>(context).page}");
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
    super.build(context);
    return contentWidget();
  }

  contentWidget() {
    return BlocBuilder<DoctorAppointmentCubit, DoctorAppointmentState>(
      builder: (context, state) {
        print("state->${state}");
        if (state is DoctorAppointmentLoading && state.isFirstFetch) {
          return GeneralWidgets.loadingIndicator();
        } else if (state is DoctorAppointmentFailure) {
          return NoAppointmentWidget(
            apiparams: apiparams,
            doctorAppointmentCubit: context.read<DoctorAppointmentCubit>(),
          );
          /*return GeneralWidgets.msgWithTryAgain(
              state.errorMessage, () => loadPage(isSetInitial: true));*/
        }
        return listContent(state);
      },
    );
  }

  Future<void> refreshList() async {
    print("---refesh******");
    loadPage(isSetInitial: true);
  }

  listContent(DoctorAppointmentState state) {
    List<Appointment> posts = [];
    bool isLoading = false;
    int currpage = 1, offset = 0;
    if (state is DoctorAppointmentLoading) {
      posts = state.oldAppointmentList;
      isLoading = true;
      currpage = state.currPage;
      offset = state.currOffset;
    } else if (state is DoctorAppointmentLoaded) {
      posts = state.appointmentList;
      currpage = state.currPage;
      offset = state.currOffset;
    }

    loadedpage = currpage;
    loadedlist = [];
    loadedlist = posts;
    loadedoffset = offset;

    return RefreshIndicator(
      onRefresh: refreshList,
      child: ListView.separated(
        controller: scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 2),
        itemBuilder: (context, index) {
          if (index < posts.length)
            return drItemWidget(posts[index], index);
          else {
            Timer(Duration(milliseconds: 30), () {
              scrollController
                  .jumpTo(scrollController.position.maxScrollExtent);
            });

            return GeneralWidgets.loadingIndicator();
          }
        },
        separatorBuilder: (context, index) {
          return SizedBox(
            height: 10,
          );
        },
        itemCount: posts.length + (isLoading ? 1 : 0),
      ),
    );
  }

  drItemWidget(Appointment post, int index) {
    return GeneralWidgets.cardBoxWidget(
        celevation: 1,
        cmargin: EdgeInsetsDirectional.zero,
        cpadding:
            const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 12),
        childWidget: Column(
          children: [
            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  GeneralWidgets.circularImage(post.doctor!.image,
                      height: 60, width: 60),
                  const SizedBox(width: 15),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                        Text(
                          Constant.session!.getCurrLangCode() ==
                                  Constant.arabicLanguageCode
                              ? post.doctor!.nameAr!
                              : post.doctor!.nameEng!,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .merge(TextStyle(fontWeight: FontWeight.normal)),
                        ),
                        Text(
                          post.displayName!,
                          style: Theme.of(context).textTheme.titleSmall!.merge(
                              TextStyle(color: primaryColor.withOpacity(0.8))),
                        ),
                        const SizedBox(height: 3),
                        iconTextWidget(
                            Icons.schedule,
                            DateFormat("dd MMM yyyy, hh:mm a",
                                    Constant.session!.getCurrLangCode())
                                .format(DateTime.parse(
                                    "${post.date} ${post.time}"))),
                        const SizedBox(height: 3),
                        iconTextWidget(
                            Icons.local_hospital, post.doctor!.hospital!.name!),
                        GeneralWidgets.statusWidget(
                            Constant.getAppoinmentStatus(post.status!),
                            context),
                      ]))
                ]),
            const SizedBox(height: 8),
            AppointmentBtnWidgets(
              appointment: post,
              index: index,
              callback: reviewUpdate,
            )
          ],
        ));
  }

  iconTextWidget(IconData icon, String lbl) {
    return Row(children: [
      Icon(
        icon,
        color: primaryColor,
        size: 15,
      ),
      const SizedBox(width: 8),
      Expanded(
          child: Text(
        lbl,
        style: Theme.of(context).textTheme.bodySmall!,
      ))
    ]);
  }

  reviewUpdate(int index, Appointment post) {
    loadedlist.removeAt(index);
    loadedlist.insert(index, post);
    context
        .read<DoctorAppointmentCubit>()
        .setOldList(loadedoffset, loadedpage, loadedlist);
  }

  @override
  bool get wantKeepAlive => true;
}
