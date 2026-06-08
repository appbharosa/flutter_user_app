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
  final VoidCallback onSelectCurrentLocation;

  const AddressBottomSheet({
    super.key,
    required this.onAddressSelected,
    this.currentAddress,
    required this.onSelectCurrentLocation,
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
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Column(
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
                        'Select Delivery Address',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: AppColors.black,
                        ),                    ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: state is AddressLoading
                          ? const Center(child: CircularProgressIndicator())
                          : state is AddressLoaded
                          ? ListView.builder(
                        controller: scrollController,
                        itemCount: state.addresses.length + 1, // +1 for current location option
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _buildCurrentLocationTile();
                          }
                          final addr = state.addresses[index - 1];
                          final isSelected = widget.currentAddress?.id == addr.id;
                          return _buildAddressTile(addr, isSelected);
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
                          label: const Text('Add New Address', style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: AppColors.whiteColor,
                          ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 34),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCurrentLocationTile() {
    final isSelected = widget.currentAddress?.id == -1;
    return GestureDetector(
      onTap: widget.onSelectCurrentLocation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade200, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.my_location, color: Colors.green, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Use Current Location',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: AppColors.black,
                ),
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressTile(Address addr, bool isSelected) {
    final formattedAddress = '${addr.hno ?? ''} ${addr.buildingNo ?? ''}, ${addr.address}'.trim();
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
            Icon(
              Icons.location_on,
              color: Colors.red,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedAddress,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${addr.city}, ${addr.state} - ${addr.pincode}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                      color: AppColors.black,
                    ),                  ),
                  if (addr.isDefault)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(12)),
                      child: const Text('DEFAULT', style: TextStyle(fontSize: 10, color: Colors.green)),
                    ),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }
}