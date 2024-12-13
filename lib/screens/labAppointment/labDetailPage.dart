import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tabebi/cubits/lab/labCubit.dart';
import 'package:tabebi/helper/stringLables.dart';
import 'package:tabebi/models/lab.dart';
import 'package:tabebi/models/labTest.dart';
import 'package:tabebi/screens/labAppointment/labListPage.dart';
import '../../app/routes.dart';
import '../../cubits/doctor/favouriteDoctorCubit.dart';
import '../../cubits/doctor/reviewCubit.dart';
import '../../helper/api.dart';
import '../../helper/apiParams.dart';
import '../../helper/colors.dart';
import '../../helper/constant.dart';
import '../../helper/designConfig.dart';
import '../../helper/generaWidgets.dart';
import '../../helper/generalMethods.dart';
import '../../helper/sessionManager.dart';
import '../../models/review.dart';

class LabDetailPage extends StatefulWidget {
  final Lab? lab;
  final String? labId;
  final bool? fromSelectTest;
  final FavDoctorCubit? favcubit;
  final int? favIndex;
  const LabDetailPage(
      {Key? key,
      required this.lab,
      required this.labId,
      required this.fromSelectTest,
      this.favcubit,
      this.favIndex})
      : super(key: key);

  @override
  LabDetailPageState createState() => LabDetailPageState();
}

class LabDetailPageState extends State<LabDetailPage> {
  Lab? labInfo;
  String selectedsection = "0";
  bool isGettingDetail = false;
  //
  var keyProfile = GlobalKey();
  var keytest = GlobalKey();
  var keyAbout = GlobalKey();
  var keyReview = GlobalKey();
  ScrollController scrollController = ScrollController();
  double totaltestamt = 0, totaltestofferamt = 0;
  StreamController<bool> favStreamController =
      StreamController<bool>.broadcast();
  Map favdridlist = {};
  @override
  void initState() {
    super.initState();
    selectedTestIds = {};
    labInfo = widget.lab;
    setInfo();
  }

  @override
  void dispose() {
    favStreamController.close();
    super.dispose();
  }

  setInfo() {
    if (widget.lab == null) {
      getLabInfoById();
    } else {
      getReview();
      updateLabCounter();
    }
    if (widget.fromSelectTest!)
      Future.delayed(Duration.zero, () {
        selectTest();
      });
  }

  updateLabCounter() async {
    List<String> labidlist =
        Constant.session!.getStringListData(SessionManager.countedLabIds);
    if (!labidlist.contains(widget.labId)) {
      await Api.sendApiRequest(
          ApiParams.apiUpdateCounter,
          {
            ApiParams.doctorId: widget.labId,
            ApiParams.type: Constant.appointmentLab
          },
          true,
          context);
      labidlist.add(widget.labId!);
      Constant.session!
          .setStringListData(SessionManager.countedLabIds, labidlist);
    }
  }

  selectTest() async {
    /*await GeneralMethods.goToNextPage(Routes.labTestListPage, context, false,
        args: {"labid": labInfo!.id!.toString()}).then((value) {
      print("returnValue->value->$value");
    });*/

    await Navigator.of(context).pushNamed(Routes.labTestListPage, arguments: {
      "labid": labInfo!.id!.toString(),
      "labTestList": labInfo!.labTestlist!,
    }).then((value) {
      setState(() {});
    });
  }

  getReview() {
    //
    if (widget.fromSelectTest! &&
        selectedTestIds.isNotEmpty &&
        labInfo != null) {
      selectedTestIds.forEach((key, value) {
        selectedTestIds[key] = labInfo!.labTestlist!
            .where((element) => element.testId == key)
            .first;
      });
    }
    //
    BlocProvider.of<ReviewCubit>(context).loadPosts(context, {
      ApiParams.id: labInfo!.id!.toString(),
      ApiParams.type: Constant.appointmentLab,
    });
  }

