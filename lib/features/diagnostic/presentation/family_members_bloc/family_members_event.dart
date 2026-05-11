

import 'package:equatable/equatable.dart';

abstract class FamilyMembersEvent extends Equatable {
  const FamilyMembersEvent();
  @override List<Object> get props => [];
}

class LoadFamilyMembers extends FamilyMembersEvent {}