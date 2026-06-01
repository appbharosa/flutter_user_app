
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/services/language_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/address.dart';
import '../../../../domain/entities/family_member.dart';
import '../../../../domain/entities/free_lab_slot.dart';
import '../bloc/free_lab_slots_bloc/free_lab_slots_bloc.dart';
import '../bloc/free_lab_slots_bloc/free_lab_slots_event.dart';
import '../bloc/free_lab_slots_bloc/free_lab_slots_state.dart';
import 'family_selection_screen.dart';
import 'free_lab_booking_confirm_screen.dart';


class FreeLabSlotsScreen extends StatefulWidget {
  final int packageId;
  final String packageName;
  final ValueNotifier<Address?> addressNotifier;

  const FreeLabSlotsScreen({
    Key? key,
    required this.packageId,
    required this.packageName,
    required this.addressNotifier,
  }) : super(key: key);

  @override
  State<FreeLabSlotsScreen> createState() => _FreeLabSlotsScreenState();
}

class _FreeLabSlotsScreenState extends State<FreeLabSlotsScreen> {
  late FreeLabSlotsBloc _bloc;
  int? _selectedSlotId;
  String? _selectedSlotTime;
  String? _selectedFormattedDate;
  String? _selectedDate;

  @override
  void initState() {
    super.initState();
    _bloc = di.sl<FreeLabSlotsBloc>();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    final language = await LanguageService.getCurrentLanguage();
    _bloc.add(LoadFreeLabSlots(language, widget.packageId));
  }

  void _navigateToFamilySelection(FreeLabSlotResponse slotsResponse) async {
    final familyMember = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FamilySelectionScreen(),
      ),
    );

    if (familyMember != null && familyMember is FamilyMember) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FreeLabBookingConfirmScreen(
            packageId: widget.packageId,
            packageName: widget.packageName,
            addressNotifier: widget.addressNotifier,
            slotId: _selectedSlotId!,
            slotTime: _selectedSlotTime!,
            date: slotsResponse.date,
            formattedDate: slotsResponse.formattedDate,
            familyMember: familyMember,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          title: const Text(
            'Select Time Slot',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: AppColors.whiteColor,
            ),
          ),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
        ),
        body: BlocConsumer<FreeLabSlotsBloc, FreeLabSlotsState>(
          listener: (context, state) {
            if (state is FreeLabSlotsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is FreeLabSlotsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FreeLabSlotsLoaded) {
              final slotsResponse = state.slots;
              _selectedFormattedDate = slotsResponse.formattedDate;
              _selectedDate = slotsResponse.date;

              return Column(
                children: [
                  // Address Card
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.blue.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.blue, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.addressNotifier.value?.address ?? 'Select Address',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Date info
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today, color: AppColors.blue, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '${slotsResponse.formattedDate} (${slotsResponse.day})',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Available Time Slots',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: slotsResponse.sessions.length,
                      itemBuilder: (context, index) {
                        final session = slotsResponse.sessions[index];
                        final availableSlots = session.slots.where((s) => s.isAvailable && !s.isBooked).toList();
                        if (availableSlots.isEmpty) return const SizedBox();
                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    session.sessionIcon,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    session.session,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${session.availableSlots} slots',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: availableSlots.map((slot) {
                                  final isSelected = _selectedSlotId == slot.slotId;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (_selectedSlotId == slot.slotId) {
                                          _selectedSlotId = null;
                                          _selectedSlotTime = null;
                                        } else {
                                          _selectedSlotId = slot.slotId;
                                          _selectedSlotTime = slot.startTime;
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppColors.blue : Colors.white,
                                        border: Border.all(
                                          color: isSelected ? AppColors.blue : Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        slot.startTime,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected ? Colors.white : AppColors.black,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _selectedSlotId == null
                            ? null
                            : () => _navigateToFamilySelection(slotsResponse),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}