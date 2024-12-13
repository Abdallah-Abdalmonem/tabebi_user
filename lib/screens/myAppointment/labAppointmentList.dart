import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tabebi/cubits/appointment/labAppointmentCubit.dart';
import 'package:tabebi/models/appointment.dart';
import '../../helper/apiParams.dart';
import '../../helper/colors.dart';
import '../../helper/constant.dart';
import '../../helper/generaWidgets.dart';
import 'appointmentBtnWidgets.dart';
import 'noAppointmentWidget.dart';

class LabAppointmentList extends StatefulWidget {
  final int tabindex;
  const LabAppointmentList({Key? key, required this.tabindex})
      : super(key: key);

  @override
  LabAppointmentListState createState() => LabAppointmentListState();
}

class LabAppointmentListState extends State<LabAppointmentList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  List<Appointment> loadedlist = [];
  int loadedpage = 1, loadedoffset = 0;
  final scrollController = ScrollController();
  Map<String, String> apiparams = {};

  @override
  void initState() {
    super.initState();
    apiparams = {
      ApiParams.time: widget.tabindex == 0 ? ApiParams.current : ApiParams.past,
      ApiParams.type: Constant.appointmentLab
    };
    setupScrollController(context);
    print(
        "loadlabstate--${BlocProvider.of<LabAppointmentCubit>(context).state}");

    //if (BlocProvider.of<LabAppointmentCubit>(context).state is! LabAppointmentLoaded) {
    if (context.read<LabAppointmentCubit>().state is LabAppointmentInitial ||
        context.read<LabAppointmentCubit>().state is LabAppointmentFailure) {
      print("loadstate==lab");
      loadPage(isSetInitial: true);
    }
  }

  loadPage({bool isSetInitial = false}) {
    BlocProvider.of<LabAppointmentCubit>(context)
        .loadPosts(context, apiparams, isSetInitial: isSetInitial);
    print("currpage=${BlocProvider.of<LabAppointmentCubit>(context).page}");
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
    return BlocBuilder<LabAppointmentCubit, LabAppointmentState>(
      builder: (context, state) {
        print("state=>${widget.tabindex}===$state");
        if (state is LabAppointmentLoading && state.isFirstFetch) {
          return GeneralWidgets.loadingIndicator();
        } else if (state is LabAppointmentFailure) {
          return NoAppointmentWidget(
              apiparams: apiparams,
              labAppointmentCubit:
                  BlocProvider.of<LabAppointmentCubit>(context));
          /*return GeneralWidgets.msgWithTryAgain(
              state.errorMessage, () => loadPage(isSetInitial: true));*/
        }
        return listContent(state);
      },
    );
  }

  Future<void> refreshList() async {
    loadPage(isSetInitial: true);
  }

  listContent(LabAppointmentState state) {
    List<Appointment> posts = [];
    bool isLoading = false;
    int currpage = 1, offset = 0;
    if (state is LabAppointmentLoading) {
      posts = state.oldLabList;
      isLoading = true;
      currpage = state.currPage;
      offset = state.currOffset;
    } else if (state is LabAppointmentLoaded) {
      posts = state.labList;
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
        physics: AlwaysScrollableScrollPhysics(),
        controller: scrollController,
        padding: EdgeInsets.symmetric(horizontal: 2),
        itemBuilder: (context, index) {
          if (index < posts.length)
            return labWidget(posts[index], index);
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

  labWidget(Appointment post, int index) {
    return GeneralWidgets.cardBoxWidget(
        celevation: 1,
        cmargin: EdgeInsetsDirectional.zero,
        cpadding:
            const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 12),
        childWidget: Column(
          children: [
            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  GeneralWidgets.circularImage(post.lab!.image,
                      height: 60, width: 60),
                  const SizedBox(width: 15),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                        Text(
                          post.lab!.name!,
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
                            Icons.medication,
                            post.testlist!
                                .map((city) => city.test)
                                .toList()
                                .join(",")),
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

  reviewUpdate(int index, Appointment post) {
    loadedlist.removeAt(index);
    loadedlist.insert(index, post);
    print("res->===========***");
    context
        .read<LabAppointmentCubit>()
        .setOldList(loadedoffset, loadedpage, loadedlist);
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
}
