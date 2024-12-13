import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tabebi/helper/sessionManager.dart';
import 'package:tabebi/helper/stringLables.dart';
import '../app/routes.dart';
import '../helper/validator.dart';
import '../models/hospital.dart';
import '../models/lab.dart';
import '../models/labTest.dart';
import '../models/review.dart';
import '../screens/labAppointment/labListPage.dart';
import '../screens/mainHome/mainPage.dart';
import 'colors.dart';
import 'constant.dart';
import 'designConfig.dart';
import 'generalMethods.dart';
import 'readMoreText.dart';

class GeneralWidgets {
  static setImage(String image,
      {double? height,
      double? width,
      Color? imgColor,
      BoxFit boxFit = BoxFit.contain}) {
    return Image.asset(
      Constant.getImagePath(image),
      height: height,
      width: width,
      color: imgColor,
      fit: boxFit,
    );
  }

  static setSvg(String image,
      {double? height,
      double? width,
      Color? imgColor,
      BoxFit boxFit = BoxFit.contain}) {
    return SvgPicture.asset(
      Constant.getImagePath(image, issvg: true),
      height: height,
      width: width,
      colorFilter:
          imgColor == null ? null : ColorFilter.mode(imgColor, BlendMode.srcIn),
      fit: boxFit,
      placeholderBuilder: (context) {
        return Center(
            child: SvgPicture.asset(
          Constant.getImagePath("placeholder", issvg: true),
          height: height,
          width: width,
          fit: boxFit,
        ));
        //return Center(child: defaultImg(height, width, boxFit: boxFit));
      },
    );
  }

  static setSvgNetwork(String image,
      {double? height,
      double? width,
      Color? imgColor,
      BoxFit boxFit = BoxFit.contain}) {
    return SvgPicture.network(
      image,
      height: height,
      width: width,
      colorFilter:
          imgColor == null ? null : ColorFilter.mode(imgColor, BlendMode.srcIn),
      fit: boxFit,
      placeholderBuilder: (context) {
        return Center(
            child: SvgPicture.asset(
          Constant.getImagePath("placeholder", issvg: true),
          height: height,
          width: width,
          fit: boxFit,
        ));
        //return Center(child: defaultImg(height, width, boxFit: boxFit));
      },
    );
  }

  static defaultImg(double? height, double? width,
      {String image = "placeholder", BoxFit? boxFit}) {
    if (image.trim().isEmpty) {
      image = "placeholder";
    }
    return setSvg(
      image,
      width: width,
      height: height,
      boxFit: boxFit!,
    );
  }

  static fileImg(
    File imgfile, {
    BoxFit? boxFit,
    double height = 40,
    double width = 40,
  }) {
    return Image.file(
      imgfile,
      width: width,
      height: height,
      fit: boxFit,
    );
  }

