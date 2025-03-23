import 'package:flutter/material.dart';
import 'package:lilactest/loginScreen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/images/dateAppbg.png",
            fit: BoxFit.cover,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 60),
              Image.asset("assets/images/images.png", height: 60),
              Text(
                "Connect. Meet. Love.\nWith Fliq Dating",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Spacer(),
              _buildLoginButton("Sign in with Google", Colors.white, "google", context),
              _buildLoginButton("Sign in with Facebook", const Color.fromARGB(255, 43, 84, 132), "facebook", context),
              _buildLoginButton("Sign in with phone number", Colors.pink, "phone", context),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "By signing up, you agree to our Terms. See how we use your data in our Privacy Policy.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(String text, Color color, String method, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: () {
          if (method == "phone") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PhoneLoginScreen()),
            );
          } else {
            print("Login with $method");
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (method == "google")
              Image.asset(
                "assets/images/google.png", 
                height: 24,
                width: 24,
              ),
              Image.asset(
                method == "facebook"
                    ? "assets/images/Facebook_logo.png"
                    : "assets/images/phone.png", 
                height: 24,
                width: 24,
              ),
            SizedBox(width: 10),
            Text(text, style: TextStyle(fontSize: 16, color: method == "google" ? Colors.black : Colors.white)),
          ],
        ),
      ),
    );
  }
}