import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:user/core/theme/app_colors.dart';
import 'package:user/features/auth/presentation/pages/login_page.dart';
import '../../../../core/utils/translations.dart';
import '../../home/presentation/pages/home_page.dart';
import '../bloc/language_bloc.dart';
import '../bloc/language_event.dart';


class LanguageSelectionPage extends StatefulWidget {
  final bool fromSplash;
  final bool fromHome;
  const LanguageSelectionPage({
    super.key,
    this.fromSplash = false,
    this.fromHome = false,
  });


  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  Language _selectedLanguage = Language.english;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              SvgPicture.asset(
                'assets/med.svg',
                height: 55,
                width: 65,
              ),
              const SizedBox(height: 30),
              Text(
                'Welcome to Med Rayder App',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Select your language',
                style: TextStyle(
                  color: AppColors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 70),
              _buildLanguageCard(
                title: 'English',
                language: Language.english,
                onTap: () => setState(() => _selectedLanguage = Language.english),
              ),
              const SizedBox(height: 16),
              _buildLanguageCard(
                title: 'తెలుగు (Telugu)',
                language: Language.telugu,
                onTap: () => setState(() => _selectedLanguage = Language.telugu),
              ),
              const SizedBox(height: 16),
              _buildLanguageCard(
                title: 'हिन्दी (Hindi)',
                language: Language.hindi,
                onTap: () => setState(() => _selectedLanguage = Language.hindi),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    context.read<LanguageBloc>().add(ChangeLanguage(_selectedLanguage));
                    if (widget.fromHome) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                      );
                    } else if (widget.fromSplash) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    } else {
                      // fallback
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    }
                  },
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard({
    required String title,
    required Language language,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedLanguage == language;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.black45,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.green, size: 24),
          ],
        ),
      ),
    );
  }
}