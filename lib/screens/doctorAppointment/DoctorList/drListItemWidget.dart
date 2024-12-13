import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../helper/colors.dart';
import '../../../helper/constant.dart';
import '../../../helper/designConfig.dart';
import '../../../helper/generaWidgets.dart';
import '../../../helper/generalMethods.dart';
import '../../../helper/stringLables.dart';
import '../../../models/doctor.dart';

class DrListItemWidget extends StatelessWidget {
  final Doctor post;
  final bool isDisplayHospital;
  const DrListItemWidget(
      {Key? key, required this.post, required this.isDisplayHospital})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return doctorWidget(post, context);
  }

  doctorWidget(Doctor post, BuildContext context) {
    return GestureDetector(
        onTap: () {
          print("click");
          GeneralMethods.goToNextPage(Routes.doctorDetailPage, context, false,
              args: {"doctor": post, "drId": post.id.toString()});
        },
        child: GeneralWidgets.cardBoxWidget(
          celevation: 10,
          shadowcolor: lightGrey,
          cpadding: const EdgeInsetsDirectional.symmetric(
              horizontal: 12, vertical: 12),
          childWidget: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                drProfileWidget(post, context),
                Divider(
                  color: lightGrey.withOpacity(0.5),
                  height: 30,
                  thickness: 2,
                ),
                otherDrInfoWidget(post, context),
                if (isDisplayHospital && post.hospital != null)
                  Divider(
                    color: lightGrey.withOpacity(0.5),
                    height: 30,
                    thickness: 2,
                  ),
                if (isDisplayHospital && post.hospital != null)
                  hospitalWidget(post, context)
              ]),
        ));
  }

  hospitalWidget(Doctor doctor, BuildContext context) {
    return Row(children: [
      GeneralWidgets.circularImage(doctor.hospital!.image,
          height: 50, width: 50),
      const SizedBox(width: 15),
      Expanded(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(
              doctor.hospital!.name!,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 3),
            Text(doctor.hospital!.address!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    Theme.of(context).textTheme.bodySmall!.apply(color: grey)),
          ]))
    ]);
  }

  drProfileWidget(Doctor post, BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.max, children: [
      GeneralWidgets.circularImage(post.image, height: 60, width: 60),
      const SizedBox(width: 15),
      Expanded(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Constant.session!.getCurrLangCode() ==
                        Constant.arabicLanguageCode
                    ? post.nameAr!
                    : post.nameEng!,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .merge(TextStyle(fontWeight: FontWeight.normal)),
              ),
              Text(
                post.totalAppointments! + " ${getLables(lblAppointments)}",
                style:
                    Theme.of(context).textTheme.bodyMedium!.apply(color: grey),
              ),
              const SizedBox(height: 5),
              GeneralWidgets.rateReviewCountWidget(
                  context, post.rates!, post.totalReviews!),
              /*Row(children: [
                GeneralWidgets.setSvg("rating"),
                const SizedBox(width: 8),
                Text(post.rates!),
                const SizedBox(width: 8),
                Text("-  ${post.totalReviews!} ${getLables(lblReviews)}"),
              ]),*/
            ]),
      )
    ]);
  }

  otherDrInfoWidget(Doctor post, BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          drInfoWidget(
              "specialities",
              Constant.session!.getCurrLangCode() == Constant.arabicLanguageCode
                  ? post.drInfoAr!
                  : post.drInfoEng!),
          heightWidget(),
          drInfoWidget("address", post.drAddress!),
          heightWidget(),
          drInfoWidget("fees",
              "${getLables(lblFees)}:  ${post.drFees!} ${Constant.currencyCode}"),
          heightWidget(),
          if (post.schedulelist!.isNotEmpty) availibilityWidget(post, context),
        ]);
  }

  availibilityWidget(Doctor doctor, BuildContext context) {
    if (doctor.schedulelist!.first.startTime == null ||
        doctor.schedulelist!.first.startTime!.trim().isEmpty)
      return SizedBox.shrink();
    else
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          drInfoWidget("waitingtime",
              "${getLables(lblWaitingTime)}:  ${doctor.schedulelist!.first.waitingTime}"),
          heightWidget(),
          Row(
            children: [
              Container(
                height: 37,
                padding: EdgeInsets.symmetric(horizontal: 8),
                alignment: AlignmentDirectional.center,
                decoration: DesignConfig.boxDecoration(
                    primaryColor.withOpacity(0.1), 5),
                child: RichText(
                    text: TextSpan(
                        text: "${getLables(lblAvailableFrom)}\t\t\t\t\t\t",
                        style: TextStyle(color: grey),
                        children: [
                      TextSpan(
                        text: DateFormat.jm(Constant.session!.getCurrLangCode())
                            .format(Constant.timeParserSecond
                                .parse(doctor.schedulelist!.first.startTime!)),
                        style: TextStyle(color: primaryColor),
                      ),
                    ])),
              ),
              const Spacer(),
              Container(
                width: 90,
                height: 35,
                alignment: AlignmentDirectional.center,
                decoration: DesignConfig.boxDecoration(primaryColor, 5),
                child: Text(
                  getLables(lblBook),
                  style: TextStyle(
                      color: white, height: 1, fontWeight: FontWeight.w500),
                ),
              ),
              /*  GeneralWidgets.btnWidget(context, getLables(lblBook),
                bwidth: 90, bheight: 35, callback: () {}), */
            ],
          ),
        ],
      );
  }

  drInfoWidget(String image, String info) {
    return Row(mainAxisSize: MainAxisSize.max, children: [
      GeneralWidgets.setSvg(image, width: 17),
      const SizedBox(width: 8),
      Expanded(child: Text(info, maxLines: 1, overflow: TextOverflow.ellipsis)),
    ]);
  }

  heightWidget() {
    return SizedBox(height: 12);
  }
}
