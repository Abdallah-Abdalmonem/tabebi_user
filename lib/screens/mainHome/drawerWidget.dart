import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tabebi/cubits/auth/loginCubit.dart';
import 'package:tabebi/helper/colors.dart';
import 'package:tabebi/helper/constant.dart';
import 'package:tabebi/helper/generalMethods.dart';
import 'package:tabebi/helper/stringLables.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/routes.dart';
import '../../helper/generaWidgets.dart';

class DrawerWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function indexChangeCallback;
  const DrawerWidget(
      {super.key,
      required this.scaffoldKey,
      required this.indexChangeCallback});

  @override
  State<DrawerWidget> createState() => DrawerWidgetState();
}

class DrawerWidgetState extends State<DrawerWidget> {
  List<Map> menus = [];
  List<Map> othermenus = [];
  bool islogin = Constant.session!.isUserLoggedIn();
  @override
  void initState() {
    super.initState();
    islogin = Constant.session!.isUserLoggedIn();
    menusetup();
  }

  menusetup() {
    menus = [
      {
        "image": "dr_search_dr",
        "title": getLables(lblSearchDoctor),
        "clickacction": () {
          GeneralMethods.goToNextPage(
              Routes.specialitylistpage, context, false);
        }
      },
      {
        "image": "dr_hospital",
        "title": getLables(lblViewHospitals),
        "clickacction": () {
          GeneralMethods.goToNextPage(
            Routes.hospitalListPage,
            context,
            false,
          );
        }
      },
      {
        "image": "dr_location",
        "title": getLables(lblChangeLocation),
        "clickacction": () {
          GeneralMethods.goToNextPage(Routes.selectProvincePage, context, false,
              args: true);
        }
      },
      {
        "image": "dr_contactus",
        "title": getLables(lblContactUs),
        "clickacction": () {
          GeneralMethods.goToNextPage(Routes.policyPage, context, false,
              args: {"title": lblContactUs, "content": Constant.contactUsData});
        }
      },
      {
        "image": "dr_shareapp",
        "title": getLables(lblShareApp),
        "clickacction": () async {
          var str =
              "${getLables(appName)}\n\n${getLables(lblShareAppInfo)}\n${getLables(lblAndroid)} ${Constant.androidLink}\n\n ${getLables(lblIos)} ${Constant.iosLink}";
          await Share.share(str, subject: getLables(appName));
          /*await Share.share(
            "${getLables(appName)}\n${Constant.deeplinkUrl}doctor/1",
            subject: getLables(appName),
          );*/
        }
      },
      {
        "image": "dr_settings",
        "title": getLables(lblSettings),
        "clickacction": () {
          GeneralMethods.goToNextPage(Routes.settingPage, context, false);
        }
      },
    ];
    if (Constant.session!.isUserLoggedIn()) {
      menus.add({
        "image": "dr_appointments",
        "title": getLables(lblMyAppointment),
        "clickacction": () {
          widget.indexChangeCallback(1);
        }
      });
      menus.add({
        "image": "dr_favorite",
        "title": getLables(lblMyFavorite),
        "clickacction": () {
          GeneralMethods.goToNextPage(Routes.favDoctorListPage, context, false);
        }
      });
    }
    othermenus = [
      {
        "image": "dr_are_you_doctor",
        "title": getLables(lblAreuDr),
        "clickacction": () async {
          Uri uri = Uri.parse(Constant.joinDrUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            throw 'Could not launch ${Constant.joinDrUrl}';
          }
        }
      },
      {
        "image": "dr_about",
        "title": getLables(lblAbout),
        "clickacction": () {
          GeneralMethods.goToNextPage(Routes.policyPage, context, false,
              args: {"title": lblAbout, "content": Constant.aboutUsData});
        }
      },
      {
        "image": "dr_privacypolicy",
        "title": getLables(lblPrivacyPolicy),
        "clickacction": () {
          GeneralMethods.goToNextPage(Routes.policyPage, context, false, args: {
            "title": lblPrivacyPolicy,
            "content": Constant.privacyPolicyData
          });
        }
      },
      {
        "image": "dr_terms",
        "title": getLables(lblTermsOfService),
        "clickacction": () {
          GeneralMethods.goToNextPage(Routes.policyPage, context, false, args: {
            "title": lblTermsOfService,
            "content": Constant.termsConditionsData
          });
        }
      },
      {
        "image": islogin ? "dr_logout" : "dr_login",
        "title": getLables(islogin ? lblLogout : lblLogin),
        "clickacction": () {
          if (islogin) {
            // Constant.session!.logoutUser(Constant.navigatorKey.currentContext!);
            openLogoutDialog();
          } else {
            //
            GeneralMethods.openLoginScreen();
            /* GeneralWidgets.showBottomSheet(
              context: Constant.navigatorKey.currentContext!,
              btmchild: BlocProvider(
                create: (context) => LogInCubit(AuthRepository()),
                child: LoginScreen(),
              ),
            ); */
          }
        }
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        width: MediaQuery.of(context).size.width - 50,
        backgroundColor: white,
        child: ListView(
          padding: EdgeInsets.symmetric(
              horizontal: 10, vertical: MediaQuery.of(context).padding.top),
          children: [
            drawerHeaderWidget(),
            Wrap(
                children: List.generate(menus.length, (index) {
              return drawerItemWidget(menus[index]["image"],
                  menus[index]["title"], menus[index]["clickacction"]);
            })),
            Divider(
              color: grey,
            ),
            Wrap(
                children: List.generate(othermenus.length, (index) {
              return drawerItemWidget(
                  othermenus[index]["image"],
                  othermenus[index]["title"],
                  othermenus[index]["clickacction"]);
            })),
          ],
        ));
  }

  drawerItemWidget(String image, String title, Function callback) {
    return GestureDetector(
      onTap: () {
        widget.scaffoldKey.currentState!.closeDrawer();
        callback();
      },
      child: GeneralWidgets.cardBoxWidget(
          celevation: 0,
          cpadding:
              EdgeInsetsDirectional.only(top: 8, bottom: 8, start: 8, end: 5),
          childWidget: Row(children: [
            GeneralWidgets.setSvg(image, width: 20),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5),
              ),
            ),
          ])),
    );
  }

  drawerHeaderWidget() {
    return GeneralWidgets.cardBoxWidget(
        celevation: 0,
        cardcolor: backgroundColor,
        cpadding:
            EdgeInsetsDirectional.only(start: 10, end: 5, top: 12, bottom: 12),
        childWidget: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            widget.scaffoldKey.currentState!.closeDrawer();
            if (Constant.session!.isUserLoggedIn()) {
              GeneralMethods.goToNextPage(
                  Routes.editProfilePage, context, false,
                  args: false);
            } else {
              //
              GeneralMethods.openLoginScreen();
              //
              // GeneralMethods.goToNextPage(Routes.login, context, false);
            }
          },
          child: Row(children: [
            GeneralWidgets.circularImage(
                islogin && Constant.userdata != null
                    ? Constant.userdata!.image!.trim()
                    : "sidemenulogo",
                issvg: !islogin,
                defaultimg: "sidemenulogo",
                height: 42,
                width: 42),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      islogin && Constant.userdata != null
                          ? Constant.userdata!.name!
                          : getLables(lblDrawerTitle),
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5),
                    ),
                    Text(
                      islogin && Constant.userdata != null
                          ? Constant.userdata!.mobileno
                          : getLables(lblLogin),
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: islogin ? grey : greencolor, height: 1.5),
                    )
                  ]),
            )
          ]),
        ));
  }

  openLogoutDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsetsDirectional.zero,
              elevation: 0.0,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      padding: const EdgeInsetsDirectional.all(20),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16.0))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            child: Icon(
                              Icons.power_settings_new,
                              color: Theme.of(context).colorScheme.primary,
                              size: 50,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            '${getLables(lblLogout)} ?',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                          ),
                          const SizedBox(
                            height: 14,
                          ),
                          Text(
                            getLables(logoutConfirmMsg),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(color: grey),
                          ),
                          const SizedBox(
                            height: 28,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                  child: GeneralWidgets.btnWidget(
                                      context, getLables(lblCancel),
                                      bheight: 34,
                                      bordercolor:
                                          Theme.of(context).colorScheme.primary,
                                      btncolor: white,
                                      textcolor:
                                          Theme.of(context).colorScheme.primary,
                                      callback: () =>
                                          Navigator.of(context).pop())),
                              const SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                  child: GeneralWidgets.btnWidget(
                                      context, getLables(lblLogout),
                                      bheight: 34,
                                      btncolor: Theme.of(context)
                                          .colorScheme
                                          .primary, callback: () {
                                Navigator.of(context).pop();
                                context.read<LogInCubit>().setLogout();
                              }))
                            ],
                          )
                        ],
                      )),
                ],
              ));
        });
  }
}
