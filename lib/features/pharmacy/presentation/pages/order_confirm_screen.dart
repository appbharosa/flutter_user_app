import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/translations.dart';
import '../../../../domain/entities/address.dart';
import '../../../../domain/entities/pharmacy.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../language/bloc/language_bloc.dart';
import '../../../language/bloc/language_state.dart';
import '../confirm_bloc/order_bloc.dart';
import '../confirm_bloc/order_event.dart';
import '../confirm_bloc/order_state.dart';


class OrderConfirmScreen extends StatelessWidget {
  final Pharmacy pharmacy;
  final String orderType;
  final List<File> prescriptionFiles;
  final Address address;

  const OrderConfirmScreen({
    super.key,
    required this.pharmacy,
    required this.orderType,
    required this.prescriptionFiles,
    required this.address,
  });

  void _showSnackBar(BuildContext context, String message, {required bool isError}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = sl<AuthRepository>();
    final userFuture = authRepo.getSavedUser();
    final languageState = context.read<LanguageBloc>().state;
    final lang = languageState is LanguageChanged ? languageState.language.apiCode : 'en';

    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          title: const Text('Confirm Order',style: TextStyle(
            color: AppColors.whiteColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,  // SemiBold
            fontFamily: 'Poppins',
          ),),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
        ),
        body: FutureBuilder(
          future: userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final user = snapshot.data!.fold((_) => null, (user) => user);
            if (user == null) {
              return const Center(child: Text('User not found. Please login again.'));
            }
            return BlocProvider(
              create: (context) => sl<OrderBloc>(),
              child: BlocConsumer<OrderBloc, OrderState>(
                listener: (context, state) {
                  if (state is OrderSuccess) {
                    _showSnackBar(context, state.message, isError: false);
                    Navigator.popUntil(context, (route) => route.isFirst);
                  } else if (state is OrderError) {
                    _showSnackBar(context, state.message, isError: true);
                  }
                },
                builder: (context, state) {
                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Pharmacy info
                              Card(
                                color: AppColors.whiteColor,
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          pharmacy.logo,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.store),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(pharmacy.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 4),
                                            Text('Order Type: ${orderType == 'home_delivery' ? 'Home Delivery' : 'Pickup'}'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text('Delivery Address', style: TextStyle(
                                color: AppColors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,  // SemiBold
                                fontFamily: 'Poppins',
                              ),),
                              const SizedBox(height: 8),
                              Card(
                                color: AppColors.lightGreen,
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.location_on, color: Colors.blue, size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(address.address, style: const TextStyle(fontWeight: FontWeight.w500)),
                                            const SizedBox(height: 4),
                                            Text('${address.city}, ${address.state} - ${address.pincode}'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text('Patient Details',  style: TextStyle(
                                color: AppColors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,  // SemiBold
                                fontFamily: 'Poppins',
                              ),),
                              const SizedBox(height: 8),
                              Card(
                                color: AppColors.whiteColor,
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    children: [
                                      _buildInfoRow(Icons.person, 'Name', user.name),
                                      const Divider(),
                                      _buildInfoRow(Icons.phone, 'Mobile', user.phone),
                                      const Divider(),
                                      _buildInfoRow(Icons.email, 'Email', user.email),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text('Prescriptions',  style: TextStyle(
                                color: AppColors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,  // SemiBold
                                fontFamily: 'Poppins',
                              ),),
                              const SizedBox(height: 8),
                              Card(
                                color: Colors.grey.shade100,
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Uploaded Files:', style: TextStyle(fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 100,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: prescriptionFiles.length,
                                          itemBuilder: (context, index) {
                                            final file = prescriptionFiles[index];
                                            return Container(
                                              margin: const EdgeInsets.only(right: 8),
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8),
                                                color: Colors.grey.shade200,
                                                image: file.path.endsWith('.pdf')
                                                    ? null
                                                    : DecorationImage(
                                                  image: FileImage(file),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              child: file.path.endsWith('.pdf')
                                                  ? const Center(child: Icon(Icons.picture_as_pdf, size: 40))
                                                  : null,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                      // Bottom button
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
                            onPressed: state is OrderLoading
                                ? null
                                : () {
                              context.read<OrderBloc>().add(
                                CreateOrderEvent(
                                  pharmacyId: pharmacy.id,
                                  orderType: orderType,
                                  prescriptionPaths: prescriptionFiles.map((f) => f.path).toList(),
                                  lang: lang,
                                  addressId: address.id,
                                ),
                              );
                            },
                            child: state is OrderLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Confirm Order', style: TextStyle(
                              color: AppColors.whiteColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,  // SemiBold
                              fontFamily: 'Poppins',
                            ),),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}