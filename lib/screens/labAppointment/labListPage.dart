import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tabebi/cubits/lab/labCubit.dart';
import 'package:tabebi/helper/generaWidgets.dart';
import 'package:tabebi/helper/generalMethods.dart';
import 'package:tabebi/models/labTest.dart';
import '../../app/routes.dart';
import '../../helper/colors.dart';
import '../../helper/constant.dart';
import '../../helper/stringLables.dart';
import '../../models/lab.dart';

Map<int, LabTest> selectedTestIds = {};

class LabListPage extends StatefulWidget {
  const LabListPage({Key? key}) : super(key: key);

  @override
  LabListPageState createState() => LabListPageState();
}

class LabListPageState extends State<LabListPage> {
  List<LabTest> loadedlist = [];
  int loadedpage = 1;
  final scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    selectedTestIds = {};
    setupScrollController(context);
    if (BlocProvider.of<LabCubit>(context).state is! LabLoaded) {
      print("loadstate");
      loadPage();
    }
  }

  loadPage({bool isSetInitial = false}) {
    BlocProvider.of<LabCubit>(context)
        .loadPosts(context, {}, isSetInitial: isSetInitial);
    print("currpage=${BlocProvider.of<LabCubit>(context).page}");
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
      appBar: GeneralWidgets.citySelectionAppbarWidget(
          context, getLables(lblBookLabTest),
          callback: loadPage),
      body:
          Column(children: [searchWidget(), Expanded(child: contentWidget())]),
    );
  }

  contentWidget() {
    return BlocBuilder<LabCubit, LabState>(
      builder: (context, state) {
        if (state is LabLoading && state.isFirstFetch) {
          return GeneralWidgets.loadingIndicator();
        } else if (state is LabFailure) {
          return GeneralWidgets.msgWithTryAgain(
              state.errorMessage, () => loadPage(isSetInitial: true));
        }
        return listContent(state);
      },
    );
  }

  listContent(LabState state) {
    List<Lab> posts = [];
    bool isLoading = false;
    //int currpage = 1;
    if (state is LabLoading) {
      posts = state.oldLabList;
      isLoading = true;
      // currpage = state.currPage;
    } else if (state is LabLoaded) {
      posts = state.labList;
      // currpage = state.currPage;
    }

    /*if (edtSearch.text.trim().isEmpty && posts.isNotEmpty) {
      loadedpage = currpage;
      loadedlist = [];
      loadedlist = posts;
    }*/

    return ListView.separated(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 8),
      itemBuilder: (context, index) {
        if (index < posts.length)
          return labWidget(posts[index], context);
        else {
          Timer(Duration(milliseconds: 30), () {
            scrollController.jumpTo(scrollController.position.maxScrollExtent);
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
    );
  }

  labWidget(Lab post, BuildContext context) {
    return GestureDetector(
        onTap: () {
          GeneralMethods.goToNextPage(Routes.labDetailPage, context, false,
              args: {
                "lab": post,
                "labId": post.id.toString(),
                "fromSelectTest": false
              });
        },
        child: Stack(children: [
          GeneralWidgets.cardBoxWidget(
              celevation: 10,
              shadowcolor: lightGrey,
              cpadding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 12, vertical: 12),
              childWidget: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        GeneralWidgets.circularImage(post.image,
                            height: 60, width: 60),
                        const SizedBox(width: 15),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                              Text(
                                post.name!,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .merge(TextStyle(
                                        fontWeight: FontWeight.normal)),
                              ),
                              const SizedBox(height: 5),
                              if (post.schedulelist!.isNotEmpty)
                                labInfoWidget(Icons.schedule,
                                    "${DateFormat.jm(Constant.session!.getCurrLangCode()).format(Constant.timeParserSecond.parse(post.schedulelist!.first.startTime!))} - ${DateFormat.jm(Constant.session!.getCurrLangCode()).format(Constant.timeParserSecond.parse(post.schedulelist!.last.endTime!))}"),
                              if (post.labTestlist != null &&
                                  post.labTestlist!.isNotEmpty)
                                labInfoWidget(Icons.schema_outlined,
                                    " ${getLables(lblAvailableTests)}: ${post.labTestlist!.length}",
                                    customIconsize: 15),
                              /*  const SizedBox(height: 2),
                              labInfoWidget(Icons.schema,
                                  "${getLables(lblAvailableBranches)}: ${post.totalBranches!}"), */
                            ]))
                      ],
                    ),
                    if (post.labTestlist!.isNotEmpty) const SizedBox(height: 5),
                    if (post.labTestlist!.isNotEmpty)
                      GeneralWidgets.btnWidget(
                          context, getLables(lblSelectTest),
                          bwidth: 100, bheight: 40, callback: () {
                        GeneralMethods.goToNextPage(
                            Routes.labDetailPage, context, false, args: {
                          "lab": post,
                          "labId": post.id.toString(),
                          "fromSelectTest": true
                        });
                      },
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .merge(TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3))),
                  ])),
          if (post.offer! > 0)
            GeneralWidgets.offerWidget(
                context,
                post.offer!
                    .toString()
                    .replaceAll(GeneralWidgets.doubleFormatRegex, ''),
                omargin: EdgeInsetsDirectional.all(4.0)),
          /*Align(
            alignment: AlignmentDirectional.topEnd,
            child: Container(
              child: Text(
                "${post.offer!}%\n${getLables(lblOff)}",
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .apply(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              alignment: AlignmentDirectional.center,
              width: 55,
              height: 45,
              padding: EdgeInsetsDirectional.only(start: 8),
              margin: EdgeInsets.all(4.0),
              decoration: DesignConfig.boxSpecificSide(primaryColor,
                  bottomStart: 50, topEnd: 8),
            ),
          )*/
        ]));
  }

  labInfoWidget(IconData icon, String info, {double? customIconsize = 18}) {
    return Row(mainAxisSize: MainAxisSize.max, children: [
      Icon(
        icon,
        color: primaryColor,
        size: customIconsize,
      ),
      const SizedBox(width: 8),
      Expanded(
          child: Text(
        info,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall,
      )),
    ]);
  }

  searchWidget() {
    return GeneralWidgets.searchWidget(
        TextEditingController(), context, getLables(labscreenSearchLbl),
        cardmargin: EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 8),
        iconPadding: EdgeInsets.only(top: 5),
        verticalpadding: 5,
        focusnode: AlwaysDisabledFocusNode(), tapCallback: () {
      selectedTestIds = {};
      GeneralMethods.goToNextPage(Routes.labTestListPage, context, false,
          args: {
            "labCubit": BlocProvider.of<LabCubit>(context),
            "labid": "0",
          });
    });
  }
}
