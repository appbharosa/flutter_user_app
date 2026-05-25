import 'package:user/domain/entities/subscription_plans.dart';

import '../../domain/entities/dashboard.dart';
import '../../domain/entities/dashboard_banner.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/family_members.dart';
import '../../domain/entities/lab_charges.dart';
import '../../domain/entities/subscription_plan.dart';



class DashboardModel extends Dashboard {
  DashboardModel({
    required super.healthCardStatus,
    required super.banners,
    required super.categories,
    required super.subCategories,
    required super.pharmacyCategories,
    required super.labTestBanners,
    required super.mobile,
    required super.familyMembersCount,
    required super.familyMembers,
    required super.freeLabTestsUsed,
    required super.labCharges,
    required super.subscriptionPlan,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    return DashboardModel(
      healthCardStatus: result['health_card_status'] ?? 0,
      banners: (result['banners'] as List?)
          ?.map((b) => DashboardBanner(
        id: b['id'] ?? 0,
        image: b['image'] ?? '',
        position: b['position'] ?? '',
      ))
          .toList() ?? [],
      categories: (result['categories'] as List?)
          ?.map((c) => Category(
        id: c['id'] ?? 0,
        name: c['name'] ?? '',
        image: c['image'] ?? '',
      ))
          .toList() ?? [],
      subCategories: (result['sub_categories'] as List?)
          ?.map((c) => Category(
        id: c['id'] ?? 0,
        name: c['name'] ?? '',
        image: c['image'] ?? '',
      ))
          .toList() ?? [],
      pharmacyCategories: (result['pharmacy_categories'] as List?)
          ?.map((c) => Category(
        id: c['id'] ?? 0,
        name: c['name'] ?? '',
        image: c['image'] ?? '',
      ))
          .toList() ?? [],
      labTestBanners: (result['lab_test_banners'] as List?)
          ?.map((b) => DashboardBanner(
        id: b['id'] ?? 0,
        image: b['image'] ?? '',
        position: b['name'] ?? '',   // lab test banners use 'name' field as position
      ))
          .toList() ?? [],
      mobile: result['mobile']?.toString() ?? '',
      familyMembersCount: result['family_members_count'] ?? 0,
      familyMembers: (result['family_members'] as List?)
          ?.map((fm) => FamilyMembers(
        id: fm['id'] ?? 0,
        name: fm['name'] ?? '',
        type: fm['type']?.toString(),
        relationship: fm['relationship'] ?? '',
      ))
          .toList() ?? [],
      freeLabTestsUsed: result['free_lab_tests_used'] ?? [],
      labCharges: LabCharges(
        hygienicKitCharges: result['lab_charges']['hygienic_kit_charges']?.toString() ?? '0',
        hygienicKitDiscount: result['lab_charges']['hygienic_kit_discount']?.toString() ?? '0',
        sampleCollectionCharges: result['lab_charges']['sample_collection_charges']?.toString() ?? '0',
        sampleCollectionDiscount: result['lab_charges']['sample_collection_discount']?.toString() ?? '0',
      ),
      subscriptionPlan: result['subscription_plan'] != null && result['subscription_plan'] is Map<String, dynamic>
          ? SubscriptionPlans.fromJson(result['subscription_plan'])
          : null,
    );
  }
}