import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:lilactest/api_service.dart';
import 'package:lilactest/otp_verification.dart';

class PhoneLoginScreen extends StatefulWidget {
  @override
  _PhoneLoginScreenState createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String countryCode = "+91"; // Default country code

  void sendOtp() async {
    String fullPhoneNumber = "$countryCode${phoneController.text}";

    try {
      await ApiService.sendOtp(fullPhoneNumber);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(phone: fullPhoneNumber),
        ),
      );
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Enter your phone number",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            IntlPhoneField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Enter phone number',
                border: OutlineInputBorder(),
              ),
              initialCountryCode: 'IN',
              onChanged: (phone) {
                setState(() {
                  countryCode = phone.countryCode; // Update country code
                });
                print("Full Number: ${phone.completeNumber}");
              },
            ),
            Text('Fliq will send you a verification code'),
            Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              width: double.infinity,
              color: Colors.white,
              child: ElevatedButton(
                onPressed: sendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[300],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
