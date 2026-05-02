import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../bloc/contact_us_bloc.dart';
import '../bloc/contact_us_event.dart';
import '../bloc/contact_us_state.dart';



class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();
  late Future<void> _userLoadFuture;
  int? _userId;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userLoadFuture = _loadSavedUser();
  }

  Future<void> _loadSavedUser() async {
    final authRepo = sl<AuthRepository>();
    final result = await authRepo.getSavedUser();
    result.fold(
          (failure) {
        debugPrint('No saved user: ${failure.message}');
      },
          (user) {
        setState(() {
          _userId = user.id;
          _nameController.text = user.name;
          _emailController.text = user.email;
       //   _mobileController.text = user.mobile;
        });
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ContactUsBloc>(),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Contact Us',
              style: TextStyle(
                color: AppColors.whiteColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
            backgroundColor: AppColors.blue,
            foregroundColor: Colors.white,
          ),
          body: FutureBuilder(
            future: _userLoadFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return BlocConsumer<ContactUsBloc, ContactUsState>(
                listener: (context, state) {
                  if (state is ContactUsSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(10),
                      ),
                    );
                    _formKey.currentState?.reset();
                    _messageController.clear();
                  } else if (state is ContactUsError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(10),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return Column(
                    children: [
                      // Scrollable form fields
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Full Name',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (v) => v == null || v.isEmpty ? 'Enter your name' : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Enter email';
                                    if (!v.contains('@')) return 'Enter valid email';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _mobileController,
                                  decoration: const InputDecoration(
                                    labelText: 'Mobile',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  validator: (v) => v == null || v.isEmpty ? 'Enter mobile number' : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _messageController,
                                  decoration: const InputDecoration(
                                    labelText: 'Message',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 5,
                                  validator: (v) => v == null || v.isEmpty ? 'Enter your message' : null,
                                ),
                                // Add extra space at the bottom for comfortable scrolling
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Fixed Submit Button at bottom
                      Padding(
                        padding: const EdgeInsets.all(16),
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
                            onPressed: (state is ContactUsLoading || _userId == null)
                                ? null
                                : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<ContactUsBloc>().add(
                                  SubmitContactUs(
                                    userId: _userId!,
                                    name: _nameController.text.trim(),
                                    email: _emailController.text.trim(),
                                    mobile: _mobileController.text.trim(),
                                    message: _messageController.text.trim(),
                                  ),
                                );
                              }
                            },
                            child: state is ContactUsLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                              'Submit',
                              style: TextStyle(
                                color: AppColors.whiteColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}