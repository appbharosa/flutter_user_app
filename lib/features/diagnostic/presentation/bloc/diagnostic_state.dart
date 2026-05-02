

import 'package:equatable/equatable.dart';

import '../../../../domain/entities/diagnostic.dart';

abstract class DiagnosticState extends Equatable {
  const DiagnosticState();
  @override List<Object> get props => [];
}

class DiagnosticInitial extends DiagnosticState {}
class DiagnosticLoading extends DiagnosticState {}
class DiagnosticLoaded extends DiagnosticState {
  final List<Diagnostic> diagnostics;
  final bool hasMore;
  const DiagnosticLoaded(this.diagnostics, this.hasMore);
  @override List<Object> get props => [diagnostics, hasMore];
}
class DiagnosticError extends DiagnosticState {
  final String message;
  const DiagnosticError(this.message);
  @override List<Object> get props => [message];
}