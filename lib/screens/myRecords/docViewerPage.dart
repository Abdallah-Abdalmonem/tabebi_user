import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:tabebi/helper/colors.dart';
import 'package:tabebi/helper/constant.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../helper/generaWidgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class DocViewerPage extends StatefulWidget {
  final String url;
  const DocViewerPage({Key? key, required this.url}) : super(key: key);

  @override
  DocViewerPageState createState() => DocViewerPageState();
}

class DocViewerPageState extends State<DocViewerPage> {
  WebViewController? controller;
  Color bgcolor = const Color(0x00000000);
  String mainurl = "";
  bool isImage = false;
  bool isSvg = false;
  File? pdffile;
  List<String> doctype = [
    ".pdf",
    ".doc",
    ".docx",
    ".pptx",
    ".ppt",
    ".csv",
    ".xlsx",
    ".xls",
    ".txt",
    ".wpd"
  ];
  @override
  void initState() {
    super.initState();
    mainurl = widget.url;
    String filetype = mainurl.split('.').last.toLowerCase();

    isImage = Constant.imagetypelist.contains(filetype);
    isSvg = filetype == "svg";
    if (filetype == "pdf") {
      loadPdfConfigs();
    } else if (!isImage && !isSvg) {
      setWebviewConfig();
    }
  }

  setWebviewConfig() {
    mainurl = doctype.contains(".${mainurl.split('.').last.toLowerCase()}")
        ? 'https://docs.google.com/gview?embedded=true&url=$mainurl'
        : mainurl;
    //print("url====${doctype.contains(".${mainurl.split('.').last.toLowerCase()}")}");
    print("url=?$mainurl");
    Future.delayed(Duration.zero, () {
      GeneralWidgets.showLoader(context);
    });
    controller = WebViewController.fromPlatformCreationParams(
        const PlatformWebViewControllerCreationParams());
    controller!
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(bgcolor)
      ..loadRequest(Uri.parse(mainurl))
      ..clearCache()
      ..setNavigationDelegate(
        NavigationDelegate(
          /*onNavigationRequest: (request) {
            print("url-->**=${request.url}");
            if (request.url.endsWith('.pdf')) {
              GeneralWidgets.hideLoder(context);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },*/
          onWebResourceError: (error) {
            print("error=>${error.description}");
            print("error=>**${error.errorType}");
            GeneralWidgets.hideLoder(context);
          },
          onPageFinished: (String url) {
            GeneralWidgets.hideLoder(context);
          },
        ),
      ).catchError((e) {
        print("error=>${e.toString()}");
      });
  }

  Future<void> loadPdfConfigs() async {
    Future.delayed(Duration.zero, () {
      GeneralWidgets.showLoader(context);
    });
    var url = widget.url;
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;
    final filename = path.basename(url);
    final dir = await getApplicationDocumentsDirectory();
    var file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    setState(() {
      pdffile = file;
    });

    GeneralWidgets.hideLoder(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: Platform.isIOS,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: bgcolor,
        body: Padding(
          padding: EdgeInsetsDirectional.only(
              top: MediaQuery.of(context).padding.top),
          child: Stack(
            alignment: Alignment.center,
            children: [
              isImage
                  ? GeneralWidgets.setNetworkImg(widget.url)
                  : isSvg
                      ? GeneralWidgets.setSvgNetwork(widget.url)
                      : controller != null
                          ? WebViewWidget(
                              controller: controller!,
                            )
                          : pdffile != null
                              ? PDFView(
                                  filePath: pdffile!.path,
                                )
                              : SizedBox.shrink(),
              Align(
                alignment: AlignmentDirectional.topStart,
                child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.clear,
                      color: white,
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
