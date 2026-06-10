import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
  final String packageDiscountPrice;
  final double hygienicKitCharges;
  final ValueNotifier<Address?> addressNotifier;

  const FreeLabSlotsScreen({
    Key? key,
    required this.packageId,
    required this.packageName,
    required this.packageDiscountPrice,
    required this.hygienicKitCharges,
    required this.addressNotifier,
  }) : super(key: key);

  @override
  State<FreeLabSlotsScreen> createState() => _FreeLabSlotsScreenState();
}

class _FreeLabSlotsScreenState extends State<FreeLabSlotsScreen> {
  late FreeLabSlotsBloc _bloc;
  DateTime _selectedDate = DateTime.now();
  int? _selectedSlotId;
  String? _selectedSlotTime;
  String? _selectedFormattedDate;
  String? _selectedDateStr;

  @override
  void initState() {
    super.initState();
    _bloc = di.sl<FreeLabSlotsBloc>();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    final language = await LanguageService.getCurrentLanguage();
    final dateStr = _selectedDate.toIso8601String().split('T').first;
    _bloc.add(LoadFreeLabSlots(language, widget.packageId, date: dateStr));
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedSlotId = null;
      _selectedSlotTime = null;
    });
    _loadSlots();
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _navigateToFamilySelection(FreeLabSlotResponse slotsResponse) async {
    final familyMember = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FamilySelectionScreen()),
    );

    if (familyMember != null && familyMember is FamilyMember) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FreeLabBookingConfirmScreen(
            packageId: widget.packageId,
            packageName: widget.packageName,
            packageDiscountPrice: widget.packageDiscountPrice,
            addressNotifier: widget.addressNotifier,
            hygienicKitCharges: widget.hygienicKitCharges,
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
      child: SafeArea(
        bottom: true,
        top: false,
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
                _selectedDateStr = slotsResponse.date;

                return Column(
                  children: [
                    // Address Card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.blue.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.blue, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.addressNotifier.value?.address ?? 'Select Address',
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Date Picker Card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Date',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 30)),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(primary: AppColors.blue),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (date != null) _onDateSelected(date);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade50,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, color: AppColors.blue, size: 20),
                                      const SizedBox(width: 12),
                                      Text(
                                        _formatDate(_selectedDate),
                                        style: const TextStyle(fontSize: 14, fontFamily: 'Poppins'),
                                      ),
                                    ],
                                  ),
                                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Available Time Slots Header
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Available Time Slots',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Slots Grid
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: slotsResponse.sessions.length,
                        itemBuilder: (context, index) {
                          final session = slotsResponse.sessions[index];
                          final availableSlots = session.slots.where((s) => s.isAvailable && !s.isBooked).toList();
                          if (availableSlots.isEmpty) return const SizedBox();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Session Header
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Text(
                                      session.sessionIcon,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      session.session,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${session.availableSlots} slots',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Slots Grid (4 slots per row)
                              GridView.count(
                                crossAxisCount: 4,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                childAspectRatio: 2.0,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                children: availableSlots.map((slot) {
                                  final isSelected = _selectedSlotId == slot.slotId;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedSlotId = slot.slotId;
                                        _selectedSlotTime = slot.startTime;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppColors.blue : Colors.white,
                                        border: Border.all(
                                          color: isSelected ? AppColors.blue : Colors.grey.shade300,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: isSelected
                                            ? [
                                          BoxShadow(
                                            color: AppColors.blue.withOpacity(0.2),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                            : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          slot.startTime,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    // Continue Button
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _selectedSlotId == null
                              ? null
                              : () => _navigateToFamilySelection(slotsResponse),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
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
      ),
    );
  }
}