import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injection.dart';
import '../../online_doctor_coupon_bloc/online_doctor_coupon_bloc.dart';


class OnlineDoctorCouponBottomSheet extends StatelessWidget {
  final Function(String) onCouponSelected;
  final String lang;

  const OnlineDoctorCouponBottomSheet({
    super.key,
    required this.onCouponSelected,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<OnlineDoctorCouponBloc>()..add(LoadOnlineDoctorCoupons(lang)),
      child: DraggableScrollableSheet(
        initialChildSize: 0.5,   // start at 50% of screen height
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,           // important: prevents taking full screen
        builder: (context, scrollController) {
          return BlocBuilder<OnlineDoctorCouponBloc, OnlineDoctorCouponState>(
            builder: (context, state) {
              if (state is OnlineDoctorCouponLoading) return const Center(child: CircularProgressIndicator());
              if (state is OnlineDoctorCouponError) return Center(child: Text(state.message));
              if (state is OnlineDoctorCouponLoaded) {
                final coupons = state.coupons;
                if (coupons.isEmpty) return const Center(child: Text('No coupons available'));
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 16),
                    const Text('Available Coupons', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: coupons.length,
                        itemBuilder: (context, index) {
                          final coupon = coupons[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              title: Text(coupon.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(coupon.description),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.pop(context);
                                onCouponSelected(coupon.name);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          );
        },
      ),
    );
  }
}