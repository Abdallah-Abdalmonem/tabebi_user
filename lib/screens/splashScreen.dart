import 'package:flutter/material.dart';
import 'package:tabebi/app/routes.dart';
import 'package:tabebi/helper/constant.dart';
import 'package:tabebi/helper/generaWidgets.dart';
import 'package:tabebi/helper/generalMethods.dart';
import 'package:tabebi/helper/sessionManager.dart';
import 'package:tabebi/helper/stringLables.dart';

import '../helper/api.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: Duration(seconds: Constant.splashTimeout),
    vsync: this,
  )..forward();
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
          child: ScaleTransition(
        scale: _animation,
        child: GeneralWidgets.setSvg("splashlogo"),
        /* child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GeneralWidgets.setSvg("splashlogo"),
            const SizedBox(height: 8),
            Text(
              testVersion,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(color: Colors.white),
            ),
          ],
        ),*/
      )),
    );
  }

  @override
  void initState() {
    super.initState();

    navigateToNextScreen();
  }

  void navigateToNextScreen() async {
    print("splash==");
    Api.getAppSettings(context);
    await Future.delayed(Duration(seconds: Constant.splashTimeout), () {
      if (Constant.session!.getData(SessionManager.keyCityId).trim().isEmpty) {
        GeneralMethods.goToNextPage(Routes.selectProvincePage, context, true,
            args: true);
      } /*else if (Constant.session!.isUserLoggedIn() &&
          Constant.session!.getData(SessionManager.keyName).trim().isEmpty) {
        GeneralMethods.goToNextPage(Routes.editProfilePage, context, false);
      } */
      else {
        // Constant.session!.isUserLoggedIn() ? Routes.mainPage : Routes.login,
        GeneralMethods.goToNextPage(Routes.mainPage, context, true,
            args: "splash");
      }
    });
  }
}
