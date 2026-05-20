class DoctorSlot {
  final int slotId;
  final String time;
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final bool isBooked;

  DoctorSlot({
    required this.slotId,
    required this.time,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    required this.isBooked,
  });
}

class DoctorSession {
  final String session;
  final String sessionIcon;
  final int totalSlots;
  final int availableSlots;
  final List<DoctorSlot> slots;

  DoctorSession({
    required this.session,
    required this.sessionIcon,
    required this.totalSlots,
    required this.availableSlots,
    required this.slots,
  });
}

class DoctorSlotsResponse {
  final String date;
  final String day;
  final String formattedDate;
  final int totalSessions;
  final int totalSlots;
  final List<DoctorSession> sessions;

  DoctorSlotsResponse({
    required this.date,
    required this.day,
    required this.formattedDate,
    required this.totalSessions,
    required this.totalSlots,
    required this.sessions,
  });
}