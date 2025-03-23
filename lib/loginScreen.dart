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
  String countryCode = "+91";

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
              "Enter your phone \n number",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            IntlPhoneField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Enter phone number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              initialCountryCode: 'IN',
              onChanged: (phone) {
                setState(() {
                  countryCode = phone.countryCode;
                });
                print("Full Number: ${phone.completeNumber}");
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Fliq will send you a text with a verification code.'),
              ],
            ),
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
