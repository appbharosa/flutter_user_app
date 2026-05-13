import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../lab_coupon_list_bloc/lab_coupon_list_bloc.dart';
import '../../lab_coupon_list_bloc/lab_coupon_list_event.dart';
import '../../lab_coupon_list_bloc/lab_coupon_list_state.dart';


class CouponBottomSheet extends StatelessWidget {
  final Function(String) onCouponSelected;
  const CouponBottomSheet({super.key, required this.onCouponSelected});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LabCouponListBloc>()..add(LoadLabCoupons()),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return BlocBuilder<LabCouponListBloc, LabCouponListState>(
            builder: (context, state) {
              if (state is LabCouponListLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is LabCouponListError) {
                return Center(child: Text(state.message));
              }
              if (state is LabCouponListLoaded && state.coupons.isEmpty) {
                return const Center(child: Text('No coupons available'));
              }
              if (state is LabCouponListLoaded) {
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Available Coupons',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: state.coupons.length,
                        itemBuilder: (context, index) {
                          final coupon = state.coupons[index];
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