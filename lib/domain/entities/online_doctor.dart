import 'package:equatable/equatable.dart';

import 'package:equatable/equatable.dart';

class OnlineDoctor extends Equatable {
  final int id;
  final String name;
  final String image;
  final int fee;
  final int availability;
  final String qualification;
  final String specialization;
  final double totalRating;
  final int totalReviews;

  const OnlineDoctor({
    required this.id,
    required this.name,
    required this.image,
    required this.fee,
    required this.availability,
    required this.qualification,
    required this.specialization,
    required this.totalRating,
    required this.totalReviews,
  });

  @override
  List<Object?> get props => [id, name, fee, specialization, totalRating];
}