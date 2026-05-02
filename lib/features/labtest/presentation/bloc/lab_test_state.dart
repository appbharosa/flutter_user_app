

import 'package:equatable/equatable.dart';

import '../../../../domain/entities/lab_test.dart';

abstract class LabTestState extends Equatable {
  const LabTestState();
  @override List<Object> get props => [];
}

class LabTestInitial extends LabTestState {}
class LabTestLoading extends LabTestState {}
class LabTestLoaded extends LabTestState {
  final List<LabTest> labTests;
  final bool hasMore;
  const LabTestLoaded(this.labTests, this.hasMore);
  @override List<Object> get props => [labTests, hasMore];
}
class LabTestError extends LabTestState {
  final String message;
  const LabTestError(this.message);
  @override List<Object> get props => [message];
}