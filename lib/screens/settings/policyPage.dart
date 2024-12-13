import 'package:flutter/material.dart';
import 'package:tabebi/helper/colors.dart';
import 'package:tabebi/helper/generaWidgets.dart';
import 'package:tabebi/helper/generalMethods.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PolicyPage extends StatefulWidget {
  final String title;
  final String content;
  const PolicyPage({Key? key, required this.title, required this.content})
      : super(key: key);

  @override
  PolicyPageState createState() => PolicyPageState();
}

class PolicyPageState extends State<PolicyPage> {
  late WebViewController wbController;
  @override
  void initState() {
    super.initState();
    print("policy=>${widget.title}");
    wbController = WebViewController()
      ..enableZoom(false)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(pageBackgroundColor)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith("https://") ||
                request.url.startsWith("http://")) {
              launchUrl(Uri.parse(request.url),
                  mode: LaunchMode.externalApplication);
              return NavigationDecision.navigate;
            } else {
              return NavigationDecision.prevent;
            }
          },
        ),
      )
      ..loadHtmlString("""
      <!DOCTYPE html>
        <html>
          <head><meta name="viewport" content="width=device-width, initial-scale=1"></head>
          <body style='"margin: 0; padding: 0;'>
            ${widget.content}
          </body>
        </html>
      """);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralWidgets.setAppbar(getLables(widget.title), context),
      body: WebViewWidget(
        controller: wbController,
      ),
    );
  }
}
