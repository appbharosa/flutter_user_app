import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/core/utils/translations.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/address.dart';
import '../../../../domain/entities/lab_test.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../language/bloc/language_bloc.dart';
import '../../../language/bloc/language_state.dart';
import '../bloc/lab_test_bloc.dart';
import '../bloc/lab_test_event.dart';
import '../bloc/lab_test_state.dart';
import '../lab_slot_bloc/lab_slot_bloc.dart';
import 'attach_lab_prescription_page.dart';
import 'lab_test_booking_page.dart';




class LabTestsTab extends StatefulWidget {
  final ValueNotifier<String> searchNotifier;
  final ValueNotifier<Address?> addressNotifier;

  const LabTestsTab({
    Key? key,
    required this.searchNotifier,
    required this.addressNotifier,
  }) : super(key: key);

  @override
  State<LabTestsTab> createState() => _LabTestsTabState();
}

class _LabTestsTabState extends State<LabTestsTab> {
  late LabTestBloc _labTestBloc;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _dataLoaded = false;
  String _searchQuery = '';
  List<LabTest> _originalLabTests = [];
  List<LabTest> _filteredLabTests = [];

  @override
  void initState() {
    super.initState();
    _labTestBloc = di.sl<LabTestBloc>();
    _scrollController.addListener(_onScroll);
    widget.searchNotifier.addListener(_onExternalSearchChanged);
    widget.addressNotifier.addListener(_onAddressChanged);
    _searchController.addListener(_onSearchTextChanged);
  }

  void _onAddressChanged() {
    if (mounted) {
      _dataLoaded = false;
      _loadData();
    }
  }

  void _onExternalSearchChanged() {
    if (mounted) {
      setState(() {
        _searchQuery = widget.searchNotifier.value;
        _searchController.text = _searchQuery;
        _applyFilter();
      });
    }
  }

  void _onSearchTextChanged() {
    if (mounted) {
      setState(() {
        _searchQuery = _searchController.text;
        widget.searchNotifier.value = _searchQuery;
        _applyFilter();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dataLoaded) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    await Future.delayed(Duration.zero);
    final address = widget.addressNotifier.value;
    final languageState = context.read<LanguageBloc>().state;

    if (address != null && languageState is LanguageChanged) {
      final lat = double.tryParse(address.lat) ?? 0.0;
      final lon = double.tryParse(address.lon) ?? 0.0;
      final lang = languageState.language.apiCode;
      _labTestBloc.add(LoadLabTests(page: 1, lat: lat, lon: lon, lang: lang));
      setState(() => _dataLoaded = true);
    }
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredLabTests = List.from(_originalLabTests);
    } else {
      _filteredLabTests = _originalLabTests.where((lab) =>
      lab.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          lab.location.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
  }

  void _onScroll() {
    if (_searchQuery.isEmpty) {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _labTestBloc.add(LoadMoreLabTests());
      }
    }
  }

  @override
  void dispose() {
    widget.searchNotifier.removeListener(_onExternalSearchChanged);
    widget.addressNotifier.removeListener(_onAddressChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
                  (route) => false,
            );
          },
        ),
        title:  Text(
          'lab_test'.tr(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search lab tests...',
                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ),
          ),
        ),
      ),
      body: BlocProvider.value(
        value: _labTestBloc,
        child: BlocBuilder<LabTestBloc, LabTestState>(
          builder: (context, state) {
            if (state is LabTestInitial || state is LabTestLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LabTestLoaded) {
              if (_originalLabTests.length != state.labTests.length) {
                _originalLabTests = List.from(state.labTests);
                _applyFilter();
              }
              final displayList = _searchQuery.isEmpty ? state.labTests : _filteredLabTests;
              if (displayList.isEmpty) {
                return const Center(child: Text('No lab tests found'));
              }
              return ListView.builder(
                controller: _scrollController,
                itemCount: displayList.length + (_searchQuery.isEmpty && state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == displayList.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final lab = displayList[index];
                  return GestureDetector(
                    onTap: () {
                      if (lab.packages.isNotEmpty) {
                        final address = widget.addressNotifier.value;
                        if (address == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select an address first'), backgroundColor: Colors.red),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (context) => di.sl<LabSlotBloc>(),
                              child: LabTestBookingPage(
                                labTest: lab,
                                addressId: address.id,
                              ),
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AttachLabPrescriptionPage(
                              labTestId: lab.id,
                              labTestAddress: lab.location,
                            ),
                          ),
                        );
                      }
                    },
                    child: _buildLabTestCard(lab),
                  );
                },
              );
            } else if (state is LabTestError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildLabTestCard(LabTest lab) {
    return Card(
      color: AppColors.whiteColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                lab.logo,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.science, size: 40),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lab.name.isNotEmpty ? lab.name : 'Lab Test',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (lab.openTime.isNotEmpty && lab.closeTime.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.access_time, size: 16, color: AppColors.red),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${lab.openTime} - ${lab.closeTime}',
                            style: const TextStyle(
                              color: AppColors.black,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, size: 16, color: AppColors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          lab.location.isNotEmpty ? lab.location : 'Unknown location',
                          style: const TextStyle(
                            color: AppColors.black,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}