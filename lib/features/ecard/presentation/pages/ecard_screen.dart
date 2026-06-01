
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/services/language_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../bloc/ecard_bloc.dart';
import '../bloc/ecard_event.dart';
import '../bloc/ecard_state.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../bloc/ecard_bloc.dart';

class ECardScreen extends StatefulWidget {
  final bool isFromBottomNav; // Add this parameter

  const ECardScreen({
    Key? key,
    this.isFromBottomNav = false,
  }) : super(key: key);

  @override
  State<ECardScreen> createState() => _ECardScreenState();
}

class _ECardScreenState extends State<ECardScreen> {
  late ECardBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = di.sl<ECardBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final language = await LanguageService.getCurrentLanguage();
    _bloc.add(LoadECard(language));
  }

  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          // Conditionally show leading back button
          leading: widget.isFromBottomNav
              ? null // No back button when from bottom navigation
              : IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
                    (route) => false,
              );
            },
          ),
          title: const Text(
            'My eCard',
            style: TextStyle(
              color: AppColors.whiteColor,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
          centerTitle: widget.isFromBottomNav, // Center title when no back button
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocConsumer<ECardBloc, ECardState>(
          listener: (context, state) {
            if (state is ECardError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ECardLoading || state is ECardInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ECardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            if (state is ECardLoaded) {
              final ecard = state.ecard;
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/med.svg',
                        height: 100,
                        width: 200,
                        placeholderBuilder: (_) => Container(
                          color: Colors.grey.shade200,
                          width: 100,
                          height: 200,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.blue.shade300, AppColors.blue],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade200,
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ecard.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
                                const SizedBox(width: 8),
                                Text(
                                  'Valid until: ${ecard.toDate}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (ecard.uniqueId != null && ecard.uniqueId!.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(Icons.qr_code, size: 16, color: Colors.white70),
                                  const SizedBox(width: 8),
                                  Text(
                                    'ID: ${ecard.uniqueId}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 8),
                            if (ecard.image != null && ecard.image!.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(Icons.image, size: 16, color: Colors.white70),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      ecard.image!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }
}