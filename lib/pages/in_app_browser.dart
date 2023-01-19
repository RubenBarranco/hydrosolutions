import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MyInAppBrowser extends InAppBrowser {
  MyInAppBrowser(
      {int? windowId, UnmodifiableListView<UserScript>? initialUserScripts})
      : super(windowId: windowId, initialUserScripts: initialUserScripts);

  @override
  Future onBrowserCreated() async {
    print("\n\nBrowser Created!\n\n");
  }

  @override
  Future onLoadStart(url) async {}

  @override
  Future onLoadStop(url) async {
    pullToRefreshController?.endRefreshing();
  }

  /*@override
  Future<PermissionResponse> onPermissionRequest(request) async {
    return PermissionRequestResponse(
        resources: request.resources, action: PermissionResponseAction.GRANT);
  }*/

  @override
  void onLoadError(url, code, message) {
    pullToRefreshController?.endRefreshing();
  }

  @override
  void onProgressChanged(progress) {
    if (progress == 100) {
      pullToRefreshController?.endRefreshing();
    }
  }

  @override
  void onExit() {
    print("\n\nBrowser closed!\n\n");
  }

  @override
  Future<NavigationActionPolicy> shouldOverrideUrlLoading(
      navigationAction) async {
    print("\n\nOverride ${navigationAction.request.url}\n\n");
    return NavigationActionPolicy.ALLOW;
  }
}

class InAppBrowserExampleScreen extends StatefulWidget {
  final MyInAppBrowser browser = new MyInAppBrowser();

  @override
  _InAppBrowserExampleScreenState createState() =>
      new _InAppBrowserExampleScreenState();
}

class _InAppBrowserExampleScreenState extends State<InAppBrowserExampleScreen> {
  PullToRefreshController? pullToRefreshController;

  launchWeb() async {
    await widget.browser.openUrlRequest(
      urlRequest: URLRequest(url: Uri.parse("http://app.hydrosolutions.es/")),
      options: InAppBrowserClassOptions(
        crossPlatform: InAppBrowserOptions(
          toolbarTopBackgroundColor: Colors.blue,
          hideToolbarTop: true,
          hideUrlBar: true,
        ),
      ),
    );
  }

  @override
  void initState() {
    launchWeb();
    super.initState();

    pullToRefreshController = kIsWeb ||
            ![TargetPlatform.iOS, TargetPlatform.android]
                .contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            options: PullToRefreshOptions(
              color: Colors.black,
            ),
            onRefresh: () async {
              if (Platform.isAndroid) {
                widget.browser.webViewController?.reload();
              } else if (Platform.isIOS) {
                widget.browser.webViewController?.loadUrl(
                    urlRequest: URLRequest(
                        url: await widget.browser.webViewController?.getUrl()));
              }
            },
          );
    widget.browser.pullToRefreshController = pullToRefreshController;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/drivi.png"),
                  fit: BoxFit.fitWidth),
            ),
            child: CircularProgressIndicator()),
      ),
    );
  }
}
