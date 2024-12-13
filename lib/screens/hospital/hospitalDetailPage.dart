import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabebi/cubits/hospital/hospitalCubit.dart';
import 'package:tabebi/helper/stringLables.dart';
import 'package:tabebi/models/hospital.dart';
import 'package:tabebi/models/speciality.dart';
import '../../cubits/doctor/doctorCubit.dart';
import '../../helper/apiParams.dart';
import '../../helper/colors.dart';
import '../../helper/constant.dart';
import '../../helper/generaWidgets.dart';
import '../../helper/generalMethods.dart';
import '../doctorAppointment/DoctorList/drListItemWidget.dart';

class HospitalDetailPage extends StatefulWidget {
  final Hospital? hospital;
  final String? hospitalId;
  const HospitalDetailPage(
      {Key? key, required this.hospital, required this.hospitalId})
      : super(key: key);

  @override
  HospitalDetailPageState createState() => HospitalDetailPageState();
}

class HospitalDetailPageState extends State<HospitalDetailPage> {
  Hospital? hospitalInfo;
  bool isGettingDetail = false;
  String selectedsection = "0";
  var keyProfile = GlobalKey();
  var keyAbout = GlobalKey();
  var keySpecializations = GlobalKey();
  var keyDoctors = GlobalKey();
  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    hospitalInfo = widget.hospital;
    setInfo();
  }

  setInfo() async {
    if (widget.hospital == null) {
      await getHospitalInfoById();
    } else if (hospitalInfo!.doctorlist!.isEmpty) {
      getDrList();
    }
  }

  getDrList() {
    Constant.drGetListParams = {};
    Constant.drGetListParams[ApiParams.hospitalId] =
        hospitalInfo!.id.toString();
    BlocProvider.of<DoctorCubit>(context)
        .fetchDoctors(Constant.drGetListParams, context)
        .then((value) {
      hospitalInfo!.doctorlist = value["list"];
      setState(() {});
    }).catchError((e) {});
  }

  getHospitalInfoById() async {
    setState(() {
      isGettingDetail = true;
    });
    Map<String, String?> parameter = {ApiParams.id: widget.hospitalId};

    context
        .read<HospitalCubit>()
        .fetchHospitalByPage(parameter, context)
        .then((newPosts) {
      if (newPosts["list"].isNotEmpty) {
        hospitalInfo = newPosts["list"].first;
      }
      setState(() {
        isGettingDetail = false;
      });
      if (hospitalInfo!.doctorlist!.isEmpty) {
        getDrList();
      }
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
      appBar: GeneralWidgets.setAppbar(getLables(lblHospital), context,
          elevation: 0, actions: []),
      body: isGettingDetail
          ? Center(child: CircularProgressIndicator())
          : hospitalInfo == null
              ? Center(child: Text(getLables(dataNotFoundErrorMessage)))
              : Column(
                  children: [profileTabs(), Expanded(child: contentWidget())]),
    );
  }

  profileTabs() {
    return Container(
      height: 55,
      color: appbarColor,
      padding: EdgeInsets.only(top: 5, bottom: 10),
      child: ListView(scrollDirection: Axis.horizontal, children: [
        const SizedBox(width: 12),
        tabWidget("0", getLables(lblProfileDetails), keyProfile),
        const SizedBox(width: 12),
        tabWidget("1", getLables(lblAbout), keyAbout),
        if (hospitalInfo != null && hospitalInfo!.specialityList!.isNotEmpty)
          const SizedBox(width: 12),
        if (hospitalInfo != null && hospitalInfo!.specialityList!.isNotEmpty)
          tabWidget("2", getLables(lblSpecializations), keySpecializations),
        if (hospitalInfo != null && hospitalInfo!.doctorlist!.isNotEmpty)
          const SizedBox(width: 12),
        if (hospitalInfo != null && hospitalInfo!.doctorlist!.isNotEmpty)
          tabWidget("3", getLables(lblDoctors), keyDoctors),
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

  contentWidget() {
    return ListView(
        controller: scrollController,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        children: [
          hospitalInfoWidget(),
          aboutWidget(),
          const SizedBox(height: 12),
          specListWidget(),
          drListWidget(),
        ]);
  }

  hospitalInfoWidget() {
    return GeneralWidgets.cardBoxWidget(
      ckey: keyProfile,
      cmargin: EdgeInsetsDirectional.symmetric(horizontal: 0, vertical: 8),
      cpadding: EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 10),
      childWidget: Column(mainAxisSize: MainAxisSize.min, children: [
        hospitalProfile(),
        SizedBox(height: 5),
        Row(children: [
          Expanded(
              child: setHospitalInfo(
            "",
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 20),
              child: Text(
                "${hospitalInfo!.noOfSpecialist!} ${getLables(lblSpecialties)}",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            titlewid: Row(children: [
              GeneralWidgets.setSvg("specialities", width: 17),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  getLables(lblSpecialties),
                  style:
                      Theme.of(context).textTheme.bodySmall!.apply(color: grey),
                ),
              )
            ]),
          )),
          Expanded(
              child: setHospitalInfo(
            "",
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 20),
              child: Text(
                "${hospitalInfo!.noOfDoctor!} ${getLables(lblDoctors)}",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            titlewid: Row(children: [
              GeneralWidgets.setSvg("available_doctor", width: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  getLables(lblAvailableDoctors),
                  style:
                      Theme.of(context).textTheme.bodySmall!.apply(color: grey),
                ),
              )
            ]),
          )),
        ])
      ]),
    );
  }

  hospitalProfile() {
    return Row(children: [
      GeneralWidgets.circularImage(hospitalInfo!.image, height: 60, width: 60),
      const SizedBox(width: 15),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hospitalInfo!.name!,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .merge(TextStyle(fontWeight: FontWeight.normal)),
            ),
            const SizedBox(height: 5),
            Row(children: [
              Icon(
                Icons.location_on,
                color: primaryColor,
                size: 15,
              ),
              Expanded(
                child: Text(hospitalInfo!.address!),
              )
            ]),
            const SizedBox(height: 3),
            GeneralWidgets.rateReviewCountWidget(
                context, hospitalInfo!.totalrate!, hospitalInfo!.totalReviews!),
            const SizedBox(height: 3),
            Text(
              "${getLables(lbloverallrating)} ${hospitalInfo!.totalRatedUser!} ${getLables(lblVisitors)}",
              style: Theme.of(context).textTheme.titleSmall!.merge(TextStyle(
                  fontWeight: FontWeight.normal, color: primaryColor)),
            ),
          ],
        ),
      )
    ]);
  }

  setHospitalInfo(
    String title,
    Widget discwid, {
    Function? clickaction,
    Widget? titlewid,
    Widget? lead,
    TextStyle? titlestyle,
  }) {
    return GeneralWidgets.setListtileMenu(title, context,
        discwidget: discwid,
        leadingwidget: lead,
        titlwidget: titlewid,
        textStyle: titlestyle, onClickAction: () {
      if (clickaction != null) clickaction();
    });
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
              GeneralWidgets.aboutTextWidget(
                  hospitalInfo!.description!.trim(), context,
                  trimline: 4),
            ]));
  }

  specListWidget() {
    return hospitalInfo == null || hospitalInfo!.specialityList!.isEmpty
        ? SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              headerWidget(getLables(lblSpecializations)),
              const SizedBox(height: 8),
              GridView.count(
                  key: keySpecializations,
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 3,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsetsDirectional.only(top: 10),
                  children: List.generate(hospitalInfo!.specialityList!.length,
                      (index) {
                    Speciality speciality =
                        hospitalInfo!.specialityList![index];
                    return Column(mainAxisSize: MainAxisSize.min, children: [
                      GeneralWidgets.circularImage(speciality.image,
                          height: 50, width: 50),
                      const SizedBox(height: 5),
                      Text(
                        speciality.name!,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .apply(color: onPrimaryColor),
                      ),
                    ]);
                  })),
            ],
          );
  }

  drListWidget() {
    if (hospitalInfo!.doctorlist!.isNotEmpty)
      return Column(
        key: keyDoctors,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          headerWidget(getLables(lblHospitalsDoctor)),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: hospitalInfo!.doctorlist!.length,
            separatorBuilder: (context, index) {
              return SizedBox(height: 10);
            },
            itemBuilder: (context, index) {
              return DrListItemWidget(
                  post: hospitalInfo!.doctorlist![index],
                  isDisplayHospital: false);
            },
          ),
        ],
      );
    else
      return SizedBox.shrink();
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
                          color: textColor,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5)),
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
}
