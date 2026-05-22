
part of 'add_family_bloc.dart';

abstract class AddFamilyEvent extends Equatable {
  const AddFamilyEvent();
  @override
  List<Object?> get props => [];
}

class SubmitAddFamily extends AddFamilyEvent {
  final AddFamilyMemberRequest request;
  const SubmitAddFamily(this.request);
  @override
  List<Object?> get props => [request];
}