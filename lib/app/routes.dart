import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabebi/cubits/auth/cityCubit.dart';
import 'package:tabebi/cubits/lab/labTestCubit.dart';
import 'package:tabebi/cubits/lab/labCubit.dart';
import 'package:tabebi/cubits/myRecordCubit.dart';
import 'package:tabebi/cubits/searchCubit.dart';
import 'package:tabebi/cubits/slotCubit.dart';
import 'package:tabebi/models/doctor.dart';
import 'package:tabebi/models/lab.dart';
import 'package:tabebi/models/province.dart';
import 'package:tabebi/screens/auth/provinceListPage.dart';
import 'package:tabebi/screens/doctorAppointment/DoctorList/doctorListPage.dart';
import 'package:tabebi/screens/doctorAppointment/addBookingResponsePage.dart';
import 'package:tabebi/screens/doctorAppointment/confirmDrAppointment.dart';
import 'package:tabebi/screens/doctorAppointment/doctorDetailPage.dart';
import 'package:tabebi/screens/doctorAppointment/reviewList.dart';
import 'package:tabebi/screens/doctorAppointment/selectDrTimeSlot.dart';
import 'package:tabebi/screens/doctorAppointment/specialityListPage.dart';
import 'package:tabebi/screens/favourite/favouriteMain.dart';
import 'package:tabebi/screens/hospital/hospitalDetailPage.dart';
import 'package:tabebi/screens/hospital/hospitalListPage.dart';
import 'package:tabebi/screens/labAppointment/confirmLabAppointment.dart';
import 'package:tabebi/screens/labAppointment/labDetailPage.dart';
import 'package:tabebi/screens/labAppointment/labListPage.dart';
import 'package:tabebi/screens/labAppointment/selectLabTimeSlot.dart';
import 'package:tabebi/screens/labAppointment/testListPage.dart';
import 'package:tabebi/screens/mainHome/mainPage.dart';
import 'package:tabebi/screens/mainHome/searchContentPage.dart';
import 'package:tabebi/screens/myRecords/addReportPage.dart';
import 'package:tabebi/screens/notification/notificationDetailPage.dart';
import 'package:tabebi/screens/settings/editProfilePage.dart';
import 'package:tabebi/screens/settings/policyPage.dart';
import 'package:tabebi/screens/settings/settingPage.dart';
import '../cubits/doctor/bookAppointmentCubit.dart';
import '../cubits/doctor/doctorCubit.dart';
import '../cubits/doctor/reviewCubit.dart';
import '../models/hospital.dart';
import '../screens/auth/cityListPage.dart';
import '../screens/hospital/topHospitalListPage.dart';
import '../screens/myRecords/docViewerPage.dart';
import '../screens/notification/notificationListPage.dart';
import '../screens/splashScreen.dart';

class Routes {
  static const String splash = "/";
  static const String login = "login";
  static const String mainPage = "mainPage";
  static const String selectProvincePage = "selectProvincePage";
  static const String selectCityPage = "selectCityPage";
  static const String doctorlistpage = "doctorlistpage";
  static const String lablistpage = "lablistpage";
  static const String specialitylistpage = "specialitylistpage";
  static const String doctorDetailPage = "doctorDetailPage";
  static const String reviewlist = "reviewlist";
  static const String selectDrtimeslot = "selectDrtimeslot";
  static const String selectLabtimeslot = "selectLabtimeslot";
  static const String confirmDrAppointment = "confirmDrAppointment";
  static const String confirmLabAppointment = "confirmLabAppointment";
  static const String bookingResponsePage = "bookingResponsePage";
  static const String labTestListPage = "labTestListPage";
  static const String labDetailPage = "labDetailPage";
  static const String topHospitalListPage = "topHospitalListPage";
  static const String hospitalListPage = "hospitalListPage";
  static const String hospitalDetailPage = "hospitalDetailPage";
  static const String addReportPage = "addreportpage";
  static const String editProfilePage = "editProfilePage";
  static const String notificationListPage = "notificationListPage";
  static const String settingPage = "settingPage";
  static const String notificationDetailPage = "notificationDetailPage";
  static const String favDoctorListPage = "favDoctorListPage";
  static const String docViewerPage = "docViewerPage";
  static const String searchPage = "searchPage";
  static const String policyPage = "policyPage";
  static String currentRoute = splash;
  static String previoudRoute = splash;

