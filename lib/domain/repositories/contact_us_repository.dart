import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/contact_us_response.dart';

abstract class ContactUsRepository {
  Future<Either<Failure, ContactUsResponse>> submitContactUs({
    required int userId,
    required String name,
    required String email,
    required String mobile,
    required String message,
  });
}