  getLabInfoById() {
    setState(() {
      isGettingDetail = true;
    });
    Map<String, String?> parameter = {ApiParams.id: widget.labId};
    context.read<LabCubit>().fetchLabs(parameter, context).then((newPosts) {
      if (newPosts["list"].isNotEmpty) {
        labInfo = newPosts["list"].first;
        getReview();
      }
      setState(() {
        isGettingDetail = false;
      });
    }).catchError((e) {
      GeneralMethods.showSnackBarMsg(context, e.toString());
      Future.delayed(Duration(seconds: 1), () {
        Navigator.of(context).pop();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralWidgets.setAppbar(getLables(lblBookLabTest), context,
          elevation: 0, actions: appbarMenus()),
      body: isGettingDetail
          ? Center(child: CircularProgressIndicator())
          : Column(children: [profileTabs(), Expanded(child: contentWidget())]),
    );
  }

  profileTabs() {
    return labInfo == null
        ? SizedBox.shrink()
        : Container(
            height: 55,
            color: appbarColor,
            padding: EdgeInsets.only(top: 5, bottom: 10),
            child: ListView(scrollDirection: Axis.horizontal, children: [
              const SizedBox(width: 12),
              tabWidget("0", getLables(lblProfileDetails), keyProfile),
              const SizedBox(width: 12),
              tabWidget("1", getLables(lblSelectTest), keytest),
              const SizedBox(width: 12),
              tabWidget("2", getLables(lblReviews), keyReview),
              const SizedBox(width: 12),
            ]),
          );
  }

  tabWidget(String type, String title, GlobalKey tabkey) {
    return GeneralWidgets.textButtonWidget(
        selectedsection == type, title, context, () {
      if (selectedsection != type) {
        Scrollable.ensureVisible(
          tabkey.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        setState(() {
          selectedsection = type;
        });
      }
    }, tpadding: EdgeInsets.symmetric(horizontal: 15, vertical: 0));
  }

  selectTimeSlot() {
    labInfo!.totalTestAmt = totaltestamt;
    labInfo!.totalTestOfferAmt = totaltestofferamt;
    GeneralMethods.goToNextPage(Routes.selectLabtimeslot, context, false,
        args: labInfo);
  }

  appbarMenus() {
    if (isGettingDetail) {
      return null;
    }
    bool favinitialval = labInfo!.isFavourite!;
    String favVal = Constant.session!.getData(SessionManager.labFavIds);
    if (Constant.session!.isUserLoggedIn() && favVal.trim().isNotEmpty) {
      favdridlist = json.decode(favVal);
      print("favdridlist=$favdridlist");
      if (favdridlist.containsKey(labInfo!.id.toString())) {
        favinitialval = favdridlist[widget.labId];
      }
    }
    return [
      IconButton(
          onPressed: () async {
            await Share.share(
              "${getLables(appName)}\n${Constant.deeplinkLabUrl}${labInfo!.id}",
              subject: getLables(appName),
            );
          },
          icon: Icon(
            Icons.share,
            color: primaryColor,
          )),
      StreamBuilder<bool>(
          initialData: favinitialval,
          stream: favStreamController.stream,
          builder: (context, snapshot) {
            return IconButton(
                onPressed: () {
                  favUnfav(snapshot.data! ? "0" : "1");
                },
                icon: Icon(
                  snapshot.data! ? Icons.favorite : Icons.favorite_outline,
                  color: primaryColor,
                ));
          }),
    ];
  }

  favUnfav(String newfavval) {
    if (Constant.session!.isUserLoggedIn()) {
      context
          .read<LabCubit>()
          .favUnfavDoctor(labInfo!.id!.toString(), newfavval, context)
          .then((newPosts) {
        print("favdrid=newPosts=**${newPosts == null}");
        labInfo!.isFavourite = newfavval == "1";
        favdridlist[labInfo!.id.toString()] = newfavval == "1";
        print("favdridlist=**$favdridlist");
        Constant.session!
            .setData(SessionManager.labFavIds, json.encode(favdridlist));
        favStreamController.sink.add(newfavval == "1");
        if (widget.favcubit != null) {
          widget.favcubit!.setFavUnFavItem(
              favouriteData: newPosts, removeindex: widget.favIndex);
        }
      }).catchError((e) {
        print("err->${e.toString()}");
        GeneralMethods.showSnackBarMsg(context, e.toString());
      });
    } else {
      GeneralMethods.openLoginScreen();
    }
  }

  contentWidget() {
    return labInfo == null
        ? SizedBox.shrink()
        : ListView(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            children: [
                labInfoWidget(),
                aboutWidget(),
                const SizedBox(height: 12),
                if (labInfo!.labTestlist!.isNotEmpty) testListWidget(),
                if (labInfo!.labTestlist!.isNotEmpty)
                  const SizedBox(height: 12),
                if (labInfo!.labTestlist!.isNotEmpty) btnBookAppointment(),
                const SizedBox(height: 12),
                reviewBlocWidget(),
              ]);
  }

  btnBookAppointment() {
    return GeneralWidgets.btnWidget(context, getLables(lblBookAppointment),
        bheight: 50, callback: () {
      if (selectedTestIds.isEmpty) {
        GeneralMethods.showSnackBarMsg(context, getLables(lblSelectTest));
        return;
      }
      selectTimeSlot();
    });
  }

  headerWidget(String header, {Function? viewallfun, Widget? headerwidget}) {
    return Row(
      children: [
        // const SizedBox(width: 5),
        Expanded(
          child: headerwidget != null
              ? headerwidget
              : Text(
                  header,
                  style: Theme.of(context).textTheme.titleMedium!.merge(
                      TextStyle(
                          fontWeight: FontWeight.w500, letterSpacing: 0.5)),
                ),
        ),
        if (viewallfun != null)
          TextButton(
              onPressed: () {
                viewallfun();
              },
              child: Text(getLables(lblViewAll),
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium!
                      .apply(color: grey)))
      ],
    );
  }

  labInfoWidget() {
    return GeneralWidgets.cardBoxWidget(
      ckey: keyProfile,
      cmargin: EdgeInsetsDirectional.symmetric(horizontal: 0, vertical: 8),
      childWidget: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: labProfileWidget()),
        Divider(
          color: lightGrey.withOpacity(0.5),
          height: 30,
          thickness: 2,
        ),
        feesWaitingTimeWidget(),
      ]),
    );
  }

  labProfileWidget() {
    return Row(children: [
      GeneralWidgets.circularImage(labInfo!.image, height: 60, width: 60),
      const SizedBox(width: 15),
      Expanded(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                labInfo!.name!,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .merge(TextStyle(fontWeight: FontWeight.normal)),
              ),
              const SizedBox(height: 5),
              RichText(
                text: TextSpan(
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: textColor),
                  children: [
                    WidgetSpan(
                      child: Icon(
                        Icons.location_on,
                        color: primaryColor,
                        size: 18,
                      ),
                    ),
                    TextSpan(
                      text: "  ${labInfo!.labAddress!}",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              GeneralWidgets.rateReviewCountWidget(
                  context, labInfo!.totalrate!, labInfo!.totalReviews!),
              const SizedBox(height: 3),
              Text(
                "${getLables(lbloverallrating)} ${labInfo!.totalVisitor!} ${getLables(lblVisitors)}",
                style: Theme.of(context).textTheme.titleSmall!.merge(TextStyle(
                    fontWeight: FontWeight.normal, color: primaryColor)),
              ),
            ]),
      )
    ]);
  }

  commonFeesWaitingTimeWidget(String title, String desc, String image) {
    return GeneralWidgets.cardBoxWidget(
        cpadding: EdgeInsetsDirectional.symmetric(vertical: 10),
        celevation: 0,
        cmargin: EdgeInsetsDirectional.zero,
        cardcolor: primaryColor.withOpacity(0.1),
        cshape: DesignConfig.setRoundedBorder(8, false),
        childWidget: Row(children: [
          const SizedBox(width: 10),
          GeneralWidgets.setSvg(image, width: 22),
          const SizedBox(width: 12),
          RichText(
              text: TextSpan(
                  text: "$title\n",
                  style: TextStyle(color: primaryColor),
                  children: [
                TextSpan(
                  text: "$desc",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .merge(TextStyle(color: grey, height: 1.5)),
                ),
              ])),
        ]));
    /* return GeneralWidgets.setListtileMenu(title, context,
        desc: desc,
        lcontentPadding: EdgeInsetsDirectional.only(start: 10),
        tilecolor: primaryColor.withOpacity(0.1),
        icontitlegap: 5,
        shapeBorder: DesignConfig.setRoundedBorder(8, false),
        textStyle: TextStyle(color: primaryColor),
        subtextstyle: Theme.of(context)
            .textTheme
            .bodySmall!
            .merge(TextStyle(color: grey, height: 1)),
        leadingwidget: GeneralWidgets.setSvg(image)); */
  }

  feesWaitingTimeWidget() {
    int waitingtime = 0;
    labInfo!.schedulelist!.forEach((element) {
      if (waitingtime < (element.waitingTime ?? 0)) {
        waitingtime = element.waitingTime ?? 0;
      }
    });
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(children: [
        Expanded(
            child: commonFeesWaitingTimeWidget(
                "${GeneralMethods.calcExperence(labInfo!.totalExperience!)}",
                getLables(lblexperience),
                "experience")),
        const SizedBox(width: 15),
        Expanded(
            child: labInfo!.schedulelist!.isEmpty
                ? SizedBox.shrink()
                : commonFeesWaitingTimeWidget(
                    "$waitingtime ${getLables(lblMinutes)}",
                    getLables(lblWaitingTime),
                    "timer")),
      ]),
    );
  }

