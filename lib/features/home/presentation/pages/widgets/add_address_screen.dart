import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../address_bloc/address_bloc.dart';
import '../../address_bloc/address_event.dart';
import '../../address_bloc/address_state.dart';
import '../home_page.dart'; 



class AddAddressScreen extends StatefulWidget {
  final AddressBloc addressBloc;
  final bool fromRegistration;
  const AddAddressScreen({super.key, required this.addressBloc,  this.fromRegistration = false,});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  final _hnoCtrl = TextEditingController();
  final _buildingCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  String _addressType = 'home';
  bool _isLoading = false;

  int? _userId;
  double? _latitude;
  double? _longitude;
  StreamSubscription<AddressState>? _stateSubscription;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _stateSubscription = widget.addressBloc.stream.listen((state) {
      if (state is AddressOperationSuccess) {
        _showSnackBar(state.message, isError: false);

        if (widget.fromRegistration) {
          // ✅ From Registration → go to Home
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
                (route) => false,
          );
        } else {
          // ✅ From Bottom Sheet → just go back
          Navigator.pop(context, true);
        }
      }
      else if (state is AddressError) {
        _showSnackBar(state.message, isError: true);
      }
    });
  }
  Future<void> _loadUserId() async {
    final authRepo = sl<AuthRepository>();
    final result = await authRepo.getSavedUser();
    result.fold((failure) => null, (user) => _userId = user.id);
    setState(() {});
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Location permission denied');
          setState(() => _isLoading = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Location permissions are permanently denied');
        setState(() => _isLoading = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _latitude = position.latitude;
      _longitude = position.longitude;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        _latitude!,
        _longitude!,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String fullAddress = [
          place.name,
          place.thoroughfare,
          place.locality,
          place.administrativeArea,
          place.postalCode,
          place.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        _addressCtrl.text = fullAddress;
        _cityCtrl.text = place.locality ?? '';
        _stateCtrl.text = place.administrativeArea ?? '';
        _pincodeCtrl.text = place.postalCode ?? '';
      }
      _showSnackBar('Location fetched successfully', isError: false);
    } catch (e) {
      _showSnackBar('Failed to get location: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_userId == null) {
        _showSnackBar('User not found. Please login again.');
        return;
      }
      final addressData = {
        'user_id': _userId,
        'address': _addressCtrl.text,
        'hno': _hnoCtrl.text,
        'building_no': _buildingCtrl.text,
        'landmark': _landmarkCtrl.text,
        'lat': _latitude?.toString() ?? '0.0',
        'lon': _longitude?.toString() ?? '0.0',
        'address_type': _addressType,
        'pincode': _pincodeCtrl.text,
        'state': _stateCtrl.text,
        'city': _cityCtrl.text,
      };
      // Dispatch event
      widget.addressBloc.add(AddNewAddress(addressData));
      // No immediate pop; wait for success state
    }
  }
  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  @override
  void dispose() {
    _addressCtrl.dispose();
    _hnoCtrl.dispose();
    _buildingCtrl.dispose();
    _landmarkCtrl.dispose();
    _pincodeCtrl.dispose();
    _stateCtrl.dispose();
    _cityCtrl.dispose();
    _stateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Address',style: TextStyle(
          color: AppColors.whiteColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,  // SemiBold
          fontFamily: 'Poppins',
        ),),
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _addressCtrl,
                decoration: InputDecoration(
                  labelText: 'Full Address',
                  hintText: 'Street, area, city, state, pincode',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  suffixIcon: IconButton(
                    icon: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.my_location, color: Colors.blue),
                    onPressed: _isLoading ? null : _getCurrentLocation,
                  ),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hnoCtrl,
                decoration: InputDecoration(
                  labelText: 'House/Flat No',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _buildingCtrl,
                decoration: InputDecoration(
                  labelText: 'Building/Apartment',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _landmarkCtrl,
                decoration: InputDecoration(
                  labelText: 'Landmark',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _addressType,
                decoration: InputDecoration(
                  labelText: 'Address Type',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: const [
                  DropdownMenuItem(value: 'home', child: Text('Home')),
                  DropdownMenuItem(value: 'work', child: Text('Work')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) => setState(() => _addressType = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pincodeCtrl,
                decoration: InputDecoration(
                  labelText: 'Pincode',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stateCtrl,
                decoration: InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityCtrl,
                decoration: InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _submit,
                  child: const Text(
                    'Confirm',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}