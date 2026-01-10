
import 'package:flutter/material.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/myconfig.dart';

import 'package:webview_flutter/webview_flutter.dart';

class DonationPage extends StatefulWidget {
  final User user;
  final int credits;
  const DonationPage({super.key, required this.user, required this.credits});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {

  final mainPink = const Color.fromRGBO(215, 54, 138, 1);
  final midPink = const Color.fromRGBO(245, 154, 185, 1); 
  
  late WebViewController _webcontroller;
  late double screenHeight, screenWidth, resWidth;
  late String userName, userEmail, userPhone, userID;

  @override
  void initState() {
    userEmail = widget.user.user_email.toString();
    userPhone = widget.user.user_phone.toString();
    userName = widget.user.user_name.toString();

    userID = widget.user.user_id.toString();
    super.initState();
    _webcontroller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(
          '${MyConfig.baseUrl}/pawpal/api/donation.php?email=$userEmail&phone=$userPhone&userid=$userID&name=$userName&credits=${widget.credits}',
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment"),
        backgroundColor: mainPink,
      ),
      body: WebViewWidget(controller: _webcontroller),
    );
  }
}
