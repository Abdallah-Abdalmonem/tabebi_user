import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tabebi/app/routes.dart';
import 'package:tabebi/cubits/doctor/doctorCubit.dart';
import 'package:tabebi/cubits/doctor/favouriteDoctorCubit.dart';
import 'package:tabebi/helper/api.dart';
import 'package:tabebi/helper/apiParams.dart';
import 'package:tabebi/helper/colors.dart';
import 'package:tabebi/helper/generaWidgets.dart';
import 'package:tabebi/helper/generalMethods.dart';
import 'package:tabebi/models/doctor.dart';

import '../../cubits/doctor/reviewCubit.dart';
import '../../helper/constant.dart';
import '../../helper/designConfig.dart';
import '../../helper/sessionManager.dart';
import '../../helper/stringLables.dart';
import '../../models/review.dart';

class DoctorDetailPage extends StatefulWidget {
  final Doctor? doctor;
  final String? drId;
  final FavDoctorCubit? favcubit;
  final int? favIndex;
  const DoctorDetailPage(
      {Key? key,
      required this.doctor,
      required this.drId,
      this.favcubit,
      this.favIndex})
      : super(key: key);

  @override
  _DoctorDetailPageState createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  Doctor? doctorInfo;
  String selectedsection = "0";
  bool isGettingDetail = false;
  //
  var keyProfile = GlobalKey();
  var keyAvailability = GlobalKey();
  var keySubSpec = GlobalKey();
  var keyReview = GlobalKey();
  ScrollController scrollController = ScrollController();
  StreamController<bool> favStreamController =
      StreamController<bool>.broadcast();
  Map favdridlist = {};
  @override
  void initState() {
    super.initState();
    doctorInfo = widget.doctor;
    print("nullcheck->${widget.doctor == null}===${doctorInfo == null}");
    if (widget.doctor == null) {
      getDoctorInfoById();
    } else {
      getReview();
      updateDrCounter();
    }
  }

  @override
  void dispose() {
    favStreamController.close();
    super.dispose();
  }

  updateDrCounter() async {
    List<String> dridlist =
        Constant.session!.getStringListData(SessionManager.countedDrIds);
    if (!dridlist.contains(widget.drId)) {
      await Api.sendApiRequest(
          ApiParams.apiUpdateCounter,
          {
            ApiParams.doctorId: widget.drId,
            ApiParams.type: Constant.appointmentDoctor
          },
          true,
          context);
      dridlist.add(widget.drId!);
      Constant.session!
          .setStringListData(SessionManager.countedDrIds, dridlist);
    }
  }

  getReview() {
    BlocProvider.of<ReviewCubit>(context).loadPosts(context, {
      ApiParams.id: doctorInfo!.id!.toString(),
      ApiParams.doctorId: doctorInfo!.id!.toString(),
      ApiParams.type: Constant.appointmentDoctor,
    });
  }

