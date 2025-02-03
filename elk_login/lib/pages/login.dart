import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
          onPressed: () {},
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
    http.Response? resp = await http.post(Uri.parse('http://10.22.45.42/login'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(
            <String, String>{'username': username, 'password': password}));
  }
}
