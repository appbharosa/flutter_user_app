import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/core/theme/app_colors.dart';
import 'package:user/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:user/features/auth/presentation/bloc/auth_state.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/translations.dart';
import '../../../otp/presentation/pages/otp_verification_page.dart';
import '../bloc/auth_event.dart';


import 'package:lottie/lottie.dart';




class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Carousel related
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<String> _animationPaths = [
    'assets/animations/slide3.json',
    'assets/animations/slide2.json',
    'assets/animations/slide5.json',
    'assets/animations/slide6.json',
  ];

  @override
  void initState() {
    super.initState();
    // Auto slide every 4 seconds
    Future.delayed(Duration.zero, () {
      Timer.periodic(const Duration(seconds: 2), (timer) {
        if (_pageController.hasClients) {
          _currentPage = (_currentPage + 1) % _animationPaths.length;
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpError) {
            _showSnackBar(state.message, isError: true);
          }
          if (state is OtpSent) {
            _showSnackBar('otp_sent'.tr(), isError: false);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OtpVerificationPage(userId: state.userId),
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            bottom: true,
            top: false,
            child: Scaffold(
              backgroundColor: AppColors.whiteColor,
              resizeToAvoidBottomInset: true,
              bottomNavigationBar: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom > 0
                      ? MediaQuery.of(context).viewInsets.bottom
                      : 16,
                  top: 10,
                ),
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: state is OtpLoading
                        ? null
                        : () {
                      FocusScope.of(context).unfocus();
                      if (_formKey.currentState!.validate()) {
                        context.read<AuthBloc>().add(
                          SendOtpRequested(phoneController.text.trim()),
                        );
                      }
                    },
                    child: state is OtpLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                      'continue_text'.tr(),
                      style: TextStyle(
                        color: AppColors.whiteColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ),
              body: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 80),
                          // 🎬 Sliding animations carousel
                          SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: PageView(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              children: _animationPaths.map((path) {
                                return Center(
                                  child: Lottie.asset(
                                    path,
                                    height: 320,
                                    width: 320,
                                    fit: BoxFit.contain,
                                    repeat: true,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 320,
                                        width: 320,
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.animation, size: 60),
                                      );
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          // Optional: page indicator dots
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_animationPaths.length, (index) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: _currentPage == index ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                      ? AppColors.blue
                                      : Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            'login'.tr(),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            decoration: InputDecoration(
                              hintText: 'enter_phone_number'.tr(),
                              counterText: "",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter phone number";
                              }
                              if (value.length != 10) {
                                return "Enter valid 10 digit number";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}