  static Route<dynamic> onGenerateRouted(RouteSettings routeSettings) {
    previoudRoute = currentRoute;
    currentRoute = routeSettings.name ?? "";
    print("currRoute->$currentRoute");
    switch (routeSettings.name) {
      case splash:
        return routePage(const SplashScreen());
      case mainPage:
        return routePage(MainPage(
          from: routeSettings.arguments as String,
        ));
      case selectProvincePage:
        return routePage(
            ProvinceListPage(isFromSplash: routeSettings.arguments as bool));
      case selectCityPage:
        Map? arguments = routeSettings.arguments as Map?;
        return routePage(BlocProvider<CityCubit>(
          create: (context) => CityCubit(),
          child: CityListPage(
              isFromSplash: arguments!["isFromSplash"] as bool,
              selectedProvince: arguments.containsKey("selectedProvince")
                  ? arguments["selectedProvince"] as Province
                  : null),
        ));
      case doctorlistpage:
        return routePage(BlocProvider(
          create: (context) => DoctorCubit(),
          child: DoctorListPage(),
        ));
      case lablistpage:
        Map? arguments = routeSettings.arguments as Map?;
        return routePage(BlocProvider(
          create: (context) => LabCubit(),
          child: LabListPage(),
        ));
      case specialitylistpage:
        return routePage(SpecialityListPage());
      case hospitalListPage:
        return routePage(HospitalListPage(
            extraparams: routeSettings.arguments == null
                ? null
                : routeSettings.arguments as Map<String, String>));
      case topHospitalListPage:
        return routePage(TopHospitalListPage(
            extraparams: routeSettings.arguments == null
                ? null
                : routeSettings.arguments as Map<String, String>));
      case favDoctorListPage:
        return routePage(FavouriteMain());
      case reviewlist:
        Map? arguments = routeSettings.arguments as Map?;
        return routePage(ReviewList(
          reviewCubit: arguments!["reviewCubit"],
          mainparameter: arguments["mainparameter"],
        ));
      case selectDrtimeslot:
        return routePage(BlocProvider(
          create: (context) => SlotCubit(),
          child:
              SelectDrTimeSlot(doctorInfo: routeSettings.arguments as Doctor),
        ));
      case selectLabtimeslot:
        return routePage(BlocProvider(
          create: (context) => SlotCubit(),
          child: SelectLabTimeSlot(labInfo: routeSettings.arguments as Lab),
        ));
      case bookingResponsePage:
        Map? arguments = routeSettings.arguments as Map?;
        return routePage(AddBookingResponsePage(
          message: arguments!["message"],
          type: arguments["type"],
          slotDateTime: arguments["slotDateTime"],
        ));
      case doctorDetailPage:
        Map? arguments = routeSettings.arguments as Map?;
        return routePage(MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => ReviewCubit(),
            ),
            BlocProvider(
              create: (context) => DoctorCubit(),
            ),
          ],
          child: DoctorDetailPage(
            doctor: arguments!["doctor"] as Doctor?,
            favIndex: arguments.containsKey("favIndex")
                ? arguments["favIndex"] as int?
                : null,
            favcubit: arguments.containsKey("favcubit")
                ? arguments["favcubit"]
                : null,
            drId: arguments["drId"] as String?,
          ),
        ));
      case confirmDrAppointment:
        Map? arguments = routeSettings.arguments as Map?;
        return routePage(BlocProvider(
          create: (context) => BookAppointmentCubit(),
          child: ConfirmDrAppointment(
            doctorInfo: arguments!["doctorInfo"] as Doctor?,
            slotDateTime: arguments["slotDateTime"] as DateTime?,
            waitingtime: arguments["waitingtime"] as String?,
          ),
        ));
      case confirmLabAppointment:
        Map? arguments = routeSettings.arguments as Map?;
        return routePage(BlocProvider(
          create: (context) => BookAppointmentCubit(),
          child: ConfirmLabAppointment(
            labInfo: arguments!["labInfo"] as Lab?,
            slotDateTime: arguments["slotDateTime"] as DateTime?,
            waitingtime: arguments["waitingtime"] as String?,
          ),
        ));
      case labTestListPage:
        Map? arguments = routeSettings.arguments as Map?;
        return routePage(TestListPage(
            labCubit: arguments!.containsKey("labCubit")
                ? arguments["labCubit"]
                : null,
            labTestList: arguments.containsKey("labTestList")
                ? arguments["labTestList"]
                : null,
            labid: arguments.containsKey("labid") ? arguments["labid"] : ""));
      case labDetailPage:
        Map? arguments = routeSettings.arguments as Map?;
        return routePage(MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => ReviewCubit(),
            ),
            BlocProvider(
              create: (context) => LabTestCubit(),
            ),
            BlocProvider(
              create: (context) => LabCubit(),
            ),
          ],
          child: LabDetailPage(
            lab:
                arguments!.containsKey("lab") ? arguments["lab"] as Lab? : null,
            labId: arguments["labId"] as String?,
            fromSelectTest: arguments["fromSelectTest"] as bool?,
            favIndex: arguments.containsKey("favIndex")
                ? arguments["favIndex"] as int?
                : null,
            favcubit: arguments.containsKey("favcubit")
                ? arguments["favcubit"]
                : null,
          ),
        ));
      case hospitalDetailPage:
        Map? arguments = routeSettings.arguments as Map?;
        return routePage(BlocProvider(
          create: (context) => DoctorCubit(),
          child: HospitalDetailPage(
              hospital: arguments!["hospital"] as Hospital?,
              hospitalId: arguments["hospitalId"] as String?),
        ));
      case addReportPage:
        return routePage(AddReportPage(
          myRecordCubit: routeSettings.arguments as MyRecordCubit,
        ));
      case settingPage:
        return routePage(SettingPage());
      case editProfilePage:
        return routePage(EditProfilePage(
          isBackIfSuccess: (routeSettings.arguments ?? false) as bool,
        ));
      case notificationDetailPage:
        return routePage(NotificationDetailPage());
      case notificationListPage:
        return routePage(NotificationListPage());
      case docViewerPage:
        return routePage(DocViewerPage(
          url: routeSettings.arguments as String,
        ));
      case searchPage:
        return routePage(BlocProvider(
          create: (context) => SearchCubit(),
          child: SearchContentPage(),
        ));
      case policyPage:
        Map? arguments = routeSettings.arguments as Map?;
        return routePage(PolicyPage(
          content: arguments!["content"] as String,
          title: arguments["title"] as String,
        ));
      default:
        return routePage(const Scaffold());
    }
  }

  static routePage(var page) {
    return CupertinoPageRoute(builder: (_) => page);
  }
}
