import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tabebi/cubits/myRecordCubit.dart';
import 'package:tabebi/helper/apiParams.dart';
import 'package:tabebi/helper/generalMethods.dart';
import 'package:tabebi/models/myRecord.dart';
import 'package:tabebi/screens/myRecords/addReportPage.dart';

import '../../app/routes.dart';
import '../../helper/api.dart';
import '../../helper/colors.dart';
import '../../helper/constant.dart';
import '../../helper/designConfig.dart';
import '../../helper/generaWidgets.dart';
import '../../helper/stringLables.dart';
import '../../models/attachement.dart';
import 'noDataWidget.dart';

class MyRecordListPage extends StatefulWidget {
  final int tabindex;
  const MyRecordListPage({Key? key, required this.tabindex}) : super(key: key);

  @override
  MyRecordListPageState createState() => MyRecordListPageState();
}

class MyRecordListPageState extends State<MyRecordListPage>
    with AutomaticKeepAliveClientMixin {
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  bool get wantKeepAlive => true;
  List<MyRecord> loadedlist = [];
  int loadedpage = 1;
  final scrollController = ScrollController();
  bool isMyReportpage = false;
  var _isVisible;
  late final StreamController<bool> btnController;
  @override
  void initState() {
    super.initState();
    btnController = StreamController<bool>();
    _isVisible = true;
    isMyReportpage = widget.tabindex == 0;
    setupScrollController(context);
    print("recordinit====");
    if (BlocProvider.of<MyRecordCubit>(context).state is! MyRecordSuccess) {
      print("loadstate");
      loadPage();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadPage({bool isSetInitial = false}) {
    String url =
        isMyReportpage ? ApiParams.apiReport : ApiParams.apiGetAppointment;
    context.read<MyRecordCubit>().loadPosts(
        url,
        context,
        {
          ApiParams.isAttachment: "1",
          ApiParams.type: Constant.appointmentDoctor,
          ApiParams.apiType: ApiParams.get,
          "from": widget.tabindex.toString()
        },
        isSetInitial: isSetInitial);
    print("currpage=${BlocProvider.of<MyRecordCubit>(context).page}");
  }

  setupScrollController(context) {
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels != 0) {
          loadPage();
        }
      }
      if (isMyReportpage) {
        if (scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          if (_isVisible) {
            _isVisible = false;
            btnController.sink.add(false);
          }
        } else {
          if (scrollController.position.userScrollDirection ==
              ScrollDirection.forward) {
            if (!_isVisible) {
              _isVisible = true;
              btnController.sink.add(true);
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      key: _scaffoldKey,
      body: contentWidget(),
      floatingActionButton: StreamBuilder<bool>(
          stream: btnController.stream,
          initialData: isMyReportpage,
          builder: (context, snapshot) {
            return Visibility(
              visible: isMyReportpage && snapshot.data!,
              child: FloatingActionButton(
                onPressed: () {
                  goToAddReport();
                },
                child: Icon(Icons.add, color: white),
              ),
            );
          }),
    );
  }

  contentWidget() {
    return BlocBuilder<MyRecordCubit, MyRecordState>(
      builder: (context, state) {
        print("recordinit====state=>$state");
        if (state is MyRecordProgress && state.isFirstFetch) {
          return GeneralWidgets.loadingIndicator();
        } else if (state is MyRecordFailure) {
          /*return GeneralWidgets.msgWithTryAgain(
              state.errorMessage, () => loadPage(isSetInitial: true));*/
          return noDataWidget(isMyReportpage, context, goToAddReport, loadPage);
          //return noDataWidget();
        }

        return listContent(state);
      },
    );
  }

/*
  noDataWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GeneralWidgets.setSvg("filesImage"),
          const SizedBox(
            height: 10,
          ),
          Text(
            getLables(
                isMyReportpage ? lblAddReportTitle : lblConsultDoctorTitle),
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .apply(color: primaryColor),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
              getLables(isMyReportpage
                  ? lblAddReportSubTitle
                  : lblConsultDoctorSubTitle),
              textAlign: TextAlign.center,
              style:
                  Theme.of(context).textTheme.titleSmall!.apply(color: grey)),
          const SizedBox(
            height: 20,
          ),
          GeneralWidgets.btnWidget(
            context,
            getLables(isMyReportpage ? lblAddReports : lblConsultDoctor),
            bwidth: MediaQuery.of(context).size.width / 1.5,
            callback: () {
              if (isMyReportpage) {
                goToAddReport();
              } else {
                GeneralMethods.goToNextPage(
                    Routes.specialitylistpage, context, false);
              }
            },
          ),
          if (Constant.session!.isUserLoggedIn())
            TextButton(
                onPressed: () {
                  loadPage(isSetInitial: true);
                },
                child: Text(
                  getLables(lblTryAgain),
                  style: TextStyle(decoration: TextDecoration.underline),
                ))
        ],
      ),
    );
  }

*/
  goToAddReport() {
    GeneralMethods.goToNextPage(Routes.addReportPage, context, false,
        args: context.read<MyRecordCubit>());
  }

  listContent(MyRecordState state) {
    List<MyRecord> posts = [];
    bool isLoading = false;
    int currpage = 1;
    if (state is MyRecordProgress) {
      posts = state.oldMyRecordList;
      isLoading = true;
      currpage = state.currPage;
    } else if (state is MyRecordSuccess) {
      posts = state.myyRecordList;
      currpage = state.currPage;
    }

    loadedpage = currpage;
    loadedlist = [];
    loadedlist = posts;

    return RefreshIndicator(
      onRefresh: refreshpage,
      child: ListView.separated(
        controller: scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 2),
        itemBuilder: (context, index) {
          if (index < posts.length)
            return recordItemWidget(posts[index], index);
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

  deleteReport(int index, String reportid) {
    GeneralWidgets.showAlertDialogue(context, Text(getLables(lblDelete)),
        Text(getLables(deleteReportWarning)), [
      GeneralWidgets.cancelActionBtn(context, getLables(lblCancel)),
      GeneralWidgets.confirmActionBtn(context, getLables(lblDelete), () async {
        Map<String, String> parameter = {
          ApiParams.isDelete: "1",
          ApiParams.apiType: ApiParams.set,
          ApiParams.reportId: reportid,
        };
        AddReportPageState.updateReportInfo(
            context.read<MyRecordCubit>(), context, parameter, {},
            removeindex: index);
      }),
    ]);
  }

  recordItemWidget(MyRecord post, int index) {
    return GeneralWidgets.cardBoxWidget(
        celevation: 1,
        cmargin: EdgeInsetsDirectional.zero,
        cpadding:
            const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 12),
        childWidget:
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GeneralWidgets.setSvg("filesImage", height: 70, width: 70),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isMyReportpage)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        post.title!,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .merge(TextStyle(fontWeight: FontWeight.normal)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        deleteReport(index, post.id.toString());
                      },
                      child: Icon(
                        Icons.delete,
                        color: grey,
                      ),
                    )
                  ],
                ),
              Text(
                post.patientname!,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .merge(TextStyle(color: primaryColor.withOpacity(0.8))),
              ),
              const SizedBox(height: 3),
              infoWidget(post.drName!, "specialities", null),
              const SizedBox(height: 2),
              infoWidget(
                  DateFormat("dd MMM yy, hh:mm a",
                          Constant.session!.getCurrLangCode())
                      .format(
                          Constant.backendDateParser.parse(post.createdDate!)),
                  "",
                  Icons.schedule),
              const SizedBox(height: 2),
              infoWidget(
                  "${getLables(lblFileAttached)} : ${post.attachmentlist!.length}",
                  "uploadPresc",
                  null),
              if (post.attachmentlist!.isNotEmpty) const SizedBox(height: 3),
              attachmentNStatusWidget(post, index)
              /*if (widget.tabindex == 1 && post.attachmentlist!.isNotEmpty)
                attachmentWidget(post, index),
              if (isMyReportpage &&
                  post.status == Constant.reportApproved)
                attachmentWidget(post, index)
              else if (isMyReportpage)
                GeneralWidgets.statusWidget(
                    Constant.getReportStatus(post.status!), context),
                    */
            ],
          ))
        ]));
  }

  attachmentNStatusWidget(MyRecord post, int index) {
    if ((widget.tabindex == 1 && post.attachmentlist!.isNotEmpty) ||
        (isMyReportpage && post.status == Constant.reportApproved)) {
      return attachmentWidget(post, index);
    } else if (isMyReportpage) {
      return GeneralWidgets.statusWidget(
          Constant.getReportStatus(post.status!), context);
    } else {
      return SizedBox.shrink();
    }
  }

  infoWidget(String value, String svgimage, IconData? icon) {
    return Row(children: [
      svgimage.trim().isNotEmpty
          ? GeneralWidgets.setSvg(svgimage, width: 16)
          : Icon(
              icon!,
              color: primaryColor,
              size: 15,
            ),
      const SizedBox(width: 8),
      Expanded(
          child: Text(
        value,
        style: Theme.of(context).textTheme.bodySmall!,
      ))
    ]);
  }

  openAttachmentlist(MyRecord post, int postindex,
      {bool isview = false}) async {
    if (post.attachmentlist!.isEmpty) {
      return;
    }
    if (!isview) {
      bool checkpermission =
          (await GeneralMethods.storageCheckpermission()) ?? false;
      if (!checkpermission) return;
    }
    //print("list->${post.attachmentlist!.length}");
    GeneralWidgets.showBottomSheet(
        bpadding: EdgeInsetsDirectional.symmetric(
            horizontal: MediaQuery.of(context).size.width * (0.035),
            vertical: MediaQuery.of(context).size.height * (0.02)),
        btmchild: GeneralWidgets.cardBoxWidget(
            cmargin: EdgeInsetsDirectional.zero,
            cpadding: EdgeInsetsDirectional.only(top: 8),
            childWidget: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.symmetric(horizontal: 12),
                    child: Text(
                      post.patientname!,
                      style: Theme.of(context).textTheme.titleSmall!.merge(
                          TextStyle(color: primaryColor.withOpacity(0.8))),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Padding(
                    padding: EdgeInsetsDirectional.symmetric(
                        horizontal: 12, vertical: 3),
                    child: Row(children: [
                      Icon(
                        Icons.schedule,
                        color: primaryColor,
                        size: 15,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(
                        post.createdDate!,
                        style: Theme.of(context).textTheme.bodySmall!,
                      ))
                    ]),
                  ),
                  Divider(
                    thickness: 2,
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.symmetric(horizontal: 12),
                    child: Text(
                      getLables(lblAttachments),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .apply(color: primaryColor),
                    ),
                  ),
                  Wrap(
                      children:
                          List.generate(post.attachmentlist!.length, (index) {
                    String url = post.attachmentlist![index].file!;
                    String filename = url.split("/").last;
                    return GeneralWidgets.setListtileMenu(filename, context,
                        trailingwidget: isview
                            ? null
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                    IconButton(
                                        padding: EdgeInsetsDirectional.zero,
                                        onPressed: () async {
                                          await downloadFile(url, filename);
                                        },
                                        color: primaryColor,
                                        icon: Icon(Icons.download)),
                                    IconButton(
                                        padding: EdgeInsetsDirectional.zero,
                                        onPressed: () async {
                                          await downloadFile(url, filename,
                                              isshare: true);
                                        },
                                        color: primaryColor,
                                        icon: Icon(Icons.share)),
                                  ]),
                        lcontentPadding: EdgeInsetsDirectional.only(start: 10),
                        discwidget: FutureBuilder(
                          future: Api.getFileLength(url,
                              filelength:
                                  post.attachmentlist![index].fileLength),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData) {
                              List<Attachment>? attachmentlist =
                                  post.attachmentlist!;
                              attachmentlist[index].fileLength = snapshot.data!;
                              loadedlist[postindex].attachmentlist =
                                  attachmentlist;
                              return Text(snapshot.data!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .apply(color: grey));
                            } else {
                              return SizedBox.shrink();
                            }
                          },
                        ),
                        textStyle: Theme.of(context).textTheme.bodySmall,
                        onClickAction: () {
                      Navigator.of(context).pop();
                      GeneralMethods.goToNextPage(
                          Routes.docViewerPage, context, false,
                          args: url);
                    });
                  }))
                ])),
        context: context);
  }

  Future downloadFile(String url, String filename,
      {bool isshare = false}) async {
    File file = File(Constant.filePath + "/" + filename);
    if (await file.exists()) {
      if (isshare) {
        Share.shareXFiles([XFile(file.path)], text: getLables(appName))
            .then((value) {
          Navigator.of(context).pop();
        });
      } else {
        Navigator.of(context).pop();
        Future.delayed(Duration(milliseconds: 500), () {
          GeneralMethods.showSnackBarMsg(context, getLables(lblFileDownloaded));
        });
      }
    } else {
      await Api.downloadFile(url, context).then((value) {
        print("dwpath->${value["path"]}");
        print("dwpath->message-${value["message"]}");
        Navigator.of(context).pop();
        if (isshare) {
          Share.shareXFiles([XFile(file.path)], text: getLables(appName))
              .then((value) {
            Navigator.of(context).pop();
          });
        } else {
          Future.delayed(Duration(milliseconds: 500), () {
            GeneralMethods.showSnackBarMsg(context, value["message"]);
          });
        }
      });
    }
  }

  btnWidget(IconData icon, String lbl, BuildContext context,
      {bool isEnable = true, Function? callback}) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 5),
        shape: DesignConfig.setRoundedBorder(5, false),
        side: BorderSide(
            color: isEnable ? primaryColor : primaryColor.withOpacity(0.5)),
      ),
      onPressed: () {
        if (callback != null) callback();
      },
      icon: Icon(
        icon,
        size: 18,
        color: isEnable ? primaryColor : primaryColor.withOpacity(0.5),
      ),
      label: Text(
        getLables(lbl),
        style: Theme.of(context).textTheme.bodySmall!.apply(
            color: isEnable ? primaryColor : primaryColor.withOpacity(0.5)),
      ),
    );
  }

  attachmentWidget(MyRecord post, int index) {
    return Row(
      children: [
        Expanded(
            child: btnWidget(Icons.share, lblShareReport, context,
                isEnable: post.attachmentlist!.isNotEmpty, callback: () {
          openAttachmentlist(post, index);
        })),
        const SizedBox(width: 5),
        Expanded(
            child: btnWidget(Icons.description, lblViewReports, context,
                isEnable: post.attachmentlist!.isNotEmpty, callback: () {
          openAttachmentlist(post, index, isview: true);
        })),
      ],
    );
  }

  Future<void> refreshpage() async {
    loadPage(isSetInitial: true);
  }
}
