import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:user/features/home/presentation/pages/home_page.dart';
import 'package:user/features/registration/presentation/pages/registration_page.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/otp_verification_bloc.dart';
import '../bloc/otp_verification_event.dart';
import '../bloc/otp_verification_state.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../bloc/otp_verification_bloc.dart';
import '../bloc/otp_verification_event.dart';
import '../bloc/otp_verification_state.dart';

class OtpVerificationPage extends StatefulWidget {
  final int userId;
  const OtpVerificationPage({super.key, required this.userId});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController otpController = TextEditingController();
  final FocusNode otpFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      otpFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    otpController.dispose();
    otpFocusNode.dispose();
    super.dispose();
  }

  String getOtp() => otpController.text.trim();

  void _submitOtp(BuildContext context, OtpVerificationState state) {
    final otp = getOtp();

    if (otp.length != 6) {
      _showSnackBar(context, "Enter valid 6-digit OTP", isError: true);
      return;
    }

    // ✅ Use BlocProvider.of to be explicit
    final bloc = BlocProvider.of<OtpVerificationBloc>(context, listen: false);
    bloc.add(VerifyOtpButtonPressed(userId: widget.userId, otp: otp));
  }

  void _showSnackBar(BuildContext context, String message, {required bool isError}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OtpVerificationBloc>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          title: const Text(
            "OTP Verification",
            style: TextStyle(fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<OtpVerificationBloc, OtpVerificationState>(
          listener: (context, state) {
            if (state is OtpVerificationError) {
              _showSnackBar(context, state.message, isError: true);
            }
            if (state is OtpVerificationSuccess) {
              final user = state.userProfile;

              _showSnackBar(context, 'Login successful!', isError: false);

              if (user.name != null && user.name!.isNotEmpty &&
                  user.email != null && user.email!.isNotEmpty) {
                // ✅ Existing user → Home
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                      (route) => false,
                );
              } else {
                // ✅ New user → Registration
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RegistrationPage(),
                  ),
                );
              }
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 0),
                            SizedBox(
                              height: 150,
                              child: SvgPicture.asset("assets/med.svg"),
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              "Enter OTP",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Enter the 6-digit OTP sent to your number",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 30),
                            TextFormField(
                              controller: otpController,
                              focusNode: otpFocusNode,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              maxLength: 6,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                letterSpacing: 8,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                counterText: "",
                                hintText: "000000",
                                hintStyle: TextStyle(
                                  fontSize: 18,
                                  letterSpacing: 8,
                                  color: Colors.grey.shade300,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.blue,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.length == 6) {
                                  _submitOtp(context, state);
                                }
                              },
                              onFieldSubmitted: (value) {
                                if (value.length == 6) {
                                  _submitOtp(context, state);
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) return "Enter OTP";
                                if (value.length != 6) return "Enter valid 6-digit OTP";
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SafeArea(
                      top: false,
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: (state is OtpVerificationLoading)
                              ? null
                              : () => _submitOtp(context, state),
                          child: state is OtpVerificationLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            "Verify OTP",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}