  getDoctorInfoById() {
    setState(() {
      isGettingDetail = true;
    });
    Map<String, String?> parameter = {ApiParams.id: widget.drId};

    context
        .read<DoctorCubit>()
        .fetchDoctors(parameter, context)
        .then((newPosts) {
      if (newPosts["list"].isNotEmpty) {
        doctorInfo = newPosts["list"].first;
        getReview();
      }
      setState(() {
        isGettingDetail = false;
      });
    }).catchError((e) {
      /* setState(() {
        isGettingDetail = false;
      }); */
      GeneralMethods.showSnackBarMsg(context, e.toString());
      Future.delayed(Duration(seconds: 1), () {
        Navigator.of(context).pop();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralWidgets.setAppbar(getLables(lblDoctorProfile), context,
          elevation: 0, actions: appbarMenus()),
      body: isGettingDetail
          ? Center(child: CircularProgressIndicator())
          : Column(children: [profileTabs(), Expanded(child: contentWidget())]),
    );
  }

  selectTimeSlot() {
    GeneralMethods.goToNextPage(Routes.selectDrtimeslot, context, false,
        args: doctorInfo);
  }

  profileTabs() {
    return doctorInfo == null
        ? SizedBox.shrink()
        : Container(
            height: 55,
            color: appbarColor,
            padding: EdgeInsets.only(top: 5, bottom: 10),
            child: ListView(scrollDirection: Axis.horizontal, children: [
              const SizedBox(width: 12),
              tabWidget("0", getLables(lblProfileDetails), keyProfile),
              const SizedBox(width: 12),
              tabWidget("1", getLables(lblAvailability), keyAvailability),
              if (doctorInfo!.subspecialties!.isNotEmpty)
                const SizedBox(width: 12),
              if (doctorInfo!.subspecialties!.isNotEmpty)
                tabWidget("2", getLables(lblSubspecialties), keySubSpec),
              const SizedBox(width: 12),
              tabWidget("3", getLables(lblReviews), keyReview),
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

  appbarMenus() {
    if (isGettingDetail) {
      return null;
    }
    bool favinitialval = doctorInfo!.isFavourite!;
    String favVal = Constant.session!.getData(SessionManager.drFavIds);
    if (Constant.session!.isUserLoggedIn() && favVal.trim().isNotEmpty) {
      favdridlist = json.decode(favVal);
      print("favdridlist=$favdridlist");
      if (favdridlist.containsKey(doctorInfo!.id.toString())) {
        favinitialval = favdridlist[widget.drId];
      }
    }
    return [
      IconButton(
          onPressed: () async {
            await Share.share(
              "${getLables(appName)}\n${Constant.deeplinkDrUrl}${doctorInfo!.id}",
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
          .read<DoctorCubit>()
          .favUnfavDoctor(doctorInfo!.id!.toString(), newfavval, context)
          .then((newPosts) {
        print("favdrid=newPosts=**${newPosts == null}");
        doctorInfo!.isFavourite = newfavval == "1";
        favdridlist[doctorInfo!.id.toString()] = newfavval == "1";
        print("favdridlist=**$favdridlist");
        Constant.session!
            .setData(SessionManager.drFavIds, json.encode(favdridlist));
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
    return doctorInfo == null
        ? SizedBox.shrink()
        : ListView(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            children: [
                drInfoWidget(),
                appointmentWidget(),
                const SizedBox(height: 12),
                btnBookAppointment(),
                const SizedBox(height: 12),
                aboutWidget(),
                const SizedBox(height: 12),
                reviewBlocWidget(),
                // SizedBox(height: MediaQuery.of(context).size.height / 3),
              ]);
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
              reviewHeader(total),
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

  reviewBlocWidget() {
    return BlocBuilder<ReviewCubit, ReviewState>(builder: (context, state) {
      if (state is ReviewFailure) {
        print("len->${state.errorMessage}");
      }
      if (state is ReviewSuccess) {
        return reviewWidget(state, state.reviewList, state.total);
      } else {
        return SizedBox.shrink();
      }
    });
  }

  reviewHeader(int total) {
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
      Text(doctorInfo!.rates!),
      const SizedBox(width: 8),
      Text(
        "(${doctorInfo!.totalReviews!})",
        style: TextStyle(color: grey),
      ),
      Spacer(),
      if (total > Constant.fetchLimit)
        TextButton(
            onPressed: () {
              GeneralMethods.goToNextPage(Routes.reviewlist, context, false,
                  args: {
                    "mainparameter": {
                      ApiParams.doctorId: doctorInfo!.id!.toString(),
                      ApiParams.id: doctorInfo!.id!.toString(),
                      ApiParams.type: Constant.appointmentDoctor,
                    },
                    "reviewCubit": BlocProvider.of<ReviewCubit>(context)
                  });
            },
            child: Text(getLables(lblViewAll),
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .apply(color: grey)))
    ]);
  }

  aboutWidget() {
    return GeneralWidgets.cardBoxWidget(
        ckey: keySubSpec,
        cpadding:
            EdgeInsetsDirectional.only(end: 10, start: 15, top: 10, bottom: 10),
        cmargin: EdgeInsetsDirectional.symmetric(horizontal: 0, vertical: 8),
        childWidget: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              headerWidget(getLables(lblAbout)),
              const SizedBox(height: 8),
              GeneralWidgets.aboutTextWidget(
                  Constant.session!.getCurrLangCode() ==
                          Constant.arabicLanguageCode
                      ? doctorInfo!.drInfoAr!
                      : doctorInfo!.drInfoEng!,
                  context),
              const SizedBox(height: 10),
              Row(children: [
                blurBoxWidget(
                    GeneralMethods.calcExperence(doctorInfo!.totalExperience!),
                    getLables(lblExperience)),
                const SizedBox(width: 8),
                blurBoxWidget(
                    doctorInfo!.totalAppointments!, getLables(lblAppointments)),
                const SizedBox(width: 8),
                blurBoxWidget(doctorInfo!.rates!, getLables(lblRatings)),
              ]),
              if (doctorInfo!.subspecialties!.isNotEmpty) subSpecialityWidget(),
            ]));
  }

  subSpecialityWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        headerWidget(getLables(lblSubspecialties)),
        const SizedBox(height: 5),
        Wrap(
            runSpacing: 12,
            spacing: 10,
            runAlignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            alignment: WrapAlignment.start,
            children: List.generate(
                doctorInfo!.subspecialties!.length,
                (index) => GeneralWidgets.cardBoxWidget(
                    celevation: 0,
                    cshape: DesignConfig.setRoundedBorder(
                      8,
                      true,
                      bordercolor: grey.withOpacity(0.1),
                    ),
                    cpadding: EdgeInsetsDirectional.symmetric(
                        horizontal: 8, vertical: 7),
                    cmargin: EdgeInsetsDirectional.zero,
                    childWidget: Text(doctorInfo!.subspecialties![index])))),
      ],
    );
  }

  blurBoxWidget(String title, String subtitle) {
    return Expanded(
      child: Container(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .apply(color: primaryColor),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style:
                      Theme.of(context).textTheme.bodySmall!.apply(color: grey),
                ),
              ]),
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration:
              DesignConfig.boxDecoration(primaryColor.withOpacity(0.1), 5)),
    );
  }

  btnBookAppointment() {
    return GeneralWidgets.btnWidget(context, getLables(lblBookAppointment),
        bheight: 50, callback: () {
      selectTimeSlot();
    });
  }

  appointmentWidget() {
    return GeneralWidgets.cardBoxWidget(
        ckey: keyAvailability,
        cpadding:
            EdgeInsetsDirectional.only(end: 10, start: 15, top: 10, bottom: 10),
        cmargin: EdgeInsetsDirectional.symmetric(horizontal: 0, vertical: 8),
        childWidget: Column(mainAxisSize: MainAxisSize.min, children: [
          headerWidget(getLables(lblBookAppointment), viewallfun: () {
            selectTimeSlot();
          }),
          Row(children: [
            GeneralWidgets.setSvg("fees", width: 17),
            const SizedBox(width: 10),
            Expanded(
                child: Text(
              "${getLables(lblFees)}:  ${doctorInfo!.drFees!} ${Constant.currencyCode}",
              style: Theme.of(context).textTheme.bodySmall,
            )),
          ]),
          const SizedBox(height: 8),
          if (doctorInfo!.schedulelist!.isNotEmpty &&
              doctorInfo!.schedulelist!.first.startTime != null &&
              doctorInfo!.schedulelist!.first.startTime!.trim().isNotEmpty)
            Row(children: [
              Icon(
                Icons.schedule,
                color: avalibilityGreen,
                size: 22,
              ),
              const SizedBox(width: 5),
              Text(
                getLables(lblAvailableToday),
                style: Theme.of(context).textTheme.bodySmall!.merge(
                    TextStyle(color: avalibilityGreen, letterSpacing: 0.5)),
              ),
              Expanded(
                  child: Text(
                "${DateFormat.jm(Constant.session!.getCurrLangCode()).format(Constant.timeParserSecond.parse(doctorInfo!.schedulelist!.first.startTime!))} - ${DateFormat.jm(Constant.session!.getCurrLangCode()).format(Constant.timeParserSecond.parse(doctorInfo!.schedulelist!.last.endTime!))}",
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodySmall,
              )),
              //Icon(Icons.arrow_drop_down)
            ]),
        ]));
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

  drInfoWidget() {
    return GeneralWidgets.cardBoxWidget(
      ckey: keyProfile,
      cmargin: EdgeInsetsDirectional.symmetric(horizontal: 0, vertical: 8),
      childWidget: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: drProfileWidget()),
        Divider(
          color: lightGrey.withOpacity(0.5),
          height: 30,
          thickness: 2,
        ),
        feesWaitingTimeWidget(),
        if (doctorInfo!.hospital != null) hospitalWidget()
      ]),
    );
  }

  hospitalWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Row(children: [
        GeneralWidgets.circularImage(doctorInfo!.hospital!.image,
            height: 50, width: 50),
        const SizedBox(width: 15),
        Expanded(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(
                doctorInfo!.hospital!.name!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 3),
              Text(doctorInfo!.hospital!.address!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .apply(color: grey)),
              const SizedBox(height: 3),
              Text(getLables(getaddressinfo),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .apply(color: primaryColor)),
            ]))
      ]),
    );
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
    /*  return GeneralWidgets.setListtileMenu(title, context,
        desc: desc,
        lcontentPadding: EdgeInsetsDirectional.only(start: 10),
        tilecolor: primaryColor.withOpacity(0.1),
        icontitlegap: 2,
        shapeBorder: DesignConfig.setRoundedBorder(8, false),
        textStyle: TextStyle(color: primaryColor),
        subtextstyle: Theme.of(context)
            .textTheme
            .bodySmall!
            .merge(TextStyle(color: grey, height: 1)),
        leadingwidget: GeneralWidgets.setSvg(image, width: 22)); */
  }

  feesWaitingTimeWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(children: [
        Expanded(
            child: commonFeesWaitingTimeWidget(doctorInfo!.drFees!,
                getLables(lblAppointmentFee), "appointmentFee")),
        const SizedBox(width: 15),
        if (doctorInfo!.schedulelist!.isNotEmpty)
          Expanded(
              child: commonFeesWaitingTimeWidget(
                  "${doctorInfo!.schedulelist!.first.waitingTime ?? ""} ${getLables(lblMinutes)}",
                  getLables(lblWaitingTime),
                  "timer")),
      ]),
    );
  }

  drProfileWidget() {
    String qualification = doctorInfo!.qualification ?? "";
    return Row(children: [
      GeneralWidgets.circularImage(doctorInfo!.image, height: 60, width: 60),
      const SizedBox(width: 15),
      Expanded(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Constant.session!.getCurrLangCode() ==
                        Constant.arabicLanguageCode
                    ? doctorInfo!.nameAr!
                    : doctorInfo!.nameEng!,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .merge(TextStyle(fontWeight: FontWeight.normal)),
              ),
              if (qualification.trim().isNotEmpty) const SizedBox(height: 5),
              if (qualification.trim().isNotEmpty)
                Text(
                  qualification,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .apply(color: grey),
                ),
              const SizedBox(height: 5),
              Text(
                doctorInfo!.speciality!.toString(),
                style:
                    Theme.of(context).textTheme.bodyMedium!.apply(color: grey),
              ),
              /*  Text(
                Constant.session!.getCurrLangCode() ==
                        Constant.arabicLanguageCode
                    ? doctorInfo!.drInfoAr!
                    : doctorInfo!.drInfoEng!,
                style:
                    Theme.of(context).textTheme.bodyMedium!.apply(color: grey),
              ), */
            ]),
      )
    ]);
  }
}
