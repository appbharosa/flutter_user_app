

import 'package:equatable/equatable.dart';
import '../../../../domain/entities/family_member.dart';

abstract class FamilyMembersState extends Equatable {
  const FamilyMembersState();
  @override List<Object> get props => [];
}

class FamilyMembersInitial extends FamilyMembersState {}
class FamilyMembersLoading extends FamilyMembersState {}
class FamilyMembersLoaded extends FamilyMembersState {
  final List<FamilyMember> members;
  const FamilyMembersLoaded(this.members);
  @override List<Object> get props => [members];
}
class FamilyMembersError extends FamilyMembersState {
  final String message;
  const FamilyMembersError(this.message);
}