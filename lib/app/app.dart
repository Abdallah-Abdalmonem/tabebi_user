import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabebi/app/routes.dart';
import 'package:tabebi/cubits/auth/provinceCubit.dart';
import 'package:tabebi/cubits/doctor/favouriteDoctorCubit.dart';
import 'package:tabebi/cubits/lab/labTestCubit.dart';
import 'package:tabebi/cubits/specialityCubit.dart';
import 'package:tabebi/helper/generalMethods.dart';
import 'package:tabebi/screens/mainHome/mainPage.dart';
import 'package:tabebi/screens/splashScreen.dart';
import 'package:uni_links/uni_links.dart';
import '../cubits/appLocalizationCubit.dart';
import '../cubits/appointment/drAppointmentCubit.dart';
import '../cubits/appointment/labAppointmentCubit.dart';
import '../cubits/auth/authRepository.dart';
import '../cubits/auth/loginCubit.dart';
import '../cubits/hospital/hospitalCubit.dart';
import '../cubits/hospital/subscribedHospitalCubit.dart';
import '../cubits/notificationCubit.dart';
import '../firebase_options.dart';
import '../helper/colors.dart';
import '../helper/constant.dart';
import '../helper/sessionManager.dart';
import 'appLocalization.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light));

  SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(MyApp(
    prefs: prefs,
  ));
}

class MyApp extends StatefulWidget {
  final SharedPreferences prefs;
  const MyApp({Key? key, required this.prefs}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

enum UniLinksType { string, uri }

class _MyAppState extends State<MyApp> {
  StreamSubscription? deepLinkSubscripiton;
  String initialroute = Routes.splash;
  String fromparam = "";

  @override
  void initState() {
    super.initState();
    Constant.session = SessionManager(prefs: widget.prefs);
    Constant.session!.setData(SessionManager.drFavIds, "");
    Constant.session!.setData(SessionManager.labFavIds, "");
    _handleIncomingLinks();
  }

  void _handleIncomingLinks() async {
    try {
      final initialLink = await getInitialLink();
      deeplinkRedirection(initialLink);
    } catch (e) {
      print('deeplink---initialerr->${e.toString()}');
    }
    deepLinkSubscripiton = uriLinkStream.listen((Uri? uri) {
      if (!mounted) return;
      print('deeplinkUri: $uri');
      deeplinkRedirection(uri.toString());
    }, onError: (Object err) {
      if (!mounted) return;
      print('deeplinkErr: $err');
    });
  }

  deeplinkRedirection(String? link) {
    if (link != null && link.trim().isNotEmpty) {
      //deeplinkUrl
      if (link.startsWith(Constant.deeplinkUrl)) {
        List<String> content =
            link.replaceFirst(Constant.deeplinkUrl, "").split("/");
        String key = content.first;
        //String value = content.last;
        if (key == "doctor" || key == "lab") {
          initialroute = Routes.mainPage;
          fromparam = content.join("==");
          setState(() {});
        }
        print("deeplinkurl-->$link==initial-$initialroute==$fromparam");
      }
    }
  }

  @override
  void dispose() {
    //deepLinkSubscripiton?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<AppLocalizationCubit>(
              create: (_) =>
                  AppLocalizationCubit(SessionManager(prefs: widget.prefs))),
          BlocProvider(create: (context) => SpecialityCubit()),
          BlocProvider(create: (context) => HospitalCubit()),
          BlocProvider(create: (context) => SubscribeHospitalCubit()),
          BlocProvider(create: (context) => ProvinceCubit()),
          BlocProvider(create: (context) => FavDoctorCubit()),
          BlocProvider(create: (context) => LogInCubit(AuthRepository())),
          BlocProvider(create: (context) => DoctorAppointmentCubit()),
          BlocProvider(create: (context) => LabAppointmentCubit()),
          BlocProvider(create: (context) => LabTestCubit()),
          BlocProvider(create: (context) => NotificationCubit()),
        ],
        child: Builder(
          builder: (context) {
            final currentLanguage =
                context.watch<AppLocalizationCubit>().state.language;
            Intl.defaultLocale = currentLanguage.countryCode;

            Constant.timeFormatter =
                DateFormat('hh:mm a', Constant.session!.getCurrLangCode());
            // print("deeplinkurl-->**==initial-$initialroute==$fromparam");
            String typefaceName =
                currentLanguage.languageCode == Constant.arabicLanguageCode
                    ? "MyArabicFont"
                    : 'MyEngFont';
            return MaterialApp(
              navigatorKey: Constant.navigatorKey,
              theme: ThemeData(
                scaffoldBackgroundColor: pageBackgroundColor,
                primaryColor: primaryColor,
                fontFamily: typefaceName,
                textTheme: Theme.of(context).textTheme.apply(
                      bodyColor: textColor,
                      displayColor: textColor,
                      fontFamily: typefaceName,
                    ),
                colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: primaryColor,
                      onPrimary: onPrimaryColor,
                      secondary: secondaryColor,
                      background: backgroundColor,
                      error: errorColor,
                      onSecondary: onSecondaryColor,
                      onBackground: onBackgroundColor,
                    ),
              ),
              debugShowCheckedModeBanner: false,

              home: initialroute == Routes.splash
                  ? SplashScreen()
                  : MainPage(from: fromparam),
              //initialRoute: Routes.splash,
              onGenerateRoute: Routes.onGenerateRouted,
              locale: currentLanguage,
              supportedLocales: Constant.appLanguages.map((appLanguage) {
                return GeneralMethods.getLocaleFromLanguageCode(
                    appLanguage["languageCode"]);
              }).toList(),
              localizationsDelegates: const [
                AppLocalization.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            );
          },
        ));
  }
}
