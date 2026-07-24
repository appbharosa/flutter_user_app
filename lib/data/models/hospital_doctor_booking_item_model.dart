
import '../../domain/entities/hospital_doctor_booking_item.dart';

class HospitalDoctorBookingItemModel extends HospitalDoctorBookingItem {
  HospitalDoctorBookingItemModel({
    required super.id,
    required super.bookingId,
    required super.consultType,
    required super.userId,
    required super.catId,
    required super.mainDataId,
    required super.specialityId,
    required super.doctorId,
    required super.slotId,
    required super.time,
    required super.date,
    required super.mobile,
    required super.familyMemberId,
    required super.fee,
    required super.consultationFee,
    required super.couponId,
    required super.couponPercentage,
    required super.couponDiscount,
    required super.specialization,
    required super.uniqueId,
    required super.name,
    super.image,
    required super.qualification,
    super.doctorSpecialization,
    required super.exp,
    required super.consultations,
    required super.patientName,
    required super.email,
    required super.gender,
    required super.dob,
    required super.medicines,
    required super.tests,
    required super.notes,
  });

  factory HospitalDoctorBookingItemModel.fromJson(Map<String, dynamic> json) {
    final medicinesList = json['medicines'] as List? ?? [];
    final medicines = medicinesList.map((e) => Medicine.fromJson(e)).toList();

    // Parse nested tests
    final testsList = json['tests'] as List? ?? [];
    final tests = testsList.map((e) => Test.fromJson(e)).toList();

    // Parse notes (list of strings)
    final notesList = json['notes'] as List? ?? [];
    final notes = notesList.map((e) => e.toString()).toList();
    return HospitalDoctorBookingItemModel(
      id: _toInt(json['id']),
      bookingId: _toString(json['booking_id']),
      consultType: _toString(json['consult_type']),
      userId: _toInt(json['user_id']),
      catId: _toInt(json['cat_id']),
      mainDataId: _toInt(json['main_data_id']),
      specialityId: _toInt(json['speciality_id']),
      doctorId: _toInt(json['doctor_id']),
      slotId: _toInt(json['slot_id']),
      time: _toString(json['time']),
      date: _toString(json['date']),
      mobile: _toInt(json['mobile']),
      familyMemberId: _toInt(json['family_member_id']),
      fee: _toInt(json['fee']),
      consultationFee: _toInt(json['consultation_fee']),
      couponId: _toInt(json['coupon_id']),
      couponPercentage: _toInt(json['coupon_percentage']),
      couponDiscount: _toInt(json['coupon_discount']),
      specialization: _toString(json['specialization']),
      uniqueId: _toString(json['unique_id']),
      name: _toString(json['name']),
      image: json['image']?.toString(),
      qualification: _toString(json['qualification']),
      doctorSpecialization: json['doctor_specialization']?.toString(),
      exp: _toInt(json['exp']),
      consultations: _toInt(json['consultations']),
      patientName: _toString(json['patient_name']),
      email: _toString(json['email']),
      gender: _toString(json['gender']),
      dob: _toString(json['dob']),
      medicines: medicines,
      tests: tests,
      notes: notes,
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _toString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }
}

// ─── Medicine Model ──────────────────────────────────────────────────
class Medicine {
  final String medicine;
  final String medicineTime;

  Medicine({required this.medicine, required this.medicineTime});

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      medicine: json['medicine']?.toString() ?? '',
      medicineTime: json['medicine_time']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'medicine': medicine,
    'medicine_time': medicineTime,
  };
}

// ─── Test Model ─────────────────────────────────────────────────────
class Test {
  final String test;
  final String testInstruction;

  Test({required this.test, required this.testInstruction});

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      test: json['test']?.toString() ?? '',
      testInstruction: json['test_instruction']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'test': test,
    'test_instruction': testInstruction,
  };
}