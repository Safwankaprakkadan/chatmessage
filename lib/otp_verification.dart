import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'chat_list_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  OtpVerificationScreen({required this.phone});

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;

  void verifyOtp() async {
    if (otpController.text.length == 6) {
      setState(() => isLoading = true);

      try {
        String? token = await ApiService.verifyOtp(
          widget.phone,
          otpController.text,
        );

        if (token != null) {
          print("Token received: $token");

          try {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('auth_token', token);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ChatListScreen(token: token),
              ),
            );
          } catch (e) {
            print("Error initializing SharedPreferences: $e");
          }
        } else {
          print("Failed to get token");
        }
      } catch (e) {
        print("Error: $e");
      } finally {
        setState(() => isLoading = false);
      }
    } else {
      print("Please enter a valid 6-digit OTP");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Enter your verification \n code",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(widget.phone),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, widget.phone);
                  },
                  child: Text('Edit', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
            SizedBox(height: 15),
            PinCodeTextField(
              appContext: context,
              length: 6,
              controller: otpController,
              keyboardType: TextInputType.number,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(10),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.white,
                inactiveFillColor: Colors.grey[200]!,
                selectedFillColor: Colors.pink[100]!,
                activeColor: Colors.pink[300],
                inactiveColor: Colors.grey,
                selectedColor: Colors.pink[400],
              ),
              enableActiveFill: true,
              onCompleted: (value) {
                print("OTP Entered: $value");
              },
              onChanged: (value) {
                print(value);
              },
            ),

            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Didn’t get anything? No worries, let’s try again.'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Resend', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),

            SizedBox(height: 30),

            isLoading ? CircularProgressIndicator() : Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              width: double.infinity,
              color: Colors.white,
              child: ElevatedButton(
                onPressed: verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[300],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Verify',
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
