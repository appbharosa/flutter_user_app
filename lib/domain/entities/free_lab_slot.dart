class FreeLabSlot {
  final int slotId;
  final String time;
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final bool isBooked;

  FreeLabSlot({
    required this.slotId,
    required this.time,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    required this.isBooked,
  });
}

class FreeLabSession {
  final String session;
  final String sessionIcon;
  final int totalSlots;
  final int availableSlots;
  final List<FreeLabSlot> slots;

  FreeLabSession({
    required this.session,
    required this.sessionIcon,
    required this.totalSlots,
    required this.availableSlots,
    required this.slots,
  });
}

class FreeLabSlotResponse {
  final String date;
  final String day;
  final String formattedDate;
  final int totalSessions;
  final int totalSlots;
  final List<FreeLabSession> sessions;

  FreeLabSlotResponse({
    required this.date,
    required this.day,
    required this.formattedDate,
    required this.totalSessions,
    required this.totalSlots,
    required this.sessions,
  });
}