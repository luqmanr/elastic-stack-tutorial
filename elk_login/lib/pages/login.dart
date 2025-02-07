import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';

import 'dart:html';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final cookieManager = WebviewCookieManager();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String errorMsg = '';
  String errorStatus = '';

  @override
  void initState() {
    super.initState();
    _initCheckCookies();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  _initCheckCookies() async {
    try {
      final response = await http.get(Uri.parse("${Uri.base.origin}"));
      // print("response check cookies: $response");
      // print("response check cookies status code: ${response.statusCode}");
      // print("response check cookies body: ${response.body}");
      if (response.body.toLowerCase().contains("please upgrade your browser")) {
        launchUrl(
          Uri.parse("${Uri.base.origin}"),
          webOnlyWindowName: '_self',
        );
      }
    } catch (e) {
      // print("error check cookies: ${e}");
    }
  }

  // _initCheckCookies() async {
  //   var cookie = document.cookie!;
  //   final entity = cookie.split("; ").map((item) {
  //     final split = item.split("=");
  //     return MapEntry(split[0], split[1]);
  //   });
  //   final cookieMap = Map.fromEntries(entity);
  //   // print("cookiesmap: $cookieMap - $cookie - ${document.cookie.toString()}");
  //   if (Uri.base.query.toLowerCase().contains("logged_out") ||
  //       // !cookieMap.containsKey('sid') ||
  //       (cookieMap.containsKey('sid') && cookieMap['sid']!.length == 0) ||
  //       ('$cookieMap' == '{: null}')) {
  //     // print("we should be logged out");
  //     final Uri uri = Uri.parse('https://dashboard.weather.id/logout/internal');

  //     final http.Response resp = await http.post(
  //       uri,
  //       headers: <String, String>{
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode(<String, String>{}),
  //     );
  //     // print("${document.cookie.toString()}");
  //     // launchUrl(
  //     //   Uri.parse("${Uri.base.origin}"),
  //     //   webOnlyWindowName: '_self',
  //     // );
  //   } else {
  //     // print("we aren't logged out, continue");
  //     launchUrl(
  //       Uri.parse("${Uri.base.origin}"),
  //       webOnlyWindowName: '_self',
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        children: [
          _header(context),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          Container(
            width: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _inputField(context),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                (errorMsg.length > 0)
                    ? _errBox(context)
                    : SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05),
                _forgotPassword(context),
                _signup(context),
              ],
            ),
          )
        ],
      ),
    );
  }

  _errBox(context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.08,
          width: MediaQuery.of(context).size.width * 0.2,
          color: Color.fromARGB(255, 255, 56, 73),
          padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(
              errorMsg,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Text(
              errorStatus,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ]),
        ));
  }

  _header(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            // SvgPicture.asset(
            //   './images/kerjasama-jerman-logo.svg',
            //   // colorFilter: const ColorFilter.mode(
            //   //     Color.fromARGB(255, 26, 2, 0), BlendMode.srcIn),
            //   // width: MediaQuery.of(context).size.width * 0.15,
            //   width: 250,
            // ),
            Image(
              image: AssetImage('images/kerjasama-jerman-logo.png'),
              width: MediaQuery.of(context).size.height * 0.25,
            ),
            Image(
              image: AssetImage('images/giz-logo.png'),
              width: MediaQuery.of(context).size.height * 0.25,
            ),
            Image(
              image: AssetImage('images/bappenas-logo-2.png'),
              width: MediaQuery.of(context).size.height * 0.25,
            ),
            Image(
              image: AssetImage('images/commonroom-logo.png'),
              width: MediaQuery.of(context).size.height * 0.3,
            ),
            Image(
              image: AssetImage('images/co_labs-logo.png'),
              width: MediaQuery.of(context).size.height * 0.3,
            ),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        const Text(
          "Welcome to CO-LABS Weather Dashboard",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        // Text("Enter your credential to login"),
      ],
    );
  }

  _inputField(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          onSubmitted: (val) {
            _loginSubmit(usernameController.text, passwordController.text);
          },
          autofillHints: [AutofillHints.username],
          controller: usernameController,
          decoration: InputDecoration(
              hintText: "Username",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none),
              fillColor: Color(0xff0093BB).withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(Icons.person)),
        ),
        const SizedBox(height: 10),
        TextField(
          onSubmitted: (val) {
            _loginSubmit(usernameController.text, passwordController.text);
          },
          autofillHints: [AutofillHints.password],
          controller: passwordController,
          decoration: InputDecoration(
            hintText: "Password",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none),
            fillColor: Color(0xff0093BB).withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.password),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            await _loginSubmit(
                usernameController.text, passwordController.text);
          },
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Color(0xff0093BB),
          ),
          child: const Text(
            "Login",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        )
      ],
    );
  }

  _forgotPassword(context) {
    return TextButton(
      onPressed: () {},
      child: const Text(
        "Forgot password?",
        style: TextStyle(color: Color(0xff0093BB)),
      ),
    );
  }

  _signup(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Dont have an account? "),
        TextButton(
            onPressed: () {},
            child: const Text(
              "Sign Up",
              style: TextStyle(color: Color(0xff0093BB)),
            ))
      ],
    );
  }

  _loginSubmit(String username, String password) async {
    if (password.length == 0 && username.length == 0) {
      setState(() {
        errorMsg = 'please fill in your login details';
      });
      return;
    } else if (password.length == 0) {
      setState(() {
        errorMsg = 'password is empty!';
      });
      return;
    } else if (username.length == 0) {
      setState(() {
        errorMsg = 'username is empty!';
      });
      return;
    }
    try {
      // final Uri uri = Uri.parse('http://127.0.0.1:8123/login/v2');
      // print("current url: ${Uri.base.origin} - ${window.location.href}");
      final Uri uri = Uri.parse('https://dashboard.weather.id/login/v2');

      final http.Response resp = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
          'origin': "${Uri.base.origin}"
        }),
      );

      // print("Status Code: ${resp.statusCode}"); // Important: Check the status code

      final respJson = jsonDecode(resp.body) as Map<String, dynamic>;
      print("resp.status ${resp.statusCode}");
      if (resp.statusCode == 401) {
        // unauthorized
        setState(() {
          errorMsg = 'invalid credentials';
          errorStatus = '401';
        });
        return;
      } else if ((resp.statusCode != 200) && (resp.statusCode != 400)) {
        // internal server error
        setState(() {
          errorMsg = 'internal server error';
          errorStatus = '500';
        });
        return;
      }

      setState(() {
        errorMsg = '';
        errorStatus = '';
      });

      // Redirect occurred.  The 'location' header contains the redirect URL.
      // print("response headers: ${resp.headers}");
      // document.cookie = "sid=${respJson['sid']}";
      // print(
      //     "current cookies: $document.cookie, ${cookieManager.getCookies(Uri.base.origin)}");
      String? redirectUrl = respJson['location'];
      if (redirectUrl == null) {
        // redirect to the samepage
        await launchUrl(
          Uri.parse("${Uri.base.origin}"),
          webOnlyWindowName: '_self',
        );
      }
      await launchUrl(
        Uri.parse(redirectUrl!),
        webOnlyWindowName: '_self',
      );
    } catch (e) {
      // treat the same as error 500
      // print("Error during login: $e");
      setState(() {
        errorMsg = 'internal server error';
        errorStatus = '500';
      });
    }
  }
}
