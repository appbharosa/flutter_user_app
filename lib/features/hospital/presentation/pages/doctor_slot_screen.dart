import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/services/language_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/user_manager.dart';
import '../../../../domain/entities/hospital_doctor.dart';
import '../../../subscription/presentation/pages/subscriptions_page.dart';
import '../doctor_slots_bloc/doctor_slots_bloc.dart';
import 'doctor_booking_family_selection_screen.dart';


class DoctorSlotScreen extends StatefulWidget {
  final HospitalDoctor doctor;
  final int hospitalId;
  final int addressId;

  const DoctorSlotScreen({
    Key? key,
    required this.doctor,
    required this.hospitalId,
    required this.addressId,
  }) : super(key: key);

  @override
  State<DoctorSlotScreen> createState() => _DoctorSlotScreenState();
}

class _DoctorSlotScreenState extends State<DoctorSlotScreen> {
  late DoctorSlotsBloc _bloc;
  DateTime _selectedDate = DateTime.now();
  int? _selectedSlotId;
  String? _selectedSlotTime;
  String? _selectedDateFromResponse;
  String? _selectedFormattedDate;

  @override
  void initState() {
    super.initState();
    _bloc = di.sl<DoctorSlotsBloc>();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    final language = await LanguageService.getCurrentLanguage();
    final dateStr = _selectedDate.toIso8601String().split('T').first;
    _bloc.add(LoadDoctorSlots(
      doctorId: widget.doctor.id,
      language: language,
      date: dateStr,
    ));
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

  Future<void> _handleContinue() async {
    if (_selectedSlotId == null) return;

    // Check subscription status
    final hasSubscription = await UserManager.hasActiveSubscription();
    if (!hasSubscription) {
      // No active subscription → redirect to subscription page
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please subscribe to book this appointment'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SubscriptionPage()),
        );
      }
      return;
    }

    // Has subscription → proceed to family selection
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorBookingFamilySelectionScreen(
          doctor: widget.doctor,
          hospitalId: widget.hospitalId,
          addressId: widget.addressId,
          slotId: _selectedSlotId!,
          slotTime: _selectedSlotTime!,
          date: _selectedDate.toIso8601String().split('T').first,
          formattedDate: _selectedFormattedDate ?? _formatDate(_selectedDate),
          consultationFee: widget.doctor.consultationFee,
        ),
      ),
    );
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
              color: AppColors.whiteColor,
              fontSize: 17,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            _buildDoctorHeader(),
            // Date picker card
            Container(
              margin: const EdgeInsets.all(16),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Available Time Slots',
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<DoctorSlotsBloc, DoctorSlotsState>(
                builder: (context, state) {
                  if (state is DoctorSlotsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is DoctorSlotsError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(state.message),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadSlots,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state is DoctorSlotsLoaded) {
                    final slotsResponse = state.slots;
                    _selectedDateFromResponse = slotsResponse.date;
                    _selectedFormattedDate = slotsResponse.formattedDate;
                    final sessions = slotsResponse.sessions;
                    if (sessions.isEmpty) {
                      return const Center(child: Text('No slots available on this date'));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        final availableSlots = session.slots.where((s) => s.isAvailable && !s.isBooked).toList();
                        if (availableSlots.isEmpty) return const SizedBox();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Text(session.sessionIcon, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Text(
                                  session.session,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${session.availableSlots} slots left',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: availableSlots.map((slot) {
                                final isSelected = _selectedSlotId == slot.slotId;
                                return FilterChip(
                                  label: Text(slot.startTime, style: const TextStyle(fontFamily: 'Poppins')),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedSlotId = slot.slotId;
                                        _selectedSlotTime = slot.time;
                                      } else {
                                        _selectedSlotId = null;
                                        _selectedSlotTime = null;
                                      }
                                    });
                                  },
                                  backgroundColor: Colors.grey.shade100,
                                  selectedColor: AppColors.blue.withOpacity(0.2),
                                  labelStyle: TextStyle(
                                    color: isSelected ? AppColors.blue : Colors.black87,
                                  ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _selectedSlotId == null ? null : _handleContinue,
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.doctor.image,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 70),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctor.name,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.doctor.specialization,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qualification: ${widget.doctor.qualificationNames}',
                  style: const TextStyle(fontSize: 12, color: Colors.black, fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 4),
                Text(
                  'Experience: ${widget.doctor.experience} years',
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  'Fee: ₹${widget.doctor.consultationFee}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}