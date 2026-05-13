

import 'package:equatable/equatable.dart';

abstract class LabCouponListEvent extends Equatable {
  const LabCouponListEvent();
  @override List<Object> get props => [];
}

class LoadLabCoupons extends LabCouponListEvent {}