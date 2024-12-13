import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tabebi/helper/constant.dart';
import 'package:tabebi/models/appointment.dart';
import 'package:tabebi/models/review.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/routes.dart';
import '../../helper/api.dart';
import '../../helper/apiParams.dart';
import '../../helper/colors.dart';
import '../../helper/designConfig.dart';
import '../../helper/flutterRatingBar.dart';
import '../../helper/generaWidgets.dart';
import '../../helper/generalMethods.dart';
import '../../helper/stringLables.dart';

class AppointmentBtnWidgets extends StatelessWidget {
  final Appointment? appointment;
  final int? index;
  final Function? callback;

  const AppointmentBtnWidgets(
      {Key? key, required this.appointment, required this.index, this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return appointmentBtnWidgets(appointment!, context);
  }

  appointmentBtnWidgets(Appointment post, BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      if (post.status == Constant.statusCame)
        btnWidget(Icons.star_rounded, lblAddReview, context,
            isEnable: post.review == null, callback: () {
          giveReview(post, context);
        }),
      const SizedBox(
        width: 5,
      ),
      btnWidget(Icons.description, lblViewFiles, context,
          isEnable: post.attachmentlist!.isNotEmpty, callback: () {
        openAttachmentlist(post, context);
      }),
      const SizedBox(
        width: 5,
      ),
      btnWidget(Icons.gps_fixed, lblGetDirection, context, callback: () async {
        String url = 'https://www.google.com/maps/search/?api=1&query=';
        if (post.lab != null) {
          url = url + "${post.lab!.latitude},${post.lab!.longitude}";
        } else {
          url = url +
              "${post.doctor!.hospital!.latitude},${post.doctor!.hospital!.longitude}";
        }

        Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch $url';
        }
      }),
    ]);
  }

  openAttachmentlist(Appointment post, BuildContext context) async {
    if (post.attachmentlist!.isEmpty) {
      return;
    }

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
                      post.patientName!,
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
                        DateFormat("MMM dd yy, hh:mm a",
                                Constant.session!.getCurrLangCode())
                            .format(
                                DateTime.parse("${post.date} ${post.time}")),
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
                    return GeneralWidgets.setListtileMenu(
                        url.split("/").last, context, onClickAction: () {
                      Navigator.of(context).pop();
                      GeneralMethods.goToNextPage(
                          Routes.docViewerPage, context, false,
                          args: url);
                      /*
                      await Api.downloadFile(url, context).then((value) {
                        print("dwpath->${value["path"]}");
                        print("dwpath->message-${value["message"]}");
                        Navigator.of(context).pop();
                        Future.delayed(Duration(milliseconds: 500), () {
                          GeneralMethods.showSnackBarMsg(
                              context, value["message"]);
                        });
                      });
                     */
                    },
                        discwidget: FutureBuilder(
                          future: Api.getFileLength(url),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData) {
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
                        textStyle: Theme.of(context).textTheme.bodySmall);
                  }))
                ])),
        context: context);
  }

  btnWidget(IconData icon, String lbl, BuildContext context,
      {bool isEnable = true, Function? callback}) {
    return Expanded(
      child: OutlinedButton.icon(
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
          color: isEnable ? primaryColor : primaryColor.withOpacity(0.5),
        ),
        label: Text(
          getLables(lbl),
          style: Theme.of(context).textTheme.bodySmall!.apply(
              color: isEnable ? primaryColor : primaryColor.withOpacity(0.5)),
        ),
      ),
    );
  }

  giveReview(Appointment post, context) async {
    print("id->${post.id}");
    final TextEditingController commentController = TextEditingController(
        text: post.review == null ? "" : post.review!.review!);
    double postrating = post.review == null || post.review!.rating! <= 0
        ? Constant.defaultRate
        : post.review!.rating!;
    double rates = postrating, initialrate = postrating;

    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(DesignConfig.bottomSheetTopRadius),
                topRight: Radius.circular(DesignConfig.bottomSheetTopRadius))),
        builder: (context) => Padding(
              padding: EdgeInsetsDirectional.only(
                  top: MediaQuery.of(context).size.height * (0.02),
                  start: MediaQuery.of(context).size.width * (0.035),
                  end: MediaQuery.of(context).size.width * (0.035),
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsetsDirectional.symmetric(
                        horizontal: 12, vertical: 8),
                    child: Text(
                      getLables(
                          post.review != null ? lblReviews : lblAddReview),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .merge(TextStyle(color: primaryColor)),
                    ),
                  ),
                  Divider(
                    thickness: 2,
                  ),
                  RatingBar(
                    initialRating: initialrate,
                    minRating: 0.5,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    ratingWidget: RatingWidget(
                      full: const Icon(
                        Icons.star_rounded,
                        color: Color.fromARGB(255, 232, 192, 34),
                      ),
                      half: const Icon(
                        Icons.star_half_rounded,
                        color: Color.fromARGB(255, 232, 192, 34),
                      ),
                      empty: const Icon(
                        Icons.star_outline_rounded,
                        color: Color.fromARGB(255, 232, 192, 34),
                      ),
                    ),
                    itemSize: 50.0,
                    ignoreGestures: post.review != null,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 6),
                    onRatingUpdate: (rating) {
                      rates = rating;
                    },
                  ),
                  Padding(
                      padding: EdgeInsetsDirectional.symmetric(
                          horizontal: 12, vertical: 12),
                      child: GeneralWidgets.textFieldWidget(
                          context, commentController,
                          isReadonly: post.review != null,
                          keyboardtyp: TextInputType.multiline,
                          maxLines: null,
                          minline: 4,
                          textAlign: TextAlign.start,
                          inputDecoration: InputDecoration(
                            labelText: getLables(post.review != null
                                ? lblReviews
                                : lblAddReview),
                            hintText: getLables(post.review != null
                                ? lblReviews
                                : lblAddReview),
                            focusedBorder:
                                DesignConfig.setOutlineInputBorder(grey),
                            enabledBorder:
                                DesignConfig.setOutlineInputBorder(grey),
                            border: DesignConfig.setOutlineInputBorder(grey),
                            errorMaxLines: 2,
                          ))),
                  if (post.review == null)
                    Padding(
                        padding: EdgeInsetsDirectional.symmetric(
                            horizontal: 12, vertical: 12),
                        child: GeneralWidgets.btnWidget(
                            context, getLables(lblSubmit), callback: () {
                          reviewAddProcess(
                              context, rates, commentController.text, post);
                        })),
                  SizedBox(height: 10),
                ],
              ),
            ));
  }

  reviewAddProcess(BuildContext context, double rate, String cmt, post) async {
    bool checkinternet = await GeneralMethods.checkInternet();
    if (!checkinternet) {
      GeneralMethods.showSnackBarMsg(
          context, getLables(noInternetErrorMessage));
      return;
    }
    Map<String, String> parameter = {
      ApiParams.appointmentId: post.id!.toString(),
      ApiParams.rating: rate.toString(),
      ApiParams.review: cmt,
    };
    try {
      GeneralWidgets.showLoader(context);
      var response = await Api.sendApiRequest(
          ApiParams.apiSetReview, parameter, true, context);
      GeneralWidgets.hideLoder(context);
      var getdata = json.decode(response);

      Navigator.of(context).pop();
      if (!getdata["error"] && callback != null) {
        post.review = Review.fromAppointment(getdata["data"]);

        callback!(index, post);
      }

      Future.delayed(Duration(milliseconds: 500), () {
        GeneralMethods.showSnackBarMsg(
            Constant.navigatorKey.currentContext, getdata[ApiParams.message]);
      });
    } catch (e) {
      GeneralWidgets.hideLoder(context);
    }
  }
}
