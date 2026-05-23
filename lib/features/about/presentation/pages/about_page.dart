import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/core/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../bloc/about_bloc.dart';
import '../bloc/about_event.dart';
import '../bloc/about_state.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AboutBloc>()..add(FetchAbout()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "About Us",
            style: TextStyle(
              color: AppColors.whiteColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,  // SemiBold
              fontFamily: 'Poppins',
            ),
          ),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
        ),
        body: BlocConsumer<AboutBloc, AboutState>(
          listener: (context, state) {
            if (state is AboutError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is AboutLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AboutLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Text(
                  state.about.content,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w300,  // SemiBold
                    fontFamily: 'Poppins',
                  ),
                ),
              );
            } else {
              return const Center(child: Text('Tap to load about content'));
            }
          },
        ),
      ),
    );
  }
}