// lib/features/home/presentation/widgets/add_address_dialog.dart
import 'package:flutter/material.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../domain/repositories/auth_repository.dart';

class AddAddressDialog extends StatefulWidget {
  const AddAddressDialog({super.key});

  @override
  State<AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<AddAddressDialog> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  final _hnoCtrl = TextEditingController();
  final _buildingCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lonCtrl = TextEditingController();
  final _addressTypeCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  late Future<int?> _userIdFuture;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _userIdFuture = _getUserId();
  }

  Future<int?> _getUserId() async {
    final authRepo = sl<AuthRepository>();
    final result = await authRepo.getSavedUser();
    return result.fold((failure) => null, (user) => user.id);
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _hnoCtrl.dispose();
    _buildingCtrl.dispose();
    _landmarkCtrl.dispose();
    _latCtrl.dispose();
    _lonCtrl.dispose();
    _addressTypeCtrl.dispose();
    _pincodeCtrl.dispose();
    _stateCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: _userIdFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        _userId = snapshot.data;
        return AlertDialog(
          title: const Text('Add New Address'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'Full Address'), validator: (v) => v!.isEmpty ? 'Required' : null),
                  const SizedBox(height: 8),
                  TextFormField(controller: _hnoCtrl, decoration: const InputDecoration(labelText: 'House/Flat No')),
                  const SizedBox(height: 8),
                  TextFormField(controller: _buildingCtrl, decoration: const InputDecoration(labelText: 'Building/Apartment')),
                  const SizedBox(height: 8),
                  TextFormField(controller: _landmarkCtrl, decoration: const InputDecoration(labelText: 'Landmark')),
                  const SizedBox(height: 8),
                  TextFormField(controller: _latCtrl, decoration: const InputDecoration(labelText: 'Latitude (optional)')),
                  const SizedBox(height: 8),
                  TextFormField(controller: _lonCtrl, decoration: const InputDecoration(labelText: 'Longitude (optional)')),
                  const SizedBox(height: 8),
                  TextFormField(controller: _addressTypeCtrl, decoration: const InputDecoration(labelText: 'Address Type (home/work)')),
                  const SizedBox(height: 8),
                  TextFormField(controller: _pincodeCtrl, decoration: const InputDecoration(labelText: 'Pincode'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
                  const SizedBox(height: 8),
                  TextFormField(controller: _stateCtrl, decoration: const InputDecoration(labelText: 'State'), validator: (v) => v!.isEmpty ? 'Required' : null),
                  const SizedBox(height: 8),
                  TextFormField(controller: _cityCtrl, decoration: const InputDecoration(labelText: 'City'), validator: (v) => v!.isEmpty ? 'Required' : null),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final addressData = {
                    'user_id': _userId,
                    'address': _addressCtrl.text,
                    'hno': _hnoCtrl.text,
                    'building_no': _buildingCtrl.text,
                    'landmark': _landmarkCtrl.text,
                    'lat': _latCtrl.text.isNotEmpty ? _latCtrl.text : '0.0',
                    'lon': _lonCtrl.text.isNotEmpty ? _lonCtrl.text : '0.0',
                    'address_type': _addressTypeCtrl.text,
                    'pincode': _pincodeCtrl.text,
                    'state': _stateCtrl.text,
                    'city': _cityCtrl.text,
                  };
                  Navigator.pop(context, addressData);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}