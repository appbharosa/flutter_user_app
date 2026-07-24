
import '../../data/models/hospital_doctor_booking_item_model.dart';

class HospitalDoctorBookingItem {
  final int id;
  final String bookingId;
  final String consultType;
  final int userId;
  final int catId;
  final int mainDataId;
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
  final String specialization;
  final String uniqueId;
  final String name;
  final String? image;
  final String qualification;
  final String? doctorSpecialization;
  final int exp;
  final int consultations;
  final String patientName;
  final String email;
  final String gender;
  final String dob;
  final List<Medicine> medicines;
  final List<Test> tests;
  final List<String> notes;

  HospitalDoctorBookingItem({
    required this.id,
    required this.bookingId,
    required this.consultType,
    required this.userId,
    required this.catId,
    required this.mainDataId,
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
    required this.specialization,
    required this.uniqueId,
    required this.name,
    this.image,
    required this.qualification,
    this.doctorSpecialization,
    required this.exp,
    required this.consultations,
    required this.patientName,
    required this.email,
    required this.gender,
    required this.dob,
    required this.medicines,
    required this.tests,
    required this.notes,
  });
}