import 'package:chatting_app/screens/Login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController digit1 = TextEditingController();
  final TextEditingController digit2 = TextEditingController();
  final TextEditingController digit3 = TextEditingController();
  final TextEditingController digit4 = TextEditingController();

  Widget buildOtpBox(TextEditingController controller) {
    return SizedBox(
      width: 60,
      height: 60,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          counterText: "",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    digit1.dispose();
    digit2.dispose();
    digit3.dispose();
    digit4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OTP Verification",)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter the OTP sent to ${widget.email}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),

            const Text(
              'Enter OTP',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            /// OTP BOXES ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildOtpBox(digit1),
                buildOtpBox(digit2),
                buildOtpBox(digit3),
                buildOtpBox(digit4),
              ],
            ),

            const SizedBox(height: 40),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  String otp = digit1.text +
                      digit2.text +
                      digit3.text +
                      digit4.text;
              
                  print("Entered OTP: $otp");
              
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text("Verify"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}