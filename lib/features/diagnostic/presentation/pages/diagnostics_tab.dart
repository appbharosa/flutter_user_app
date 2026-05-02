import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/address.dart';
import '../../../../domain/entities/diagnostic.dart';
import '../../../home/presentation/address_bloc/address_bloc.dart';
import '../../../home/presentation/address_bloc/address_state.dart';
import '../../../language/bloc/language_bloc.dart';
import '../../../language/bloc/language_state.dart';
import '../bloc/diagnostic_bloc.dart';
import '../bloc/diagnostic_event.dart';
import '../bloc/diagnostic_state.dart';

class DiagnosticsTab extends StatefulWidget {
  final ValueNotifier<String> searchNotifier;
  const DiagnosticsTab({super.key, required this.searchNotifier});

  @override
  State<DiagnosticsTab> createState() => _DiagnosticsTabState();
}

class _DiagnosticsTabState extends State<DiagnosticsTab> {
  late DiagnosticBloc _diagnosticBloc;
  final ScrollController _scrollController = ScrollController();
  bool _dataLoaded = false;
  String _searchQuery = '';
  List<Diagnostic> _originalDiagnostics = [];
  List<Diagnostic> _filteredDiagnostics = [];

  @override
  void initState() {
    super.initState();
    _diagnosticBloc = sl<DiagnosticBloc>();
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
        print("🩺 Loading diagnostics with lat=$lat, lon=$lon, lang=$lang");
        _diagnosticBloc.add(LoadDiagnostics(page: 1, lat: lat, lon: lon, lang: lang));
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
      _filteredDiagnostics = List.from(_originalDiagnostics);
    } else {
      _filteredDiagnostics = _originalDiagnostics.where((diag) =>
      diag.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          diag.location.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
  }

  void _onScroll() {
    if (_searchQuery.isEmpty) {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _diagnosticBloc.add(LoadMoreDiagnostics());
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
      value: _diagnosticBloc,
      child: BlocBuilder<DiagnosticBloc, DiagnosticState>(
        builder: (context, state) {
          if (state is DiagnosticInitial || state is DiagnosticLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DiagnosticLoaded) {
            if (_originalDiagnostics.length != state.diagnostics.length) {
              _originalDiagnostics = List.from(state.diagnostics);
              _applyFilter();
            }
            final displayList = _searchQuery.isEmpty ? state.diagnostics : _filteredDiagnostics;
            if (displayList.isEmpty) {
              return const Center(child: Text('No diagnostics found'));
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
                final diagnostic = displayList[index];
                return _buildDiagnosticCard(diagnostic);
              },
            );
          } else if (state is DiagnosticError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildDiagnosticCard(Diagnostic diagnostic) {
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
                diagnostic.logo,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.monitor_heart, size: 40),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(diagnostic.name.isNotEmpty ? diagnostic.name : 'Diagnostic Center', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  if (diagnostic.openTime.isNotEmpty && diagnostic.closeTime.isNotEmpty)
                    Text('⏰ ${diagnostic.openTime} - ${diagnostic.closeTime}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Text('📍 ${diagnostic.location.isNotEmpty ? diagnostic.location : 'Unknown location'}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Text('📏 ${diagnostic.distance}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}