import 'package:flutter/material.dart';
import 'package:tabebi/helper/colors.dart';
import 'package:tabebi/helper/generaWidgets.dart';
import 'package:tabebi/helper/generalMethods.dart';
import 'package:tabebi/helper/stringLables.dart';

import 'notificationListPage.dart';

class NotificationDetailPage extends StatefulWidget {
  const NotificationDetailPage({Key? key}) : super(key: key);

  @override
  _NotificationDetailPageState createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralWidgets.setAppbar(getLables(lblNotifications), context),
      body: ListView(children: [
        if (selectedNotification!.image!.trim().isNotEmpty)
          GeneralWidgets.setNetworkImg(selectedNotification!.image),
        const SizedBox(height: 5),
        Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 8),
            child: contentWidget()),
      ]),
    );
  }

  contentWidget() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Text(
          selectedNotification!.createdAt!,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        selectedNotification!.title!,
        style:
            Theme.of(context).textTheme.titleMedium!.apply(color: primaryColor),
      ),
      const SizedBox(height: 5),
      Text(selectedNotification!.message!,
          style: Theme.of(context).textTheme.bodyMedium!),
    ]);
  }
}
