import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
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
  bool isLoading = false;  // ✅ Add a loading state

  void verifyOtp() async {
    if (otpController.text.length == 6) {
      setState(() => isLoading = true);  // ✅ Show loading indicator

      try {
        String? token = await ApiService.verifyOtp(widget.phone, otpController.text);

        if (token != null) {
          // ✅ Navigate to ChatListScreen with token
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ChatListScreen(token: token)),
          );
        } else {
          print("Failed to get token");
        }
      } catch (e) {
        print("Error: $e");
      } finally {
        setState(() => isLoading = false);  // ✅ Hide loading indicator
      }
    } else {
      print("Please enter a valid 6-digit OTP");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter OTP")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Enter OTP sent to ${widget.phone}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),

            /// 📌 OTP Input Field with 6 Boxes
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

            SizedBox(height: 30),

            isLoading
                ? CircularProgressIndicator()  // ✅ Show loading while verifying
                : ElevatedButton(
                    onPressed: verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[300],
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Verify OTP",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
