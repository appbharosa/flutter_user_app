import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/address.dart';
import '../../../../domain/entities/lab_test.dart';
import '../../../home/presentation/address_bloc/address_bloc.dart';
import '../../../home/presentation/address_bloc/address_state.dart';
import '../../../language/bloc/language_bloc.dart';
import '../../../language/bloc/language_state.dart';
import '../bloc/lab_test_bloc.dart';
import '../bloc/lab_test_event.dart';
import '../bloc/lab_test_state.dart';

class LabTestsTab extends StatefulWidget {
  final ValueNotifier<String> searchNotifier;
  const LabTestsTab({super.key, required this.searchNotifier});

  @override
  State<LabTestsTab> createState() => _LabTestsTabState();
}

class _LabTestsTabState extends State<LabTestsTab> {
  late LabTestBloc _labTestBloc;
  final ScrollController _scrollController = ScrollController();
  bool _dataLoaded = false;
  String _searchQuery = '';
  List<LabTest> _originalLabTests = [];
  List<LabTest> _filteredLabTests = [];

  @override
  void initState() {
    super.initState();
    _labTestBloc = sl<LabTestBloc>();
    _scrollController.addListener(_onScroll);
    widget.searchNotifier.addListener(_onSearchChanged);
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
    final addressState = context.read<AddressBloc>().state;
    final languageState = context.read<LanguageBloc>().state;

    if (addressState is AddressLoaded && languageState is LanguageChanged) {
      Address? selectedAddress;
      if (addressState.addresses.isNotEmpty) {
        for (var addr in addressState.addresses) {
          if (addr.isDefault) {
            selectedAddress = addr;
            break;
          }
        }
        selectedAddress ??= addressState.addresses.first;
      }
      if (selectedAddress != null) {
        final lat = double.tryParse(selectedAddress.lat) ?? 0.0;
        final lon = double.tryParse(selectedAddress.lon) ?? 0.0;
        final lang = languageState.language.apiCode;
        print("🔬 Loading lab tests with lat=$lat, lon=$lon, lang=$lang");
        _labTestBloc.add(LoadLabTests(page: 1, lat: lat, lon: lon, lang: lang));
        setState(() => _dataLoaded = true);
      }
    }
  }

  void _onSearchChanged() {
    if (mounted) {
      setState(() {
        _searchQuery = widget.searchNotifier.value;
        _applyFilter();
      });
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
    widget.searchNotifier.removeListener(_onSearchChanged);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
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
              return const Center(child: Text('No labs found'));
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
                return _buildLabTestCard(lab);
              },
            );
          } else if (state is LabTestError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
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
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.science, size: 40),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lab.name.isNotEmpty ? lab.name : 'Lab Test', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  if (lab.openTime.isNotEmpty && lab.closeTime.isNotEmpty)
                    Text('⏰ ${lab.openTime} - ${lab.closeTime}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Text('📍 ${lab.location.isNotEmpty ? lab.location : 'Unknown location'}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Text('📏 ${lab.distance}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}