  testListWidget() {
    return GeneralWidgets.cardBoxWidget(
        ckey: keytest,
        cpadding:
            EdgeInsetsDirectional.only(end: 10, start: 15, top: 10, bottom: 10),
        cmargin: EdgeInsetsDirectional.symmetric(horizontal: 0, vertical: 8),
        childWidget: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              headerWidget(getLables(lblSelectTest)),
              const SizedBox(height: 8),
              if (selectedTestIds.isNotEmpty)
                Wrap(
                    children: List.generate(selectedTestIds.length, (index) {
                  if (index == 0) {
                    totaltestamt = 0;
                    totaltestofferamt = 0;
                  }
                  LabTest labTest =
                      selectedTestIds[selectedTestIds.keys.elementAt(index)]!;

                  totaltestamt = totaltestamt + labTest.labAmount!;
                  totaltestofferamt = totaltestofferamt + labTest.offerprice!;
                  return labTestWidget(labTest);
                }))
              else
                Wrap(
                    children: List.generate(
                        labInfo!.labTestlist!.length > 10
                            ? 10
                            : labInfo!.labTestlist!.length, (index) {
                  LabTest labTest = labInfo!.labTestlist![index];

                  return labTestWidget(labTest);
                })),
              GeneralWidgets.btnWidget(context, getLables(lblSelectTest),
                  callback: () async {
                selectTest();
              }),
            ]));
  }

  labTestWidget(LabTest labtest) {
    return GeneralWidgets.cardBoxWidget(
      celevation: 0,
      cradius: 5,
      cmargin: EdgeInsetsDirectional.zero,
      childWidget: GeneralWidgets.setListtileMenu(
        labtest.test!,
        context,
        trailingwidget: Icon(
          selectedTestIds.containsKey(labtest.id)
              ? Icons.check_circle
              : Icons.radio_button_off,
          color: selectedTestIds.containsKey(labtest.id) ? primaryColor : grey,
        ),
        discwidget: RichText(
            text: TextSpan(
                text: "${labtest.labAmount} ${Constant.currencyCode}\t\t\t",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .apply(color: primaryColor),
                children: [
              if (labtest.offerprice! > 0)
                TextSpan(
                  text: "${labtest.offerprice} ${Constant.currencyCode}",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: grey,
                      fontWeight: FontWeight.w500,
                      decorationStyle: TextDecorationStyle.solid,
                      decoration: TextDecoration.lineThrough),
                ),
            ])),
        isdence: false,
        textStyle: Theme.of(context).textTheme.titleMedium!,
        onClickAction: () {
          selectTest();
        },
      ),
    );
  }

  aboutWidget() {
    return GeneralWidgets.cardBoxWidget(
        ckey: keyAbout,
        cpadding:
            EdgeInsetsDirectional.only(end: 10, start: 15, top: 10, bottom: 10),
        cmargin: EdgeInsetsDirectional.symmetric(horizontal: 0, vertical: 8),
        childWidget: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              headerWidget(getLables(lblAbout)),
              const SizedBox(height: 8),
              GeneralWidgets.aboutTextWidget(labInfo!.labInfo!.trim(), context),
            ]));
  }

  reviewBlocWidget() {
    return BlocBuilder<ReviewCubit, ReviewState>(builder: (context, state) {
      if (state is ReviewSuccess) {
        return reviewWidget(state, state.reviewList, state.total);
      } else {
        return SizedBox.shrink();
      }
    });
  }

  reviewWidget(ReviewState state, List<Review> reviewlist, int total) {
    return GeneralWidgets.cardBoxWidget(
        ckey: keyReview,
        cpadding:
            EdgeInsetsDirectional.only(end: 10, start: 15, top: 10, bottom: 10),
        cmargin: EdgeInsetsDirectional.symmetric(horizontal: 0, vertical: 5),
        childWidget: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              reviewHeader(),
              const SizedBox(height: 8),
              SizedBox(
                  height: 100,
                  child: ListView.separated(
                    itemCount: reviewlist.length,
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (context, index) {
                      return SizedBox(width: 10);
                    },
                    itemBuilder: (context, index) {
                      Review review = reviewlist[index];
                      return GeneralWidgets.reviewListItemWidget(
                          review, 2, TextOverflow.ellipsis, context,
                          reviewDetailDialog: reviewDetailDialog);
                    },
                  ))
            ]));
  }

  reviewDetailDialog(Review review) {
    GeneralWidgets.showAlertDialogue(context, Text(getLables(lblReviews)),
        GeneralWidgets.reviewListItemWidget(review, null, null, context), [],
        cpadding: EdgeInsets.all(0));
  }

  reviewHeader() {
    return Row(children: [
      Text(
        getLables(lblReviews),
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .merge(TextStyle(fontWeight: FontWeight.w500, letterSpacing: 0.5)),
      ),
      const SizedBox(width: 10),
      GeneralWidgets.setSvg("rating", width: 15),
      const SizedBox(width: 8),
      Text(labInfo!.totalrate!),
      const SizedBox(width: 8),
      Text(
        "(${labInfo!.totalReviews!})",
        style: TextStyle(color: grey),
      ),
      Spacer(),
      TextButton(
          onPressed: () {
            GeneralMethods.goToNextPage(Routes.reviewlist, context, false,
                args: {
                  "mainparameter": {
                    ApiParams.labId: labInfo!.id!.toString(),
                    ApiParams.id: labInfo!.id!.toString(),
                    ApiParams.type: Constant.appointmentLab,
                  },
                  "reviewCubit": BlocProvider.of<ReviewCubit>(context)
                });
          },
          child: Text(getLables(lblViewAll),
              style:
                  Theme.of(context).textTheme.labelMedium!.apply(color: grey)))
    ]);
  }
}
