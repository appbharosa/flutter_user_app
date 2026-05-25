import 'package:user/domain/entities/subscription_plan.dart';
import 'package:user/domain/entities/subscription_plans.dart';

import 'dashboard_banner.dart';
import 'category.dart';
import 'family_member.dart';
import 'family_members.dart';
import 'lab_charges.dart';



class Dashboard {
  final int healthCardStatus;
  final List<DashboardBanner> banners;        // changed
  final List<Category> categories;
  final List<Category> subCategories;
  final List<Category> pharmacyCategories;
  final List<DashboardBanner> labTestBanners; // changed
  final String mobile;
  final int familyMembersCount;
  final List<FamilyMembers> familyMembers;
  final List<dynamic> freeLabTestsUsed;
  final LabCharges labCharges;
  final SubscriptionPlans? subscriptionPlan;

  Dashboard({
    required this.healthCardStatus,
    required this.banners,
    required this.categories,
    required this.subCategories,
    required this.pharmacyCategories,
    required this.labTestBanners,
    required this.mobile,
    required this.familyMembersCount,
    required this.familyMembers,
    required this.freeLabTestsUsed,
    required this.labCharges,
    this.subscriptionPlan,
  });
}