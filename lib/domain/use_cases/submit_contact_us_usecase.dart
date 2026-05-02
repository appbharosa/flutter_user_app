import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/contact_us_response.dart';
import '../repositories/contact_us_repository.dart';

class SubmitContactUsParams {
  final int userId;
  final String name;
  final String email;
  final String mobile;
  final String message;

  SubmitContactUsParams({
    required this.userId,
    required this.name,
    required this.email,
    required this.mobile,
    required this.message,
  });
}

class SubmitContactUsUseCase {
  final ContactUsRepository repository;

  SubmitContactUsUseCase(this.repository);

  Future<Either<Failure, ContactUsResponse>> call(SubmitContactUsParams params) async {
    return await repository.submitContactUs(
      userId: params.userId,
      name: params.name,
      email: params.email,
      mobile: params.mobile,
      message: params.message,
    );
  }
}