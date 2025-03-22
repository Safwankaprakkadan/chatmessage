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
            "assets/images/datingImage.jpg",
            fit: BoxFit.cover,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              // Image.asset("assets/images/logo.png", height: 60),
              SizedBox(height: 20),
              Text(
                "Connect. Meet. Love.\nWith Fliq Dating",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Spacer(),
              _buildLoginButton("Sign in with Google", Colors.black, "google", context),
              _buildLoginButton("Sign in with Facebook", Colors.blue, "facebook", context),
              _buildLoginButton("Sign in with phone number", Colors.orange, "phone", context),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "By signing up, you agree to our Terms & Privacy Policy.",
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
            Icon(method == "google" ? Icons.g_mobiledata : method == "facebook" ? Icons.facebook : Icons.phone, color: Colors.white),
            SizedBox(width: 10),
            Text(text, style: TextStyle(fontSize: 16, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
