
import 'package:flutter/material.dart';
import 'package:user/core/theme/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../domain/entities/address.dart';
import '../../address_bloc/address_bloc.dart';
import '../../address_bloc/address_event.dart';
import '../../address_bloc/address_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_address_screen.dart';



class AddressBottomSheet extends StatefulWidget {
  final Function(Address) onAddressSelected;
  final Address? currentAddress;

  const AddressBottomSheet({
    super.key,
    required this.onAddressSelected,
    this.currentAddress,
  });

  @override
  State<AddressBottomSheet> createState() => _AddressBottomSheetState();
}

class _AddressBottomSheetState extends State<AddressBottomSheet> {
  late AddressBloc _addressBloc;

  @override
  void initState() {
    super.initState();
    _addressBloc = sl<AddressBloc>()..add(LoadAddresses());
  }

  @override
  void dispose() {
    _addressBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _addressBloc,
      child: DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return BlocConsumer<AddressBloc, AddressState>(
            listener: (context, state) {
              if (state is AddressOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.green),
                );
              } else if (state is AddressError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                );
              }
            },
            builder: (context, state) {
              return
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Select Address',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: state is AddressLoading
                          ? const Center(child: CircularProgressIndicator())
                          : state is AddressLoaded
                          ? ListView.builder(
                        controller: scrollController,
                        itemCount: state.addresses.length,
                        itemBuilder: (context, index) {
                          final addr = state.addresses[index];
                          final formattedAddress = '${addr.hno ?? ''} ${addr.buildingNo ?? ''}, ${addr.address}'.trim();
                          final isSelected = widget.currentAddress?.id == addr.id;
                          return GestureDetector(
                            onTap: () {
                              widget.onAddressSelected(addr);
                              Navigator.pop(context);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade200, width: isSelected ? 2 : 1),
                                borderRadius: BorderRadius.circular(12),
                                color: addr.isDefault ? Colors.blue.shade50 : null,
                              ),
                              child: Row(
                                children: [
                                  Image.asset('assets/location.jpeg', width: 28, height: 26),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          formattedAddress,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${addr.city}, ${addr.state} - ${addr.pincode}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        if (addr.isDefault)
                                          Container(
                                            margin: const EdgeInsets.only(top: 6),
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade100,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              'DEFAULT',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.green,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected) const Icon(Icons.check_circle, color: Colors.green),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                          : const Center(child: Text('No addresses found')),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            final addressBloc = context.read<AddressBloc>();
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddAddressScreen(addressBloc: addressBloc),
                              ),
                            );
                            if (result == true && mounted) {
                              addressBloc.add(LoadAddresses());
                            }
                          },
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: Text(
                            'Add New Address',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
            },
          );
        },
      ),
    );
  }
}