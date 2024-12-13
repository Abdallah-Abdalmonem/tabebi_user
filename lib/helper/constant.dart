import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tabebi/helper/generalMethods.dart';
import '../models/userdata.dart';
import 'sessionManager.dart';
import 'stringLables.dart';

class Constant {
  //static String hosturl = "https://tabebi.mirzapar.com";
  static String hosturl = "https://tabebby.com";
  static String baseUrl = "$hosturl/api/";
  //deeplink
  static String deeplinkUrl = "$hosturl/app/";
  static String deeplinkDrUrl = "$hosturl/app/doctor/";
  static String deeplinkLabUrl = "$hosturl/app/lab/";
  //
  static String joinDrUrl = "$hosturl/doctor-register";
  static String specialityImagePath = "$hosturl/public/images/speciality/";
  static String labImagePath = "$hosturl/public/images/user/";
  static String hospitalImagePath = "$hosturl/public/images/user/";
  static String doctorImagePath = "$hosturl/public/images/doctor/";
  static String patientImagePath = "$hosturl/public/images/patient/";
  static String prescriptionImagePath = "$hosturl/public/images/prescription/";
  static String reportImagePath = "$hosturl/public/images/report/";
  static String notificationImagePath = "$hosturl/public/images/notification/";
  static String socialMediaImagePath = "$hosturl/public/images/socialmedia/";
  //
  //Your package name

  static String iosPackage = 'com.app.tabebiuser';
//Playstore link of your application
  static String androidLink =
      'https://play.google.com/store/apps/details?id=com.app.tabebiuser';
//Appstore link of your application
  static String iosLink = 'your ios link here';
  //
  static String filePath = "";
  static double documentSize = 0.0;
  static String documentSizeFormat = "MB";
  static List<String> uploadReportTypes = [];
  static String aboutUsData = "";
  static String contactUsData = "";
  static String privacyPolicyData = "";
  static String termsConditionsData = "";
  static SessionManager? session;
  static int otpTimeOutSecond = 60; //otp time out
  static int otpResendSecond = 60; // resend otp timer
  static int otpLength = 6;
  static int splashTimeout = 3;
  static int fetchLimit = 20;
  static int specialityFetchLimit = 50;
  static int displayNextAppointmentDay = 7;
  static int slotIntervalTime = 30;
  //static int fetchLimit = 30;
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static UserData? userdata;
  static Map<String, String> drGetListParams = {};
  static DateFormat timeFormatter =
      DateFormat('hh:mm a', Constant.session!.getCurrLangCode());
  static DateFormat timeParserSecond = DateFormat('HH:mm:ss');
  static DateFormat backendDateFormat = DateFormat("yyyy-MM-dd");
  static DateFormat backendDateParser = DateFormat("yyyy-MM-dd HH:mm:ss");
  static String currencyCode = "IQD";
  static int morningSlotStartTime = 9;
  static int eveSlotStartTime = 14;
  static int totalHrAfterEndBook = 3;
  //
  static double defaultRate = 0.5;