  static setNetworkImg(String? murl,
      {double? height,
      double? width,
      Color? imgColor,
      BoxFit boxFit = BoxFit.contain,
      BoxFit? placeboxfit}) {
    String url = murl ??= "";
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: boxFit,
      placeholder: (context, url) => Center(
          child: defaultImg(height, width, boxFit: placeboxfit ??= boxFit)),
      errorWidget: (context, url, error) =>
          defaultImg(height, width, boxFit: placeboxfit ??= boxFit),
    );
    /*return Image.network(
      url,
      width: width,
      height: height,
      fit: boxFit,
      gaplessPlayback: true,
      errorBuilder:
          (BuildContext context, Object exception, StackTrace? stackTrace) {
        return defaultImg(height, width, boxFit: placeboxfit ??= boxFit);
      },
      loadingBuilder: (BuildContext context, Widget? child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) return child!;
        return Center(
            child: defaultImg(height, width, boxFit: placeboxfit ??= boxFit));
      },
    );*/
  }

  static showLoader(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            child: const Center(
              child: CircularProgressIndicator(),
            ),
            onWillPop: () {
              return Future(() => false);
            },
          );
        });
  }

  static hideLoder(BuildContext context) {
    Navigator.of(context).pop();
  }

  static textFieldWidget(BuildContext context, TextEditingController controller,
      {bool isReadonly = false,
      FocusNode? focusNode,
      VoidCallback? tapCallback,
      TextInputType? keyboardtyp = TextInputType.text,
      bool isSetValidator = true,
      List<TextInputFormatter>? setinputFormatters,
      String? errmsg,
      String? edtPrefixtext,
      Function? validationmsg,
      Function? onChangeInfo,
      InputDecoration? inputDecoration,
      TextStyle? textStyle,
      TextAlign textAlign = TextAlign.start,
      bool obscureText = false,
      TextInputAction? textInputAction,
      int? maxLines = 1,
      int? minline}) {
    errmsg ??= getLables(emptyValueMessage);
    return TextFormField(
      obscureText: obscureText,
      readOnly: isReadonly,
      focusNode: focusNode,
      onTap: tapCallback,
      maxLines: maxLines,
      minLines: minline,
      decoration: inputDecoration,
      textAlignVertical: TextAlignVertical.center,
      textInputAction: textInputAction,
      style: textStyle,
      keyboardType: keyboardtyp,
      controller: controller,
      inputFormatters: setinputFormatters,
      textAlign: textAlign,
      onChanged: (value) {
        if (onChangeInfo != null) {
          onChangeInfo(value);
        }
      },
      validator: (value) {
        if (isSetValidator) {
          if (validationmsg != null) {
            return validationmsg(value);
          }
          if (keyboardtyp == TextInputType.emailAddress) {
            return Validator.validateEmail(value);
          }
          if (keyboardtyp == TextInputType.phone) {
            return Validator.validatePhoneNumber(value);
          }
          if (value != null && value.toString().trim().isEmpty) {
            return errmsg;
          }
        }
        return null;
      },
    );
  }

  static btnWidget(BuildContext context, String title,
      {required Function callback,
      Color? bordercolor,
      Color? btncolor,
      Color? textcolor,
      double bradius = 5.0,
      double? bwidth = double.infinity,
      double? bheight = 45,
      TextStyle? textStyle}) {
    btncolor ??= primaryColor;
    bordercolor ??= btncolor;
    textcolor ??= Colors.white;
    textStyle ??= Theme.of(context).textTheme.titleMedium!.merge(TextStyle(
        color: textcolor, fontWeight: FontWeight.w500, letterSpacing: 0.5));
    return SizedBox(
      height: bheight,
      width: bwidth,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(bradius),
          ),
          foregroundColor: textcolor,
          backgroundColor: btncolor,
          side: BorderSide(color: bordercolor, width: 1),
        ),
        onPressed: () {
          callback();
        },
        child: Text(
          title,
          style: textStyle,
        ),
      ),
    );
  }

  static setAppbar(String title, BuildContext context,
      {Color? mappbarcolor,
      bool showBackBtn = true,
      List<Widget>? actions,
      double elevation = 4,
      double appbarheight = kToolbarHeight,
      Widget? leadingwidget,
      TextStyle? textStyle,
      Widget? titleWidget,
      PreferredSizeWidget? bottomwidget}) {
    Color iconcolor = Theme.of(context).colorScheme.primary;
    textStyle ??
        Theme.of(context)
            .textTheme
            .titleLarge!
            .merge(TextStyle(color: iconcolor));
    return AppBar(
      toolbarHeight: appbarheight,
      elevation: elevation,
      automaticallyImplyLeading: showBackBtn,
      systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark),
      backgroundColor: mappbarcolor ?? appbarColor,
      shadowColor: lightGrey,
      iconTheme: IconThemeData(color: iconcolor),
      leading: leadingwidget ??
          (Navigator.canPop(context)
              ? GestureDetector(
                  child: Icon(Icons.arrow_back_ios, color: iconcolor),
                  onTap: () {
                    // Navigator.pop(context);
                    Navigator.maybePop(context);
                  },
                )
              : null),
      title: titleWidget ??
          Text(
            title,
            style: textStyle,
          ),
      centerTitle: true,
      actions: actions,
      bottom: bottomwidget,
    );
  }

  static cardBoxWidget(
      {Widget? childWidget,
      EdgeInsetsDirectional? cmargin,
      double? celevation = 3,
      double cradius = 8.0,
      Color? cardcolor,
      Color? shadowcolor,
      RoundedRectangleBorder? cshape,
      EdgeInsetsDirectional? cpadding = EdgeInsetsDirectional.zero,
      GlobalKey? ckey}) {
    return Card(
        key: ckey,
        margin: cmargin,
        color: cardcolor ?? white,
        elevation: celevation,
        shadowColor: shadowcolor,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: cshape ??= RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cradius),
        ),
        child: Padding(padding: cpadding!, child: childWidget));
  }

  static setHeaderWidget(String cardInformation, BuildContext context) {
    return Text(
      cardInformation,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  static setListtileMenu(String title, BuildContext context,
      {Widget? leadingwidget,
      Function? onClickAction,
      Widget? trailingwidget,
      double? icontitlegap,
      TextStyle? textStyle,
      bool isdence = true,
      String desc = "",
      TextStyle? subtextstyle,
      ShapeBorder? shapeBorder,
      Color? tilecolor = Colors.white,
      VisualDensity? visualDensity,
      int? titleMaxline,
      TextOverflow? titleTextoverflow,
      EdgeInsetsGeometry? lcontentPadding,
      Widget? discwidget,
      Widget? titlwidget}) {
    textStyle ??= Theme.of(context).textTheme.titleMedium!.merge(TextStyle(
        color: black, fontWeight: FontWeight.w500, letterSpacing: 0.5));
    return Material(
      child: ListTile(
        leading: leadingwidget,
        contentPadding: lcontentPadding,
        trailing: trailingwidget,
        tileColor: tilecolor,
        horizontalTitleGap: icontitlegap,
        visualDensity: visualDensity,
        shape: shapeBorder,
        title: titlwidget != null
            ? titlwidget
            : Text(
                title,
                maxLines: titleMaxline,
                overflow: titleTextoverflow,
                style: textStyle,
              ),
        dense: isdence,
        subtitle: discwidget != null
            ? discwidget
            : desc.trim().isEmpty
                ? null
                : Text(
                    desc,
                    style: subtextstyle,
                  ),
        onTap: () {
          if (onClickAction != null) onClickAction();
        },
      ),
    );
  }

  static showPicker(BuildContext context) async {
    File? file = await showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: Text(getLables(lblphotolibrary)),
                    onTap: () async {
                      File? file = await imgFromGallery(ImageSource.gallery);
                      Navigator.of(context).pop(file);
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: Text(getLables(lblcamera)),
                  onTap: () async {
                    File? file = await imgFromGallery(ImageSource.camera);
                    Navigator.of(context).pop(file);
                  },
                ),
              ],
            ),
          );
        });
    return file;
  }

  static imgFromGallery(ImageSource imageSource) async {
    final pickedFile = await ImagePicker().pickImage(source: imageSource);
    File? file;
    if (pickedFile != null) {
      file = File(pickedFile.path);
    }
    return file;
  }

  static showAlertDialogue(BuildContext context, Widget? titleTxt,
      Widget? content, List<Widget>? actions,
      {EdgeInsets? cpadding}) {
    if (cpadding == null) {
      cpadding = EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0);
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: cpadding!,

          title: titleTxt,
          // titlePadding:
          //     const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          scrollable: true,
          content: content,
          actions: actions,
          actionsAlignment: actions!.length > 1
              ? MainAxisAlignment.spaceAround
              : MainAxisAlignment.center,
          elevation: 1.0,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
        );
      },
    );
  }

  static confirmActionBtn(
      BuildContext context, String btnText, VoidCallback onPressed) {
    return TextButton(
      //onPressed: onPressed, //() =>
      onPressed: () {
        Navigator.pop(context);
        onPressed();
      },
      child: Text(btnText),
    );
  }

  static cancelActionBtn(BuildContext context, String btnText) {
    return TextButton(
      child: Text(btnText),
      onPressed: () {
        //pop alert only
        Navigator.pop(context);
      },
    );
  }

  static Future<dynamic> showBottomSheet(
      {required Widget btmchild,
      required BuildContext context,
      bool? enableDrag,
      EdgeInsetsDirectional? bpadding}) async {
    final result = await showModalBottomSheet(
        enableDrag: enableDrag ?? false,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(DesignConfig.bottomSheetTopRadius),
                topRight: Radius.circular(DesignConfig.bottomSheetTopRadius))),
        context: context,
        builder: (context) => Padding(
            padding: bpadding ??
                EdgeInsetsDirectional.symmetric(
                    horizontal: MediaQuery.of(context).size.width * (0.075),
                    vertical: MediaQuery.of(context).size.height * (0.05)),
            child: btmchild));

    return result;
  }

  static msgWithTryAgain(String msg, Function callback, {String btnText = ""}) {
    if (btnText.trim().isEmpty) btnText = getLables(lblTryAgain);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            msg,
            textAlign: TextAlign.center,
          ),
          ElevatedButton(
              onPressed: () => callback(),
              child: Text(
                btnText,
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
    );
  }

  static searchWidget(
      TextEditingController edtSearch, BuildContext context, String lbl,
      {Function? onSearchTextChanged,
      FocusNode? focusnode,
      Function? tapCallback,
      Color? cardcolor,
      double verticalpadding = 3.0,
      EdgeInsetsDirectional? cardmargin,
      EdgeInsets? iconPadding}) {
    return GeneralWidgets.cardBoxWidget(
      celevation: 0,
      cradius: 5,
      cmargin: cardmargin,
      cardcolor: cardcolor,
      childWidget: Padding(
        padding: EdgeInsets.symmetric(vertical: verticalpadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 8),
            Expanded(
                child: TextField(
              controller: edtSearch,
              focusNode: focusnode,
              decoration: InputDecoration(
                  hintText: lbl,
                  border: InputBorder.none,
                  hintStyle: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: grey),
                  contentPadding: EdgeInsets.zero),
              onChanged: (value) {
                if (onSearchTextChanged != null) onSearchTextChanged(value);
              },
              onTap: () {
                if (tapCallback != null) tapCallback();
              },
            )),
            IconButton(
              padding: iconPadding,
              icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => RotationTransition(
                        turns: child.key == const ValueKey('icon1')
                            ? Tween<double>(begin: 1, end: 0).animate(anim)
                            : Tween<double>(begin: 0, end: 1).animate(anim),
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                  child: Icon(
                    edtSearch.text.trim().isEmpty ? Icons.search : Icons.clear,
                    size: edtSearch.text.trim().isEmpty ? 30 : 25,
                    key: ValueKey(
                        edtSearch.text.trim().isEmpty ? 'icon1' : 'icon2'),
                    color: Theme.of(context).colorScheme.primary,
                  )),
              onPressed: () {
                if (tapCallback != null) {
                  tapCallback();
                } else {
                  if (edtSearch.text.trim().isEmpty) return;
                  edtSearch.clear();
                  if (onSearchTextChanged != null) onSearchTextChanged('');
                }
              },
            )
          ],
        ),
      ),
    );
  }

  static circularImage(String? image,
      {double height = 40,
      double width = 40,
      BoxFit boxfit = BoxFit.fill,
      bool issvg = false,
      String? defaultimg}) {
    return ClipOval(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: image == null || image.trim().isEmpty
            ? defaultImg(height, width, boxFit: BoxFit.fill)
            : issvg
                ? setSvg(image, width: width, height: height, boxFit: boxfit)
                : setNetworkImg(image,
                    width: width,
                    height: height,
                    boxFit:
                        boxfit) /*Image.network(
                    image,
                    width: width,
                    height: height,
                    fit: boxfit,
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      return defaultImg(height, width, boxFit: boxfit);
                    },
                    loadingBuilder: (BuildContext context, Widget? child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child!;
                      return defaultImg(height, width, boxFit: boxfit);
                    },
                  )*/
        );
  }

  static textButtonWidget(
      bool isSelected, String title, BuildContext context, Function? callback,
      {EdgeInsetsGeometry? tpadding,
      Color? unselectedcolor = Colors.transparent}) {
    return TextButton(
      style: TextButton.styleFrom(
          shape: DesignConfig.setRoundedBorder(
            8,
            true,
            bordercolor: grey.withOpacity(0.1),
          ),
          backgroundColor: isSelected ? primaryColor : unselectedcolor,
          padding: tpadding ?? EdgeInsets.symmetric(horizontal: 10)),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .bodyMedium!
            .merge(TextStyle(color: isSelected ? Colors.white : textColor)),
      ),
      onPressed: () {
        if (callback != null) callback();
      },
    );
  }

  static citySelectionAppbarWidget(BuildContext context, String title,
      {bool isShowBottomHeader = false, Function? callback}) {
    Color iconcolor = Theme.of(context).colorScheme.primary;
    return PreferredSize(
      preferredSize: Size(double.infinity, kToolbarHeight),
      child: StreamBuilder<Object>(
          stream: currentUserCity!.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                (snapshot.data as bool) &&
                callback != null) {
              callback(isSetInitial: true);
            }
            return AppBar(
              elevation: isShowBottomHeader ? 0 : 4,
              systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarBrightness: Brightness.light,
                  statusBarIconBrightness: Brightness.dark),
              backgroundColor: appbarColor,
              shadowColor: lightGrey,
              iconTheme: IconThemeData(color: iconcolor),
              leading: (Navigator.canPop(context)
                  ? GestureDetector(
                      child: Icon(Icons.arrow_back_ios, color: iconcolor),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    )
                  : null),
              centerTitle: true,
              title: citySelection(context, title),
            );
          }),
    );
  }

  static citySelection(BuildContext context, String title) {
    return GestureDetector(
        onTap: () async {
          GeneralMethods.goToNextPage(Routes.selectProvincePage, context, false,
              args: false);
        },
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge!.merge(
                    TextStyle(color: Theme.of(context).colorScheme.primary)),
              ),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  getLables(searchingIn),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .merge(TextStyle(color: grey)),
                ),
                const SizedBox(width: 3),
                Text(
                  Constant.session!.getData(SessionManager.keyCityName),
                  style: Theme.of(context).textTheme.bodySmall!,
                ),
                const SizedBox(width: 5),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: primaryColor,
                )
              ])
            ]));
  }

  static Widget loadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  static offerWidget(BuildContext context, String offer,
      {EdgeInsetsDirectional? omargin}) {
    return Align(
      alignment: AlignmentDirectional.topEnd,
      child: Container(
        child: Text(
          "$offer%\n${getLables(lblOff)}",
          style:
              Theme.of(context).textTheme.bodySmall!.apply(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        alignment: AlignmentDirectional.center,
        width: 55,
        height: 45,
        padding: EdgeInsetsDirectional.only(start: 8),
        margin: omargin,
        decoration: DesignConfig.boxSpecificSide(primaryColor,
            bottomStart: 50, topEnd: 8),
      ),
    );
  }

  static RegExp doubleFormatRegex = RegExp(r'([.]*0)(?!.*\d)');
  static labProfileWidget(Lab labInfo, BuildContext context, bool isTestVisible,
      Function? callback) {
    return GeneralWidgets.cardBoxWidget(
      cpadding: EdgeInsetsDirectional.zero,
      childWidget: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding:
                    EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GeneralWidgets.circularImage(labInfo.image,
                        height: 60, width: 60),
                    const SizedBox(width: 15),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                          Text(
                            labInfo.name!,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .merge(
                                    TextStyle(fontWeight: FontWeight.normal)),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(color: textColor),
                              children: [
                                WidgetSpan(
                                  child: Icon(
                                    Icons.location_on,
                                    color: primaryColor,
                                    size: 18,
                                  ),
                                ),
                                TextSpan(
                                  text: "  ${labInfo.labAddress!}",
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (callback != null) callback();
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(color: textColor),
                                      children: [
                                        WidgetSpan(
                                          child: Icon(
                                            Icons.note_add,
                                            color: primaryColor,
                                            size: 18,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "  ${selectedTestIds.length}",
                                        ),
                                        TextSpan(
                                          text:
                                              "  ${getLables(lblTestSelected)}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(color: grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Icon(
                                  isTestVisible
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: primaryColor,
                                )
                              ],
                            ),
                          ),
                        ]))
                  ],
                ),
              ),
              selectedTestWidget(context, isTestVisible, callback),
              Divider(
                color: lightGrey.withOpacity(0.5),
                thickness: 2,
                height: 1,
              ),
              GeneralWidgets.setListtileMenu(getLables(lblTotalAmount), context,
                  textStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .apply(color: grey.withOpacity(0.7)),
                  discwidget: amtWidget(labInfo.totalTestAmt!,
                      labInfo.totalTestOfferAmt!, context)),
            ],
          ),
          if (labInfo.offer! > 0)
            GeneralWidgets.offerWidget(context,
                labInfo.offer!.toString().replaceAll(doubleFormatRegex, '')),
        ],
      ),
    );
  }

  static selectedTestWidget(
      BuildContext context, bool isTestVisible, Function? callback) {
    if (isTestVisible)
      return GestureDetector(
        onTap: () {
          if (callback != null) callback();
        },
        child: Column(
          children: List.generate(selectedTestIds.length, (index) {
            LabTest labtest =
                selectedTestIds[selectedTestIds.keys.elementAt(index)]!;
            return GeneralWidgets.cardBoxWidget(
              celevation: 0,
              cradius: 5,
              cardcolor: lightBg,
              cpadding:
                  EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 5),
              cmargin:
                  EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 5),
              childWidget: Row(children: [
                Expanded(
                    child: Text(
                  labtest.test!,
                  style: Theme.of(context).textTheme.titleMedium!,
                )),
                amtWidget(labtest.labAmount!, labtest.offerprice!, context),
              ]),
            );
          }),
        ),
      );
    else
      return SizedBox.shrink();
  }

  static amtWidget(double amount, double offeramt, BuildContext context) {
    return RichText(
        text: TextSpan(
            text: "$amount ${Constant.currencyCode}\t\t\t",
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .apply(color: primaryColor),
            children: [
          if (offeramt > 0)
            TextSpan(
              text: "$offeramt ${Constant.currencyCode}",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: grey.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  decorationStyle: TextDecorationStyle.solid,
                  decoration: TextDecoration.lineThrough),
            ),
        ]));
  }

  static aboutTextWidget(String abtinfo, BuildContext context,
      {int trimline = 10}) {
    return ReadMoreText(
      abtinfo,
      trimLines: trimline,
      colorClickableText: primaryColor,
      trimMode: TrimMode.Line,
      trimCollapsedText: ' ${getLables(lblReadmore)} ',
      trimExpandedText: ' ${getLables(lblReadless)} ',
      style: Theme.of(context).textTheme.bodyMedium!.apply(color: grey),
    );
  }

  static rateWidget(bool isdialog, Review review, BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      if (isdialog) const SizedBox(width: 20),
      GeneralWidgets.setSvg("rating", width: 15),
      const SizedBox(width: 8),
      Text(
        review.rate!,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ]);
  }

  static rateReviewCountWidget(
      BuildContext context, String totalrate, String totalReviews) {
    return RichText(
      text: TextSpan(
        style:
            Theme.of(context).textTheme.bodySmall!.copyWith(color: textColor),
        children: [
          WidgetSpan(
            child: GeneralWidgets.setSvg("rating", width: 15),
          ),
          TextSpan(
            text: "  $totalrate",
          ),
          TextSpan(
            text: "  -  $totalReviews ${getLables(lblReviews)}",
          ),
        ],
      ),
    );
  }

  static reviewListItemWidget(Review review, int? mline,
      TextOverflow? textOverflow, BuildContext context,
      {Function? reviewDetailDialog}) {
    bool isdialog = mline == null;
    return GestureDetector(
      onTap: () {
        if (!isdialog) {
          reviewDetailDialog!(review);
        }
      },
      child: Container(
        width: isdialog
            ? MediaQuery.of(context).size.width / 1.6
            : MediaQuery.of(context).size.width / 1.3,
        decoration: DesignConfig.boxDecoration(
            isdialog ? Colors.transparent : lightBg, 5),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                GeneralWidgets.circularImage(review.image,
                    height: 50, width: 50),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.name!,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                  //review.createdDate!,
                                  review.displaydays!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .apply(color: grey)),
                            ),
                            if (isdialog)
                              GeneralWidgets.rateWidget(
                                  isdialog, review, context),
                          ],
                        ),
                      ]),
                ),
                if (!isdialog) Spacer(),
                if (!isdialog)
                  GeneralWidgets.rateWidget(isdialog, review, context)
              ]),
              SizedBox(height: isdialog ? 5 : 2),
              Text(
                review.comment!,
                maxLines: mline,
                overflow: textOverflow,
                style: TextStyle(color: grey),
              )
            ]),
      ),
    );
  }

  static statusWidget(Map statusinfo, BuildContext context) {
    return Row(children: [
      Text(
        getLables(lblStatus) + " :",
        style: TextStyle(color: primaryColor),
      ),
      const SizedBox(width: 10),
      Expanded(
          child: Text(
        getLables(statusinfo["lbl"]),
        style: TextStyle(color: statusinfo["color"]),
      ))
    ]);
  }

  static hospitalWidget(Hospital post, BuildContext context) {
    return InkWell(
        onTap: () {
          GeneralMethods.goToNextPage(Routes.hospitalDetailPage, context, false,
              args: {"hospital": post, "hospitalId": post.id!.toString()});
        },
        child: IgnorePointer(
            ignoring: true,
            child: GeneralWidgets.cardBoxWidget(
                celevation: 10,
                shadowcolor: lightGrey,
                childWidget: Column(children: [
                  setDrInfo(
                    context,
                    post.name!,
                    Row(children: [
                      Icon(
                        Icons.location_on,
                        color: primaryColor,
                        size: 15,
                      ),
                      Expanded(
                        child: Text(post.address!),
                      )
                    ]),
                    titlestyle: Theme.of(context).textTheme.bodyMedium!,
                    lead: GeneralWidgets.circularImage(post.image),
                  ),
                  Divider(
                    thickness: 0.7,
                    indent: 15,
                    endIndent: 15,
                  ),
                  Row(children: [
                    Expanded(
                        child: setDrInfo(
                      context,
                      "",
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 25),
                        child: Text(
                          "${post.noOfSpecialist!} ${getLables(lblSpecialties)}",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                      titlewid: Row(children: [
                        GeneralWidgets.setSvg("specialities",
                            width: 16, height: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            getLables(lblSpecialties),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .apply(color: grey),
                          ),
                        )
                      ]),
                    )),
                    Expanded(
                        child: setDrInfo(
                      context,
                      "",
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 25),
                        child: Text(
                          "${post.noOfDoctor!} ${getLables(lblDoctors)}",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                      titlewid: Row(children: [
                        GeneralWidgets.setSvg("available_doctor",
                            width: 15, height: 15),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            getLables(lblAvailableDoctors),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .apply(color: grey),
                          ),
                        )
                      ]),
                    )),
                  ])
                ]))));
  }

  static setDrInfo(
    BuildContext context,
    String title,
    Widget discwid, {
    Widget? titlewid,
    Widget? lead,
    TextStyle? titlestyle,
  }) {
    return GeneralWidgets.setListtileMenu(title, context,
        discwidget: discwid,
        leadingwidget: lead,
        titlwidget: titlewid,
        textStyle: titlestyle);
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class AlwaysEnabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => true;
}
