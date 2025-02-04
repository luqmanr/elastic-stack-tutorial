import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:html';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                _forgotPassword(context),
                _signup(context),
              ],
            ),
          )
        ],
      ),
    );
  }

  _header(context) {
    return Column(
      children: [
        Image(
          image: AssetImage('images/commonroom-logo.png'),
          width: MediaQuery.of(context).size.width * 0.3,
        ),
        // SvgPicture.asset(
        //   './images/commonroom-logo.svg',
        //   colorFilter: const ColorFilter.mode(
        //       Color.fromARGB(255, 26, 2, 0), BlendMode.srcIn),
        //   width: 400,
        // ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        const Text(
          "Welcome to CO-LABS Weather Dashboard",
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
    try {
      final Uri uri = Uri.parse('https://dashboard.weather.id/loginv2');

      final http.Response resp = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
            <String, String>{'username': username, 'password': password}),
      );

      print(
          "Status Code: ${resp.statusCode}"); // Important: Check the status code

      final respJson = jsonDecode(resp.body) as Map<String, dynamic>;
      print("resp.body $respJson}");

      document.cookie = "sid=${respJson['sid']}";

      if (resp.statusCode == 200 ||
          resp.statusCode == 301 ||
          resp.statusCode == 302 ||
          resp.statusCode == 307 ||
          resp.statusCode == 308) {
        // Redirect occurred.  The 'location' header contains the redirect URL.
        print("response headers: ${resp.headers}");
        String? redirectUrl = resp.headers['location'];
        if (redirectUrl != null) {
          print("Redirecting to: $redirectUrl");

          //Option 1:  Manually follow the redirect (if you need more control)
          final http.Response redirectResponse =
              await http.get(Uri.parse(redirectUrl));
          print("Redirect Response: ${redirectResponse.statusCode}");
          print("Redirect Body: ${redirectResponse.body}");

          //Option 2: Let http handle it (usually the best way). http already did follow the redirect.
          print("Final URL: ${resp.request?.url}"); //Access the final url

          // Process the redirectResponse or just the resp, depending on your need
          if (redirectResponse.statusCode == 200) {
            //Do what you have to do
          } else {
            // Handle error
          }
        } else {
          print("Redirect but no 'location' header found.");
          print("Redirecting to: https://dashboard.weather.id");

          //Option 1:  Manually follow the redirect (if you need more control)
          // final http.Response redirectResponse =
          //     await http.get(Uri.parse("https://dashboard.weather.id"));

          await launchUrl(
            Uri.parse("https://dashboard.weather.id"),
            webOnlyWindowName: '_self',
          );
          // print("Redirect Response: ${redirectResponse.statusCode}");
          // print("Redirect Body: ${redirectResponse.body}");

          // //Option 2: Let http handle it (usually the best way). http already did follow the redirect.
          // print("Final URL: ${resp.request?.url}"); //Access the final url

          // // Process the redirectResponse or just the resp, depending on your need
          // if (redirectResponse.statusCode == 200) {
          //   //Do what you have to do
          // } else {
          //   // Handle error
          // }
        }
      } else {
        // Other error codes (e.g., 400, 401, 500)
        print("Login Failed: ${resp.statusCode} - ${resp.body}");
      }
    } catch (e) {
      print("Error during login: $e");
    }
  }
}
