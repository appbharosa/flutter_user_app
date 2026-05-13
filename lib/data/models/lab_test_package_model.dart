import '../../domain/entities/lab_test_package.dart';

class LabTestPackageModel extends LabTestPackage {
  const LabTestPackageModel({
    required super.id,
    required super.name,
    required super.onePerson,
    required super.onePersonDiscount,
    required super.twoPerson,
    required super.twoPersonDiscount,
    required super.threePerson,
    required super.threePersonDiscount,
    required super.fourPerson,
    required super.fourPersonDiscount,
    required super.fivePerson,
    required super.fivePersonDiscount,
    required super.reportIn,
    required super.fasting,
  });

  factory LabTestPackageModel.fromJson(Map<String, dynamic> json) {
    return LabTestPackageModel(
      id: json['id'],
      name: json['name'],
      onePerson: json['one_person'],
      onePersonDiscount: json['one_person_discount'],
      twoPerson: json['two_person'],
      twoPersonDiscount: json['two_person_discount'],
      threePerson: json['three_person'],
      threePersonDiscount: json['three_person_discount'],
      fourPerson: json['four_person'],
      fourPersonDiscount: json['four_person_discount'],
      fivePerson: json['five_person'],
      fivePersonDiscount: json['five_person_discount'],
      reportIn: json['report_in'],
      fasting: json['fasting'],
    );
  }
}