  static String getImagePath(String img, {bool issvg = false}) {
    if (issvg) {
      return "assets/svg/$img.svg";
    } else {
      return "assets/images/$img";
    }
  }

//report status=0-pending, 1-approved,2= reject
  static const int reportPending = 0;
  static const int reportApproved = 1;
  static const int reportReject = 2;
  static getReportStatus(int status) {
    String statuslbl;
    Color statuscolor;
    switch (status) {
      case reportApproved:
        statuscolor = Colors.green[800]!;
        statuslbl = lblApproved;
        break;
      case reportPending:
        statuscolor = Colors.orange;
        statuslbl = lblPending;
        break;
      case reportReject:
        statuscolor = Colors.red;
        statuslbl = lblRejected;
        break;
      default:
        statuscolor = Colors.orange;
        statuslbl = lblPending;
        break;
    }
    return {"lbl": statuslbl, "color": statuscolor};
  }

//0-book, 1-came, 2-not came, 3-cancel,4 - ignore
  static const int statusBooked = 0;
  static const int statusCame = 1;
  static const int statusNotCame = 2;
  static const int statusCancel = 3;
  static const int statusIgnore = 4;
  static getAppoinmentStatus(int status) {
    String statuslbl;
    Color statuscolor;
    switch (status) {
      case statusBooked:
        statuscolor = Colors.blue;
        statuslbl = lblBooked;
        break;
      case statusCame:
        statuscolor = Colors.green[800]!;
        statuslbl = lblCame;
        break;
      case statusNotCame:
        statuscolor = Colors.orange;
        statuslbl = lblNotCame;
        break;
      case statusCancel:
        statuscolor = Colors.red;
        statuslbl = lblCanceled;
        break;
      case statusIgnore:
        statuscolor = Colors.pink[200]!;
        statuslbl = lblIgnored;
        break;
      default:
        statuscolor = Colors.yellow;
        statuslbl = lblPending;
        break;
    }
    return {"lbl": statuslbl, "color": statuscolor};
  }
  /*  static getStatusText(String status) {
    switch (status) {
      case "0":
        return getLables(lblPending);
      case "1":
        return getLables(lblConfirm);
      case "2":
        return getLables(lblCanceled);
      case "3":
        return getLables(lblCompleted);
    }
  }

  static getStatusColor(String status) {
    switch (status) {
      case "0":
        return Colors.orange;
      case "1":
        return Colors.green;
      case "2":
        return Colors.red;
      case "3":
        return Colors.blue;
    }
  } */

//2-hospital, 3-center, 4-clinic
  static String entityHospital = "2";
  static String entityCenter = "3";
  static String entityClinic = "4";
//appointment type- 1-doctor, 2-lab
  static String appointmentDoctor = "1";
  static String appointmentLab = "2";
//
  static String defaultLanguageCode = "en";
  static String englishLanguageCode = "en";
  static String arabicLanguageCode = "ar";
  static List<Map> appLanguages = [
    {"languageCode": englishLanguageCode, "languageName": "English"},
    {"languageCode": arabicLanguageCode, "languageName": "عربي - Arabic"},
    //{"languageCode": "ur", "languageName": "اردو - Urdu"},
  ];
  //1-fees, 2-waiting_time, 3-top_ratings, 4-most_recommended
  static String drNoSortyByValue = "0";
  static List<Map> doctorSortByList = [
    {"id": "4", "title": getLables(lblMostRecommended)},
    {"id": "3", "title": getLables(lblTopRatings)},
    {"id": "2", "title": getLables(lblLessWaitingTime)},
    {"id": "1", "title": getLables(lblLessAppointmentPrice)},
  ];

  //1-female, 2-male

  static List<Map> filterGenderList = [
    {"key": "2", "title": getLables(lblMale)},
    {"key": "1", "title": getLables(lblFemale)},
  ];
  //2-hospital, 3-center, 4-clinic
  static List<Map> filterEntityList = [
    {"key": "2", "title": getLables(lblHospital)},
    {"key": "3", "title": getLables(lblCenter)},
    {"key": "4", "title": getLables(lblClinic)},
  ];
  //1-today, 2-tomorrow
  static String anyDateKey = "3";
  static List<Map> filterAvailabilityList = [
    {"key": "1", "title": getLables(lblToday)},
    {"key": "2", "title": getLables(lblTomorrow)},
    {"key": anyDateKey, "title": getLables(lblAnyDate)},
  ];
  static List<dynamic> socialmediaMap = [];
/*   static List<dynamic> socialmediaMap = [
    {"name": lblYoutube, "image": "youtube", "link": ""},
    {"name": lblFacebook, "image": "fb", "link": ""},
    {"name": lblInstagram, "image": "instagram", "link": ""},
  ]; */

  static Country defaultCountry = Country(
      countryCode: 'IQ',
      displayName: "Iraq (IQ) [+964]",
      displayNameNoCountryCode: "Iraq (IQ)",
      e164Key: "964-IQ-0",
      e164Sc: 0,
      example: "7912345678",
      geographic: true,
      level: 1,
      name: "Iraq",
      phoneCode: "964");
  static List<String> imagetypelist = [
    "jpg",
    "jpeg",
    "png",
    "gif",
    "webp",
    "tiff",
    "psd",
    "raw",
    "bmp",
    "heif",
    "indd",
    "jpeg 2000",
    "jfif",
    "exif"
  ];
  static String notificationAddVisitAppointment = "add_visit_appointment";
  static String notificationRescheduleAppointment = "reschedule_appointment";
  static String notificationCancelAppointment = "cancel_appointment";
  static String notificationMyReport = "my_report";
  static String notificationAdmin = "admin";
  static String notificationLabAppointment = "lab_appointment";
  static String notificationDoctorAppointmentReminder =
      "doctor_appointment_reminder";
  static String notificationLabAppointmentReminder = "lab_appointment_reminder";

  //recentList
  static List recentDrlist = [];
  static List recentLablist = [];
  static List recentHospitallist = [];
  // recentCliniclist = [], recentCenterlist = [];
}
