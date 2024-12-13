import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabebi/app/routes.dart';
import 'package:tabebi/cubits/specialityCubit.dart';
import 'package:tabebi/helper/colors.dart';
import 'package:tabebi/helper/constant.dart';
import 'package:tabebi/helper/designConfig.dart';
import 'package:tabebi/helper/generaWidgets.dart';
import 'package:tabebi/helper/generalMethods.dart';
import 'package:tabebi/models/hospital.dart';
import 'package:tabebi/models/speciality.dart';
import 'package:tabebi/screens/mainHome/mainPage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../cubits/hospital/subscribedHospitalCubit.dart';
import '../../helper/apiParams.dart';
import '../../helper/stringLables.dart';

class HomePage extends StatefulWidget {
  final Function indexChangeCallback;
  const HomePage({Key? key, required this.indexChangeCallback})
      : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  double spaceBetweenWidget = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          children: [
            searchWidget(),
            const SizedBox(height: 20),
            myAppointmentWidget(),
            const SizedBox(height: 20),
            bookingWidget(),
            hospitalWidget(),
            specialityWidget(),
            socialMediaWidget(),
          ]),
    );
  }

  bookingWidget() {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          headerWidget(getLables(homeBookHeader)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: bookContent("doctor", getLables(doctorAppointment),
                    getLables(homeDrBookSubhead),
                    callback: () => GeneralMethods.goToNextPage(
                        Routes.specialitylistpage, context, false))),
            const SizedBox(width: 10),
            Expanded(
              child: bookContent(
                  "lab", getLables(labTests), getLables(homeLabBookSubhead),
                  callback: () => GeneralMethods.goToNextPage(
                      Routes.lablistpage, context, false)),
            ),
          ]),
        ]);
  }

  bookContent(String image, String title, String desc, {Function? callback}) {
    return GestureDetector(
        onTap: () {
          if (callback != null) callback();
        },
        child: Container(
            padding: EdgeInsetsDirectional.only(
                start: 12, end: 5, top: 10, bottom: 5),
            decoration: DesignConfig.boxDecorationWithShadow(Colors.white, 8,
                shadowcolor: lightGrey.withOpacity(0.3)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GeneralWidgets.setSvg(image, height: 50, width: 50),
                const SizedBox(height: 5),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .apply(color: onPrimaryColor),
                ),
                const SizedBox(height: 3),
                Text(desc + '\n',
                    maxLines: 2,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .merge(TextStyle(color: lightGrey, height: 1))),
              ],
            )));
  }

  myAppointmentWidget() {
    return GestureDetector(
        onTap: () {
          widget.indexChangeCallback(1);
        },
        child: GeneralWidgets.cardBoxWidget(
            celevation: 0,
            cradius: 5,
            cmargin: EdgeInsetsDirectional.zero,
            cpadding:
                EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 12),
            childWidget: Row(children: [
              GeneralWidgets.setSvg("myappointments"),
              const SizedBox(width: 10),
              Expanded(
                child: Text(getLables(lblMyAppointment),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(letterSpacing: 0.5)),
              ),
              GeneralWidgets.setSvg("arrow")
            ])));

    /*GeneralWidgets.setListtileMenu(
            getLables(lblMyAppointment), context,
            /*shapeBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),*/
            lcontentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leadingwidget: GeneralWidgets.setSvg("myappointments"),
            trailingwidget: GeneralWidgets.setSvg("arrow"),
            textStyle: Theme.of(context).textTheme.titleMedium);*/
  }

  headerWidget(String header, {Function? viewallfun}) {
    return Row(
      children: [
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            header,
            style: Theme.of(context).textTheme.titleMedium!.merge(
                TextStyle(fontWeight: FontWeight.w500, letterSpacing: 0.5)),
          ),
        ),
        if (viewallfun != null)
          TextButton(
              onPressed: () {
                viewallfun();
              },
              child: Text(
                getLables(lblViewAll),
                style:
                    Theme.of(context).textTheme.labelMedium!.apply(color: grey),
              ))
      ],
    );
  }

  searchWidget() {
    return GeneralWidgets.searchWidget(
        TextEditingController(), context, getLables(homescreenSearchLbl),
        cardmargin: EdgeInsetsDirectional.zero,
        iconPadding: EdgeInsets.only(top: 5),
        verticalpadding: 5,
        focusnode: AlwaysDisabledFocusNode(), tapCallback: () {
      // print("click");
      GeneralMethods.goToNextPage(Routes.searchPage, context, false);
    });
  }

  hospitalWidget() {
    return BlocBuilder<SubscribeHospitalCubit, SubscribeHospitalState>(
      builder: (context, state) {
        print("hospital-state=>$state");
        if (state is SubscribeHospitalSuccess) {
          return hospitalMainWidget(state.hospitalList);
        } else if (state is SubscribeHospitalLocalSuccess) {
          return hospitalMainWidget(state.hospitalList);
        } else if (state is SubscribeHospitalProgress) {
          return Center(child: CircularProgressIndicator());
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  hospitalMainWidget(List<Hospital> hospitallist) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        headerWidget(getLables(homeHospitalHeader), viewallfun: () {
          GeneralMethods.goToNextPage(
              Routes.topHospitalListPage, context, false,
              args: {ApiParams.isSubscribe: "1"});
        }),
        Container(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: hospitallist.length,
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(width: 8);
            },
            itemBuilder: (context, index) {
              Hospital hospital = hospitallist[index];
              return GestureDetector(
                  onTap: () {
                    GeneralMethods.goToNextPage(
                        Routes.hospitalDetailPage, context, false, args: {
                      "hospital": hospital,
                      "hospitalId": hospital.id!.toString()
                    });
                  },
                  child: GeneralWidgets.cardBoxWidget(
                      celevation: 0,
                      cradius: 5,
                      cmargin: EdgeInsetsDirectional.zero,
                      cpadding:
                          const EdgeInsetsDirectional.symmetric(horizontal: 10),
                      childWidget: Container(
                        height: 80,
                        width: MediaQuery.of(context).size.width / 1.5,
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width / 1.5,
                        ),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GeneralWidgets.circularImage(hospital.image,
                                  height: 50, width: 50),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        hospital.name!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .merge(TextStyle(
                                                color: onPrimaryColor,
                                                height: 1)),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        "${hospital.noOfDoctor!} ${getLables(drAvailable)}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .merge(TextStyle(
                                                color: onPrimaryColor,
                                                height: 1)),
                                      ),
                                      Text(
                                        "${hospital.noOfSpecialist} ${getLables(specialistAvailable)}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .apply(color: onPrimaryColor),
                                      ),
                                    ]),
                              )
                            ]),
                      )));
            },
          ),
        ),
      ],
    );
  }

  specialityWidget() {
    return BlocBuilder<SpecialityCubit, SpecialityState>(
      builder: (context, state) {
        print("specialitystate=>$state");
        if (state is SpecialitySuccess) {
          return specialityMainWidget(state.specialityList);
        } else if (state is SpecialityLocalSuccess) {
          return specialityMainWidget(state.specialityList);
        } else if (state is SpecialityProgress) {
          return Container(
              alignment: Alignment.center,
              margin: EdgeInsetsDirectional.only(top: 10),
              child: CircularProgressIndicator());
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  specialityMainWidget(List<Speciality> specialityList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        headerWidget(getLables(homeSpecialityHeader), viewallfun: () {
          GeneralMethods.goToNextPage(
              Routes.specialitylistpage, context, false);
        }),
        Container(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: specialityList.length,
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(width: 25);
            },
            itemBuilder: (context, index) {
              Speciality speciality = specialityList[index];
              return GestureDetector(
                onTap: () {
                  Constant.drGetListParams = {};
                  Constant.drGetListParams[ApiParams.specialityId] =
                      speciality.id.toString();
                  GeneralMethods.goToNextPage(
                    Routes.doctorlistpage,
                    context,
                    false,
                  );
                },
                child: SizedBox(
                  width: 70,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                  ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  socialMediaWidget() {
    return StreamBuilder<Object>(
        stream: settingController!.stream,
        builder: (context, snapshot) {
          if (Constant.socialmediaMap.isEmpty)
            return SizedBox.shrink();
          else
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
                headerWidget(
                  getLables(homeSocialHeader),
                ),
                Container(
                  height: 80,
                  margin: EdgeInsets.only(top: 8),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: Constant.socialmediaMap.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(width: 25);
                    },
                    itemBuilder: (context, index) {
                      Map socialmap = Constant.socialmediaMap[index];
                      String image = socialmap["image"];
                      if (!image.contains(Constant.hosturl)) {
                        image = Constant.socialMediaImagePath + image;
                      }
                      return GestureDetector(
                        onTap: () async {
                          if (socialmap["link"].toString().trim().isNotEmpty) {
                            Uri uri = Uri.parse(socialmap["link"]);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            } else {
                              throw 'Could not launch ${socialmap["link"]}';
                            }
                          }
                        },
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          GeneralWidgets.circularImage(image,
                              height: 50, width: 50),
                          const SizedBox(height: 5),
                          Text(
                            getLables(socialmap["name"]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .apply(color: onPrimaryColor),
                          ),
                        ]),
                      );
                    },
                  ),
                ),
              ],
            );
        });
  }
}
