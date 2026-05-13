import 'package:equatable/equatable.dart';

class LabTestPackage extends Equatable {
  final int id;
  final String name;
  final int onePerson;
  final int onePersonDiscount;
  final int twoPerson;
  final int twoPersonDiscount;
  final int threePerson;
  final int threePersonDiscount;
  final int fourPerson;
  final int fourPersonDiscount;
  final int fivePerson;
  final int fivePersonDiscount;
  final String reportIn;
  final String fasting;

  const LabTestPackage({
    required this.id,
    required this.name,
    required this.onePerson,
    required this.onePersonDiscount,
    required this.twoPerson,
    required this.twoPersonDiscount,
    required this.threePerson,
    required this.threePersonDiscount,
    required this.fourPerson,
    required this.fourPersonDiscount,
    required this.fivePerson,
    required this.fivePersonDiscount,
    required this.reportIn,
    required this.fasting,
  });

  int getEffectivePrice(int persons) {
    switch (persons) {
      case 1: return onePerson - onePersonDiscount;
      case 2: return twoPerson - twoPersonDiscount;
      case 3: return threePerson - threePersonDiscount;
      case 4: return fourPerson - fourPersonDiscount;
      case 5: return fivePerson - fivePersonDiscount;
      default: return onePerson;
    }
  }

  @override
  List<Object?> get props => [id];
}