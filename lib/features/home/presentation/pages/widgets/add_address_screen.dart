import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/translations.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../language/bloc/language_bloc.dart';
import '../../address_bloc/address_bloc.dart';
import '../../address_bloc/address_event.dart';
import '../../address_bloc/address_state.dart';
import '../home_page.dart';

class AddAddressScreen extends StatefulWidget {
  final AddressBloc addressBloc;
  final bool fromRegistration;
  const AddAddressScreen({
    super.key,
    required this.addressBloc,
    this.fromRegistration = false,
  });

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

  // Google Places API Key
  final String _googlePlacesApiKey = 'AIzaSyBj0nytaOdNp6qdK9-blmnhPARai5QtWeY';
  List<dynamic> _addressSuggestions = [];
  bool _isFetchingSuggestions = false;
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _addressCtrl.addListener(_onAddressChanged);
    _stateSubscription = widget.addressBloc.stream.listen((state) {
      if (state is AddressOperationSuccess) {
        _showSnackBar(state.message, isError: false);
        if (widget.fromRegistration) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
                (route) => false,
          );
        } else {
          Navigator.pop(context, true);
        }
      } else if (state is AddressError) {
        _showSnackBar(state.message, isError: true);
      }
    });
  }

  @override
  void dispose() {
    _addressCtrl.removeListener(_onAddressChanged);
    _addressCtrl.dispose();
    _hnoCtrl.dispose();
    _buildingCtrl.dispose();
    _landmarkCtrl.dispose();
    _pincodeCtrl.dispose();
    _stateCtrl.dispose();
    _cityCtrl.dispose();
    _stateSubscription?.cancel();
    _debouncer.dispose();
    super.dispose();
  }

  void _onAddressChanged() {
    if (_addressCtrl.text.isEmpty) {
      setState(() => _addressSuggestions = []);
      return;
    }
    _debouncer.run(() => _fetchAddressSuggestions(_addressCtrl.text));
  }

  Future<void> _fetchAddressSuggestions(String input) async {
    if (input.isEmpty) return;
    setState(() => _isFetchingSuggestions = true);
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$_googlePlacesApiKey&components=country:in',
      );
      final response = await http.get(url);
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['status'] == 'OK') {
        setState(() => _addressSuggestions = data['predictions']);
      } else {
        _showSnackBar('Failed to fetch suggestions: ${data['status']}');
      }
    } catch (e) {
      _showSnackBar('Failed to fetch suggestions: $e');
    } finally {
      setState(() => _isFetchingSuggestions = false);
    }
  }

  Future<void> _selectSuggestion(dynamic prediction) async {
    setState(() {
      _addressCtrl.text = prediction['description'];
      _addressSuggestions = [];
    });

    // Fetch place details
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=${prediction['place_id']}&key=$_googlePlacesApiKey',
      );
      final response = await http.get(url);
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['status'] == 'OK') {
        final result = data['result'];
        final components = result['address_components'];

        // Extract city, state, pincode, and lat/lon
        for (var component in components) {
          final types = List<String>.from(component['types']);
          if (types.contains('locality')) {
            _cityCtrl.text = component['long_name'];
          } else if (types.contains('administrative_area_level_1')) {
            _stateCtrl.text = component['long_name'];
          } else if (types.contains('postal_code')) {
            _pincodeCtrl.text = component['long_name'];
          }
        }

        // Extract latitude and longitude
        if (result['geometry'] != null && result['geometry']['location'] != null) {
          _latitude = result['geometry']['location']['lat'];
          _longitude = result['geometry']['location']['lng'];
        }
      }
    } catch (e) {
      _showSnackBar('Failed to fetch details: $e');
    }
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

  String getLanguageCode(Language lang) {
    switch (lang) {
      case Language.english: return 'en';
      case Language.hindi:   return 'hi';
      case Language.telugu:  return 'te';
      default:               return 'en';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_userId == null) {
      _showSnackBar('User not found. Please login again.');
      return;
    }

    double lat = _latitude ?? 0.0;
    double lon = _longitude ?? 0.0;

    if ((lat == 0.0 && lon == 0.0) || _latitude == null || _longitude == null) {
      setState(() => _isLoading = true);
      try {
        String fullAddress = _addressCtrl.text.trim();
        if (fullAddress.isEmpty) {
          List<String> parts = [];
          if (_pincodeCtrl.text.isNotEmpty) parts.add(_pincodeCtrl.text);
          if (_cityCtrl.text.isNotEmpty) parts.add(_cityCtrl.text);
          if (_stateCtrl.text.isNotEmpty) parts.add(_stateCtrl.text);
          fullAddress = parts.join(', ');
        }

        if (fullAddress.isEmpty) {
          _showSnackBar('Please provide a valid address.', isError: true);
          setState(() => _isLoading = false);
          return;
        }

        final locations = await locationFromAddress(fullAddress);
        if (locations.isNotEmpty) {
          lat = locations.first.latitude;
          lon = locations.first.longitude;
        } else {
          _showSnackBar(
              'Could not fetch coordinates for this address. Please use the location button.',
              isError: true);
          setState(() => _isLoading = false);
          return;
        }
      } catch (e) {
        _showSnackBar('Geocoding error: $e', isError: true);
        setState(() => _isLoading = false);
        return;
      } finally {
        setState(() => _isLoading = false);
      }
    }

    final addressData = {
      'user_id': _userId,
      'address': _addressCtrl.text,
      'hno': _hnoCtrl.text,
      'building_no': _buildingCtrl.text,
      'landmark': _landmarkCtrl.text,
      'lat': lat.toString(),
      'lon': lon.toString(),
      'address_type': _addressType,
      'pincode': _pincodeCtrl.text,
      'state': _stateCtrl.text,
      'city': _cityCtrl.text,
    };

    // 👇 Get current language and pass it with the event
    final lang = getLanguageCode(LanguageBloc.currentLanguage);
    widget.addressBloc.add(AddNewAddress(addressData, lang));
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(
          'add_address'.tr(),
          style: TextStyle(
            color: AppColors.whiteColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
        ),
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
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isFetchingSuggestions)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.my_location, color: Colors.blue),
                        onPressed: _isLoading ? null : _getCurrentLocation,
                      ),
                    ],
                  ),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              if (_addressSuggestions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _addressSuggestions.length,
                    itemBuilder: (context, index) {
                      final prediction = _addressSuggestions[index];
                      return ListTile(
                        title: Text(prediction['description']),
                        onTap: () => _selectSuggestion(prediction),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hnoCtrl,
                decoration: InputDecoration(
                  labelText: 'House/Flat No',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _buildingCtrl,
                decoration: InputDecoration(
                  labelText: 'Building/Apartment',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _landmarkCtrl,
                decoration: InputDecoration(
                  labelText: 'Landmark',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _addressType,
                decoration: InputDecoration(
                  labelText: 'Address Type',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
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
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stateCtrl,
                decoration: InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityCtrl,
                decoration: InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      :  Text(
                    'confirm'.tr(),
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

// Debouncer to avoid excessive API calls
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}