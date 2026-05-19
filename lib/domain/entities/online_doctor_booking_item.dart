
class OnlineDoctorBookingItem {
  final int id;
  final String bookingId;
  final String consultType;
  final int userId;
  final int specialityId;
  final int doctorId;
  final int slotId;
  final String time;
  final String date;
  final int mobile;
  final int familyMemberId;
  final int fee;
  final int consultationFee;
  final int couponId;
  final int couponPercentage;
  final int couponDiscount;
  final String? specialityName;
  final String uniqueId;
  final String name;
  final String image;
  final String qualification;
  final String specialization;
  final int exp;
  final int consultations;
  final String patientName;
  final String email;
  final String gender;
  final String dob;

  OnlineDoctorBookingItem({
    required this.id,
    required this.bookingId,
    required this.consultType,
    required this.userId,
    required this.specialityId,
    required this.doctorId,
    required this.slotId,
    required this.time,
    required this.date,
    required this.mobile,
    required this.familyMemberId,
    required this.fee,
    required this.consultationFee,
    required this.couponId,
    required this.couponPercentage,
    required this.couponDiscount,
    this.specialityName,
    required this.uniqueId,
    required this.name,
    required this.image,
    required this.qualification,
    required this.specialization,
    required this.exp,
    required this.consultations,
    required this.patientName,
    required this.email,
    required this.gender,
    required this.dob,
  });
}