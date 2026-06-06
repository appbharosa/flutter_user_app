import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/di/injection.dart' as sl;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/user_manager.dart';
import '../../../../domain/entities/online_doctor.dart';
import '../../../../domain/entities/online_doctor_slot.dart';
import '../../../subscription/presentation/pages/subscriptions_page.dart';
import '../online_doctor_slot_bloc/online_doctor_slot_bloc.dart';
import 'online_doctor_family_selection_screen.dart';



class OnlineDoctorSlotScreen extends StatefulWidget {
  final OnlineDoctor doctor;
  const OnlineDoctorSlotScreen({super.key, required this.doctor});

  @override
  State<OnlineDoctorSlotScreen> createState() => _OnlineDoctorSlotScreenState();
}

class _OnlineDoctorSlotScreenState extends State<OnlineDoctorSlotScreen> {
  late OnlineDoctorSlotBloc _slotBloc;
  DateTime _selectedDate = DateTime.now();
  OnlineDoctorSlot? _selectedSlot;
  int? _bookingCount;

  @override
  void initState() {
    super.initState();
    _slotBloc = sl.sl<OnlineDoctorSlotBloc>();
    _loadSlots();
  }

  void _loadSlots() {
    final dateStr = _selectedDate.toIso8601String().split('T').first;
    _slotBloc.add(LoadOnlineDoctorSlots(dateStr));
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedSlot = null;
      _bookingCount = null;
    });
    _loadSlots();
  }

  Future<void> _handleContinue() async {
    final hasSubscription = await UserManager.hasActiveSubscription();
    if (!hasSubscription) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please subscribe to book this appointment'), backgroundColor: Colors.orange),
        );
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionPage()));
      }
      return;
    }
    if (_selectedSlot != null && _bookingCount != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OnlineDoctorFamilySelectionScreen(
            doctor: widget.doctor,
            selectedDate: _selectedDate.toIso8601String().split('T').first,
            formattedDate: _formatDate(_selectedDate),
            slot: _selectedSlot!,
            bookingCount: _bookingCount!,
          ),
        ),
      );
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _slotBloc,
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          title: const Text('Select Time Slot',
            style: TextStyle(color: AppColors.whiteColor, fontSize: 17, fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
          ),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            // Date selection card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Poppins', color: AppColors.black)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.blue)),
                          child: child!,
                        ),
                      );
                      if (date != null) _onDateSelected(date);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                              Text('${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, fontFamily: 'Poppins', color: AppColors.black)),
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
            // Slots section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(alignment: Alignment.centerLeft, child: Text('Available Time Slots',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Poppins', color: AppColors.black))),
            ),
            Expanded(
              child: BlocBuilder<OnlineDoctorSlotBloc, OnlineDoctorSlotState>(
                builder: (context, state) {
                  if (state is OnlineDoctorSlotLoading) return const Center(child: CircularProgressIndicator());
                  if (state is OnlineDoctorSlotError) return Center(child: Text(state.message));
                  if (state is OnlineDoctorSlotLoaded) {
                    final slots = state.slots;
                    _bookingCount = slots.bookingCount;
                    if (slots.sessions.isEmpty) return const Center(child: Text('No slots available on this date'));
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: slots.sessions.length,
                      itemBuilder: (context, index) {
                        final session = slots.sessions[index];
                        final availableSlots = session.slots.where((s) => s.isAvailable && !s.isBooked).toList();
                        if (availableSlots.isEmpty) return const SizedBox();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Text(session.icon, style: const TextStyle(fontSize: 24)),
                                const SizedBox(width: 8),
                                Text(session.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Poppins', color: AppColors.black)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: availableSlots.map((slot) {
                                final isSelected = _selectedSlot?.slotId == slot.slotId;
                                return FilterChip(
                                  label: Text(slot.startTime, style: const TextStyle(fontFamily: 'Poppins')),
                                  selected: isSelected,
                                  onSelected: (selected) => setState(() => _selectedSlot = selected ? slot : null),
                                  backgroundColor: Colors.grey.shade100,
                                  selectedColor: AppColors.blue.withOpacity(0.2),
                                  labelStyle: TextStyle(color: isSelected ? AppColors.blue : Colors.black87),
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: _selectedSlot == null ? null : _handleContinue,
                  child: const Text('Continue', style: TextStyle(color: AppColors.whiteColor, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}