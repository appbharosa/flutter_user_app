import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:user/features/pharmacy/presentation/pharmacy_category_bloc/pharmacy_category_bloc.dart';
import '../../data/data_sources/about_remote_datasource.dart';
import '../../data/data_sources/address_remote_datasource.dart';
import '../../data/data_sources/admission_remote_datasource.dart';
import '../../data/data_sources/ambulance_booking_remote_datasource.dart';
import '../../data/data_sources/auth_remote_datasource.dart';
import '../../data/data_sources/contact_us_remote_datasource.dart';
import '../../data/data_sources/coverage_category_remote_datasource.dart';
import '../../data/data_sources/dashboard_remote_datasource.dart';
import '../../data/data_sources/diagnostic_booking_fetch_remote_datasource.dart';
import '../../data/data_sources/diagnostic_booking_remote_datasource.dart';
import '../../data/data_sources/diagnostic_remote_datasource.dart';
import '../../data/data_sources/doctor_coupon_remote_datasource.dart';
import '../../data/data_sources/doctor_slots_remote_datasource.dart';
import '../../data/data_sources/ecard_remote_datasource.dart';
import '../../data/data_sources/family_member_remote_datasource.dart';
import '../../data/data_sources/family_remote_datasource.dart';
import '../../data/data_sources/free_lab_remote_datasource.dart';
import '../../data/data_sources/free_lab_report_remote_datasource.dart';
import '../../data/data_sources/hospital_booking_history_remote_datasource.dart';
import '../../data/data_sources/hospital_diagnostic_remote_datasource.dart';
import '../../data/data_sources/hospital_doctor_booking_history_remote_datasource.dart';
import '../../data/data_sources/hospital_filter_remote_datasource.dart';
import '../../data/data_sources/hospital_filtered_remote_datasource.dart';
import '../../data/data_sources/hospital_filters_remote_datasource.dart';
import '../../data/data_sources/hospital_main_data_remote_datasource.dart';
import '../../data/data_sources/hospital_pharmacy_booking_history_remote_datasource.dart';
import '../../data/data_sources/hospital_remote_datasource.dart';
import '../../data/data_sources/lab_cashfree_order_remote_datasource.dart';
import '../../data/data_sources/lab_coupon_remote_datasource.dart';
import '../../data/data_sources/lab_payment_booking_remote_datasource.dart';
import '../../data/data_sources/lab_slot_remote_datasource.dart';
import '../../data/data_sources/lab_test_booking_fetch_remote_datasource.dart';
import '../../data/data_sources/lab_test_booking_remote_datasource.dart';
import '../../data/data_sources/lab_test_category_remote_datasource.dart';
import '../../data/data_sources/lab_test_remote_datasource.dart';
import '../../data/data_sources/med_locker_remote_datasource.dart';
import '../../data/data_sources/medicine_booking_remote_datasource.dart';
import '../../data/data_sources/notification_remote_datasource.dart';
import '../../data/data_sources/online_doctor_booking_history_remote_datasource.dart';
import '../../data/data_sources/online_doctor_coupon_remote_datasource.dart';
import '../../data/data_sources/online_doctor_remote_datasource.dart';
import '../../data/data_sources/online_doctor_slot_remote_datasource.dart';
import '../../data/data_sources/online_doctor_speciality_remote_datasource.dart';
import '../../data/data_sources/order_remote_datasource.dart';
import '../../data/data_sources/payment_remote_datasource.dart';
import '../../data/data_sources/pharmacy_booking_history_remote_datasource.dart';
import '../../data/data_sources/pharmacy_remote_datasource.dart';
import '../../data/data_sources/profile_remote_datasource.dart';
import '../../data/data_sources/subscription_payment_remote_datasource.dart';
import '../../data/data_sources/subscription_remote_datasource.dart';
import '../../data/data_sources/user_local_datasource.dart';
import '../../data/repositories/about_repository_impl.dart';
import '../../data/repositories/address_repository_impl.dart';
import '../../data/repositories/admission_repository_impl.dart';
import '../../data/repositories/ambulance_booking_repository_impl.dart';
import '../../data/repositories/contact_us_repository_impl.dart';
import '../../data/repositories/coverage_category_repository_impl.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../data/repositories/diagnostic_booking_fetch_repository_impl.dart';
import '../../data/repositories/diagnostic_booking_repository_impl.dart';
import '../../data/repositories/diagnostic_repository_impl.dart';
import '../../data/repositories/doctor_coupon_repository_impl.dart';
import '../../data/repositories/doctor_slots_repository_impl.dart';
import '../../data/repositories/ecard_repository_impl.dart';
import '../../data/repositories/family_member_repository_impl.dart';
import '../../data/repositories/family_repository_impl.dart';
import '../../data/repositories/free_lab_report_repository_impl.dart';
import '../../data/repositories/free_lab_repository_impl.dart';
import '../../data/repositories/hospital_booking_history_repository_impl.dart';
import '../../data/repositories/hospital_diagnostic_repository_impl.dart';
import '../../data/repositories/hospital_doctor_booking_history_repository_impl.dart';
import '../../data/repositories/hospital_filter_repository_impl.dart';
import '../../data/repositories/hospital_filtered_repository_impl.dart';
import '../../data/repositories/hospital_filters_repository_impl.dart';
import '../../data/repositories/hospital_main_data_repository_impl.dart';
import '../../data/repositories/hospital_pharmacy_booking_history_repository_impl.dart';
import '../../data/repositories/hospital_repository_impl.dart';
import '../../data/repositories/lab_cashfree_order_repository_impl.dart';
import '../../data/repositories/lab_coupon_repository_impl.dart';
import '../../data/repositories/lab_payment_booking_repository_impl.dart';
import '../../data/repositories/lab_slot_repository_impl.dart';
import '../../data/repositories/lab_test_booking_fetch_repository_impl.dart';
import '../../data/repositories/lab_test_booking_repository_impl.dart';
import '../../data/repositories/lab_test_category_remote_datasource_impl.dart';
import '../../data/repositories/lab_test_category_repository_impl.dart';
import '../../data/repositories/lab_test_repository_impl.dart';
import '../../data/repositories/med_locker_repository_impl.dart';
import '../../data/repositories/medicine_booking_repository_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/repositories/online_doctor_booking_history_repository_impl.dart';
import '../../data/repositories/online_doctor_coupon_repository_impl.dart';
import '../../data/repositories/online_doctor_repository_impl.dart';
import '../../data/repositories/online_doctor_slot_repository_impl.dart';
import '../../data/repositories/online_doctor_speciality_repository_impl.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../data/repositories/pharmacy_booking_history_repository_impl.dart';
import '../../data/repositories/pharmacy_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/repositories/subscription_payment_repository_impl.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/repositories/about_repository.dart';
import '../../domain/repositories/address_repository.dart';
import '../../domain/repositories/admission_repository.dart';
import '../../domain/repositories/ambulance_booking_repository.dart';
import '../../domain/repositories/contact_us_repository.dart';
import '../../domain/repositories/coverage_category_repository.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/repositories/diagnostic_booking_fetch_repository.dart';
import '../../domain/repositories/diagnostic_booking_repository.dart';
import '../../domain/repositories/diagnostic_repository.dart';
import '../../domain/repositories/doctor_coupon_repository.dart';
import '../../domain/repositories/doctor_slots_repository.dart';
import '../../domain/repositories/ecard_repository.dart';
import '../../domain/repositories/family_member_repository.dart';
import '../../domain/repositories/family_repository.dart';
import '../../domain/repositories/free_lab_report_repository.dart';
import '../../domain/repositories/free_lab_repository.dart';
import '../../domain/repositories/hospital_booking_history_repository.dart';
import '../../domain/repositories/hospital_diagnostic_repository.dart';
import '../../domain/repositories/hospital_doctor_booking_history_repository.dart';
import '../../domain/repositories/hospital_filter_repository.dart';
import '../../domain/repositories/hospital_filtered_repository.dart';
import '../../domain/repositories/hospital_filters_repository.dart';
import '../../domain/repositories/hospital_main_data_repository.dart';
import '../../domain/repositories/hospital_pharmacy_booking_history_repository.dart';
import '../../domain/repositories/hospital_repository.dart';
import '../../domain/repositories/lab_cashfree_order_repository.dart';
import '../../domain/repositories/lab_coupon_repository.dart';
import '../../domain/repositories/lab_payment_booking_repository.dart';
import '../../domain/repositories/lab_slot_repository.dart';
import '../../domain/repositories/lab_test_booking_fetch_repository.dart';
import '../../domain/repositories/lab_test_booking_repository.dart';
import '../../domain/repositories/lab_test_category_repository.dart';
import '../../domain/repositories/lab_test_repository.dart';
import '../../domain/repositories/med_locker_repository.dart';
import '../../domain/repositories/medicine_booking_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/online_doctor_booking_history_repository.dart';
import '../../domain/repositories/online_doctor_coupon_repository.dart';
import '../../domain/repositories/online_doctor_repository.dart';
import '../../domain/repositories/online_doctor_slot_repository.dart';
import '../../domain/repositories/online_doctor_speciality_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/repositories/pharmacy_booking_history_repository.dart';
import '../../domain/repositories/pharmacy_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/subscription_payment_repository.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../domain/use_cases/add_address_usecase.dart';
import '../../domain/use_cases/add_family_member.dart';
import '../../domain/use_cases/add_med_locker_usecase.dart';
import '../../domain/use_cases/apply_doctor_coupon.dart';
import '../../domain/use_cases/apply_lab_coupon_usecase.dart';
import '../../domain/use_cases/apply_online_doctor_coupon_usecase.dart';
import '../../domain/use_cases/book_ambulance.dart';
import '../../domain/use_cases/book_diagnostic_usecase.dart';
import '../../domain/use_cases/book_hospital_diagnostic.dart';
import '../../domain/use_cases/book_medicine_usecase.dart';
import '../../domain/use_cases/check_payment_status_usecase.dart';
import '../../domain/use_cases/create_cashfree_order_usecase.dart';
import '../../domain/use_cases/create_lab_cashfree_order_usecase.dart';
import '../../domain/use_cases/create_lab_payment_booking_usecase.dart';
import '../../domain/use_cases/create_lab_test_order_usecase.dart';
import '../../domain/use_cases/create_order_usecase.dart';
import '../../domain/use_cases/create_subscription_order_usecase.dart';
import '../../domain/use_cases/get_about_usecase.dart';
import '../../domain/use_cases/get_addresses_usecase.dart';
import '../../domain/use_cases/get_booking_fetch_detail_usecase.dart';
import '../../domain/use_cases/get_completed_fetch_bookings_usecase.dart';
import '../../domain/use_cases/get_completed_lab_test_bookings_usecase.dart';
import '../../domain/use_cases/get_coverage_categories.dart';
import '../../domain/use_cases/get_dashboard.dart';
import '../../domain/use_cases/get_diagnostics_usecase.dart';
import '../../domain/use_cases/get_doctor_coupons.dart';
import '../../domain/use_cases/get_doctor_slots.dart';
import '../../domain/use_cases/get_ecard.dart';
import '../../domain/use_cases/get_family_members_usecase.dart';
import '../../domain/use_cases/get_filtered_hospitals_usecase.dart';
import '../../domain/use_cases/get_free_lab_packages.dart';
import '../../domain/use_cases/get_free_lab_reports.dart';
import '../../domain/use_cases/get_free_lab_slots.dart';
import '../../domain/use_cases/get_hospital_diagnostic_bookings.dart';
import '../../domain/use_cases/get_hospital_doctor_bookings.dart';
import '../../domain/use_cases/get_hospital_filters_usecase.dart';
import '../../domain/use_cases/get_hospital_main_data_usecase.dart';
import '../../domain/use_cases/get_hospital_pharmacy_bookings.dart';
import '../../domain/use_cases/get_hospitals_usecase.dart';
import '../../domain/use_cases/get_lab_coupons_usecase.dart';
import '../../domain/use_cases/get_lab_slots_usecase.dart';
import '../../domain/use_cases/get_lab_test_booking_detail_usecase.dart';
import '../../domain/use_cases/get_lab_test_categories.dart';
import '../../domain/use_cases/get_lab_tests_usecase.dart';
import '../../domain/use_cases/get_notifications.dart';
import '../../domain/use_cases/get_ongoing_fetch_bookings_usecase.dart';
import '../../domain/use_cases/get_ongoing_lab_test_bookings_usecase.dart';
import '../../domain/use_cases/get_online_doctor_bookings.dart';
import '../../domain/use_cases/get_online_doctor_coupons_usecase.dart';
import '../../domain/use_cases/get_online_doctor_slots_usecase.dart';
import '../../domain/use_cases/get_online_doctor_specialities_usecase.dart';
import '../../domain/use_cases/get_online_doctors_usecase.dart';
import '../../domain/use_cases/get_packages_by_category_id.dart';
import '../../domain/use_cases/get_pharmacies_usecase.dart';
import '../../domain/use_cases/get_pharmacy_bookings.dart';
import '../../domain/use_cases/get_pharmacy_categories.dart';
import '../../domain/use_cases/get_pharmacy_products.dart';
import '../../domain/use_cases/get_profile_usecase.dart';
import '../../domain/use_cases/get_subscription_plans_usecase.dart';
import '../../domain/use_cases/get_unread_count.dart';
import '../../domain/use_cases/get_user_subscription.dart';
import '../../domain/use_cases/login_usecase.dart';
import '../../domain/use_cases/mark_notification_read.dart';
import '../../domain/use_cases/mark_notifications_read.dart';
import '../../domain/use_cases/register_user_usecase.dart';
import '../../domain/use_cases/submit_admission.dart';
import '../../domain/use_cases/submit_contact_us_usecase.dart';
import '../../domain/use_cases/submit_subscription_usecase.dart';
import '../../domain/use_cases/update_profile_usecase.dart';
import '../../domain/use_cases/verify_otp_usecase.dart';
import '../../features/about/presentation/bloc/about_bloc.dart';
import '../../features/admission/bloc/admission_bloc.dart';
import '../../features/contact_us/presentation/bloc/contact_us_bloc.dart';
import '../../features/diagnostic/presentation/bloc/diagnostic_bloc.dart';
import '../../features/diagnostic/presentation/diagnostic_booking_bloc/diagnostic_booking_bloc.dart';
import '../../features/diagnostic/presentation/diagnostic_booking_fetch_detail_bloc/diagnostic_booking_fetch_detail_bloc.dart';
import '../../features/diagnostic/presentation/diagnostic_bookings_bloc/diagnostic_booking_fetch_list_bloc.dart';
import '../../features/diagnostic/presentation/family_members_bloc/family_members_bloc.dart';
import '../../features/ecard/presentation/bloc/ecard_bloc.dart';
import '../../features/free_lab/presentation/bloc/free_lab_booking_bloc/free_lab_booking_bloc.dart';
import '../../features/free_lab/presentation/bloc/free_lab_packages_bloc/free_lab_packages_bloc.dart';
import '../../features/free_lab/presentation/bloc/free_lab_slots_bloc/free_lab_slots_bloc.dart';
import '../../features/free_lab/presentation/free_lab_report_bloc/free_lab_report_bloc.dart';
import '../../features/free_lab/presentation/lab_test_category_bloc/lab_test_category_bloc.dart';
import '../../features/free_lab/presentation/lab_test_subcategory_bloc/lab_test_subcategory_bloc.dart';
import '../../features/home/presentation/address_bloc/address_bloc.dart';
import '../../features/home/presentation/dashboard_bloc/dashboard_bloc.dart';
import '../../features/hospital/presentation/ambulance_booking_bloc/ambulance_booking_bloc.dart';
import '../../features/hospital/presentation/bloc/filtered_hospitals_bloc/filtered_hospitals_bloc.dart';
import '../../features/hospital/presentation/bloc/hospital_bloc.dart';
import '../../features/hospital/presentation/bloc/hospital_diagnostic_booking_bloc/hospital_diagnostic_booking_bloc.dart';
import '../../features/hospital/presentation/doctor_booking_bloc/doctor_booking_bloc.dart';
import '../../features/hospital/presentation/doctor_coupon_bloc/doctor_coupon_bloc.dart';
import '../../features/hospital/presentation/doctor_slots_bloc/doctor_slots_bloc.dart';
import '../../features/hospital/presentation/hospital_booking_history_bloc/hospital_booking_history_bloc.dart';
import '../../features/hospital/presentation/hospital_doctor_booking_history_bloc/hospital_doctor_booking_history_bloc.dart';
import '../../features/hospital/presentation/hospital_filters_bloc/hospital_filters_bloc.dart';
import '../../features/hospital/presentation/hospital_main_data_bloc/hospital_main_data_bloc.dart';
import '../../features/hospital/presentation/hospital_pharmacy_booking_history_bloc/hospital_pharmacy_booking_history_bloc.dart';
import '../../features/hospital/presentation/medicine_booking_bloc/medicine_booking_bloc.dart';
import '../../features/labtest/presentation/apply_lab_coupon_bloc/apply_lab_coupon_bloc.dart';
import '../../features/labtest/presentation/bloc/lab_test_bloc.dart';
import '../../features/labtest/presentation/lab_coupon_list_bloc/lab_coupon_list_bloc.dart';
import '../../features/labtest/presentation/lab_payment_booking_bloc/lab_payment_booking_bloc.dart';
import '../../features/labtest/presentation/lab_slot_bloc/lab_slot_bloc.dart';
import '../../features/labtest/presentation/lab_test_booking_bloc/lab_test_booking_bloc.dart';
import '../../features/labtest/presentation/lab_test_booking_fetch_detail_bloc/lab_test_booking_fetch_detail_bloc.dart';
import '../../features/labtest/presentation/lab_test_booking_fetch_list_bloc/lab_test_booking_fetch_list_bloc.dart';
import '../../features/language/bloc/language_bloc.dart';
import '../../features/medlocker/presentation/bloc/med_locker_bloc.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../../features/online_doctor/presentation/bloc/online_doctor_bloc.dart';
import '../../features/online_doctor/presentation/online_doctor_apply_coupon_bloc/online_doctor_apply_coupon_bloc.dart';
import '../../features/online_doctor/presentation/online_doctor_booking_bloc/online_doctor_booking_bloc.dart';
import '../../features/online_doctor/presentation/online_doctor_booking_history_bloc/online_doctor_booking_history_bloc.dart';
import '../../features/online_doctor/presentation/online_doctor_coupon_bloc/online_doctor_coupon_bloc.dart';
import '../../features/online_doctor/presentation/online_doctor_slot_bloc/online_doctor_slot_bloc.dart';
import '../../features/online_doctor/presentation/online_doctor_speciality_bloc/online_doctor_speciality_bloc.dart';
import '../../features/otp/presentation/bloc/otp_verification_bloc.dart';
import '../../features/pharmacy/presentation/bloc/pharmacy_bloc.dart';
import '../../features/pharmacy/presentation/confirm_bloc/order_bloc.dart';
import '../../features/pharmacy/presentation/pharmacy_booking_history_bloc/pharmacy_booking_history_bloc.dart';
import '../../features/profile/presentation/add_family_bloc/add_family_bloc.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/coverage_category_bloc/coverage_category_bloc.dart';
import '../../features/registration/presentation/bloc/registration_bloc.dart';
import '../../features/subscription/presentation/bloc/subscription_bloc.dart';
import '../../features/subscription/presentation/create_order_bloc/subscription_payment_bloc.dart';
import '../../features/subscription/presentation/subscription_status_bloc/subscription_status_bloc.dart';
import '../../features/wallet/presentation/bloc/payment_bloc.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../services/cashfree_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ========== Core ==========
  sl.registerLazySingleton(() => DioClient());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(Connectivity()));
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => CashfreeService());
  sl.registerLazySingleton<LabCouponRemoteDataSource>(() => LabCouponRemoteDataSourceImpl(sl()));


  // ========== Data Sources ==========
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<UserLocalDataSource>(() => UserLocalDataSourceImpl(secureStorage: sl()));
  sl.registerLazySingleton<AboutRemoteDataSource>(() => AboutRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<ContactUsRemoteDataSource>(() => ContactUsRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<ProfileRemoteDataSource>(() => ProfileRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<AddressRemoteDataSource>(() => AddressRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<PharmacyRemoteDataSource>(() => PharmacyRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<HospitalRemoteDataSource>(() => HospitalRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<LabTestRemoteDataSource>(() => LabTestRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<DiagnosticRemoteDataSource>(() => DiagnosticRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<MedLockerRemoteDataSource>(() => MedLockerRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<OrderRemoteDataSource>(() => OrderRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<PaymentRemoteDataSource>(() => PaymentRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<SubscriptionRemoteDataSource>(() => SubscriptionRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<SubscriptionPaymentRemoteDataSource>(() => SubscriptionPaymentRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<FamilyMemberRemoteDataSource>(() => FamilyMemberRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<DiagnosticBookingRemoteDataSource>(() => DiagnosticBookingRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<DiagnosticBookingFetchRemoteDataSource>(() => DiagnosticBookingFetchRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<LabTestBookingRemoteDataSource>(() => LabTestBookingRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<LabTestBookingFetchRemoteDataSource>(() => LabTestBookingFetchRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<LabCashfreeOrderRemoteDataSource>(() => LabCashfreeOrderRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<HospitalFiltersRemoteDataSource>(() => HospitalFiltersRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<HospitalFilterRemoteDataSource>(() => HospitalFilterRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<OnlineDoctorRemoteDataSource>(() => OnlineDoctorRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<OnlineDoctorSpecialityRemoteDataSource>(() => OnlineDoctorSpecialityRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<OnlineDoctorSlotRemoteDataSource>(() => OnlineDoctorSlotRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<OnlineDoctorCouponRemoteDataSource>(() => OnlineDoctorCouponRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<HospitalFilteredRemoteDataSource>(() => HospitalFilteredRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<HospitalMainDataRemoteDataSource>(() => HospitalMainDataRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<MedicineBookingRemoteDataSource>(() => MedicineBookingRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<HospitalDiagnosticRemoteDataSource>(() => HospitalDiagnosticRemoteDataSourceImpl(sl()),);
  sl.registerLazySingleton<HospitalBookingHistoryRemoteDataSource>(() => HospitalBookingHistoryRemoteDataSourceImpl(dioClient: sl()),);
  sl.registerLazySingleton<HospitalPharmacyBookingHistoryRemoteDataSource>(() => HospitalPharmacyBookingHistoryRemoteDataSourceImpl(sl()),);
  sl.registerLazySingleton<HospitalDoctorBookingHistoryRemoteDataSource>(() => HospitalDoctorBookingHistoryRemoteDataSourceImpl(dioClient: sl()),);
  sl.registerLazySingleton<AmbulanceBookingRemoteDataSource>(() => AmbulanceBookingRemoteDataSourceImpl(dioClient: sl()),);
  sl.registerLazySingleton<PharmacyBookingHistoryRemoteDataSource>(() => PharmacyBookingHistoryRemoteDataSourceImpl(dioClient: sl()),);
  sl.registerLazySingleton<ECardRemoteDataSource>(() => ECardRemoteDataSourceImpl(dioClient: sl()),);
  sl.registerLazySingleton<OnlineDoctorBookingHistoryRemoteDataSource>(() => OnlineDoctorBookingHistoryRemoteDataSourceImpl(dioClient: sl()),);
  sl.registerLazySingleton<DoctorSlotsRemoteDataSource>(() => DoctorSlotsRemoteDataSourceImpl(dioClient: sl()),);
  sl.registerLazySingleton<DoctorCouponRemoteDataSource>(() => DoctorCouponRemoteDataSourceImpl(dioClient: sl()),);
  sl.registerLazySingleton<NotificationRemoteDataSource>(() => NotificationRemoteDataSourceImpl(sl()),);
  sl.registerLazySingleton<FamilyRemoteDataSource>(() => FamilyRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<CoverageCategoryRemoteDataSource>(() => CoverageCategoryRemoteDataSourceImpl(sl()),);
  sl.registerLazySingleton<DashboardRemoteDataSource>(() => DashboardRemoteDataSourceImpl( sl()),);
  sl.registerLazySingleton<FreeLabRemoteDataSource>(() => FreeLabRemoteDataSourceImpl( sl()),);
  sl.registerLazySingleton<FreeLabReportRemoteDataSource>(() => FreeLabReportRemoteDataSourceImpl(sl<DioClient>()),);
  sl.registerLazySingleton<AdmissionRemoteDataSource>(() => AdmissionRemoteDataSourceImpl(sl<DioClient>()),);
  sl.registerLazySingleton<LabTestCategoryRemoteDataSource>(() => LabTestCategoryRemoteDataSourceImpl(sl<DioClient>()),
  );

  // ========== Repositories ==========
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
    remoteDataSource: sl(),
    localDataSource: sl(),
    networkInfo: sl(),
  ));

  sl.registerLazySingleton<AboutRepository>(() => AboutRepositoryImpl(
    remoteDataSource: sl(),
    networkInfo: sl(),
  ));
  sl.registerLazySingleton<ContactUsRepository>(() => ContactUsRepositoryImpl(
    remoteDataSource: sl(),
    networkInfo: sl(),
  ));
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(
    remoteDataSource: sl(),
    networkInfo: sl(),
  ));
  sl.registerLazySingleton<AddressRepository>(() => AddressRepositoryImpl(
    remoteDataSource: sl(),
    networkInfo: sl(),
  ));
  sl.registerLazySingleton<PharmacyRepository>(() => PharmacyRepositoryImpl(
    remoteDataSource: sl(),
    networkInfo: sl(),
  ));
  sl.registerLazySingleton<HospitalRepository>(() => HospitalRepositoryImpl(
    remoteDataSource: sl(),
    networkInfo: sl(),
  ));
  sl.registerLazySingleton<LabTestRepository>(() => LabTestRepositoryImpl(
    remoteDataSource: sl(),
    networkInfo: sl(),
  ));
  sl.registerLazySingleton<DiagnosticRepository>(() => DiagnosticRepositoryImpl(
    remoteDataSource: sl(),
    networkInfo: sl(),
  ));

  sl.registerLazySingleton<MedLockerRepository>(() => MedLockerRepositoryImpl(
    remoteDataSource: sl(),
    networkInfo: sl(),
  ));
  sl.registerLazySingleton<OrderRepository>(() => OrderRepositoryImpl(
    remoteDataSource: sl(),
    networkInfo: sl(),
  ));
  sl.registerLazySingleton<PaymentRepository>(() => PaymentRepositoryImpl(
    remoteDataSource: sl(),
    networkInfo: sl(),
  ));
  sl.registerLazySingleton<SubscriptionRepository>(() => SubscriptionRepositoryImpl(
    remoteDataSource: sl(),
    networkInfo: sl(),
  ));
  sl.registerLazySingleton<SubscriptionPaymentRepository>(() => SubscriptionPaymentRepositoryImpl(
    remoteDataSource: sl(),
    networkInfo: sl(),
  ));
  sl.registerLazySingleton<FamilyMemberRepository>(() => FamilyMemberRepositoryImpl(
      remoteDataSource: sl(), networkInfo: sl()));
  sl.registerLazySingleton<DiagnosticBookingRepository>(() => DiagnosticBookingRepositoryImpl(
      remoteDataSource: sl(), networkInfo: sl()));
  sl.registerLazySingleton<DiagnosticBookingFetchRepository>(() => DiagnosticBookingFetchRepositoryImpl(
    remoteDataSource: sl(),
    networkInfo: sl(),
  ));
  sl.registerLazySingleton<LabTestBookingRepository>(() => LabTestBookingRepositoryImpl(
    remoteDataSource: sl(),
    networkInfo: sl(),
  ));
  sl.registerLazySingleton<LabTestBookingFetchRepository>(() => LabTestBookingFetchRepositoryImpl(
    remoteDataSource: sl(),
    networkInfo: sl(),
  ));
  sl.registerLazySingleton<LabSlotRemoteDataSource>(() => LabSlotRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<LabSlotRepository>(() => LabSlotRepositoryImpl(
    remoteDataSource: sl(),
    networkInfo: sl(),
  ));sl.registerLazySingleton<LabCouponRepository>(() => LabCouponRepositoryImpl(
    remoteDataSource: sl(),
    networkInfo: sl(),
  ));
  sl.registerLazySingleton<LabPaymentBookingRemoteDataSource>(() => LabPaymentBookingRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<LabPaymentBookingRepository>(() => LabPaymentBookingRepositoryImpl(
    remoteDataSource: sl(),
    networkInfo: sl(),
  ));
  sl.registerLazySingleton<LabCashfreeOrderRepository>(() => LabCashfreeOrderRepositoryImpl(
    remoteDataSource: sl(),
    networkInfo: sl(),
  ));
  sl.registerLazySingleton<HospitalFiltersRepository>(() => HospitalFiltersRepositoryImpl(
    remoteDataSource: sl(),
    networkInfo: sl(),
  ));
 sl.registerLazySingleton<HospitalFilterRepository>(() => HospitalFilterRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()));
  sl.registerLazySingleton<OnlineDoctorRepository>(() => OnlineDoctorRepositoryImpl(
    remoteDataSource: sl(),
    networkInfo: sl(),
  ));
  sl.registerLazySingleton<OnlineDoctorSpecialityRepository>(() => OnlineDoctorSpecialityRepositoryImpl(
    remoteDataSource: sl(),
    networkInfo: sl(),
  ));
  sl.registerLazySingleton<OnlineDoctorSlotRepository>(() => OnlineDoctorSlotRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()));
  sl.registerLazySingleton<OnlineDoctorCouponRepository>(() => OnlineDoctorCouponRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()));
  sl.registerLazySingleton<HospitalFilteredRepository>(() => HospitalFilteredRepositoryImpl(
    remoteDataSource: sl(),
    networkInfo: sl(),
  ));
  sl.registerLazySingleton<HospitalMainDataRepository>(() => HospitalMainDataRepositoryImpl(
    remoteDataSource: sl(),
    networkInfo: sl(),
  ));
  sl.registerLazySingleton<MedicineBookingRepository>(() => MedicineBookingRepositoryImpl(
    remoteDataSource: sl(),
    networkInfo: sl(),
  ));
  sl.registerLazySingleton<HospitalDiagnosticRepository>(
        () => HospitalDiagnosticRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<HospitalBookingHistoryRepository>(() => HospitalBookingHistoryRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<HospitalPharmacyBookingHistoryRepository>(() => HospitalPharmacyBookingHistoryRepositoryImpl(remoteDataSource: sl(), networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<HospitalDoctorBookingHistoryRepository>(() => HospitalDoctorBookingHistoryRepositoryImpl(
    remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<AmbulanceBookingRepository>(() => AmbulanceBookingRepositoryImpl(remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<PharmacyBookingHistoryRepository>(() => PharmacyBookingHistoryRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<ECardRepository>(() => ECardRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<OnlineDoctorBookingHistoryRepository>(() => OnlineDoctorBookingHistoryRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<DoctorSlotsRepository>(() => DoctorSlotsRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<DoctorCouponRepository>(() => DoctorCouponRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<NotificationRepository>(
        () => NotificationRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<FamilyRepository>(() => FamilyRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()));
  sl.registerLazySingleton<CoverageCategoryRepository>(() => CoverageCategoryRepositoryImpl(sl<CoverageCategoryRemoteDataSource>()),);
  sl.registerLazySingleton<DashboardRepository>(() => DashboardRepositoryImpl(remoteDataSource: sl(), networkInfo: sl(),),
  );
  sl.registerLazySingleton<FreeLabRepository>(() => FreeLabRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),);
  sl.registerLazySingleton<FreeLabReportRepository>(() => FreeLabReportRepositoryImpl(sl<FreeLabReportRemoteDataSource>()),);
  sl.registerLazySingleton<AdmissionRepository>(() => AdmissionRepositoryImpl(sl<AdmissionRemoteDataSource>()),);
  sl.registerLazySingleton<LabTestCategoryRepository>(() => LabTestCategoryRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );


  // ========== Use Cases ==========
  sl.registerLazySingleton(() => SendOtpUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetAboutUseCase(sl()));
  sl.registerLazySingleton(() => SubmitContactUsUseCase(sl()));
  sl.registerLazySingleton(() => GetAddressesUseCase(sl()));
  sl.registerLazySingleton(() => AddAddressUseCase(sl()));
  sl.registerLazySingleton(() => GetPharmaciesUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUserUseCase(sl()));
  sl.registerLazySingleton(() => GetHospitalsUseCase(sl()));
  sl.registerLazySingleton(() => GetLabTestsUseCase(sl()));
  sl.registerLazySingleton(() => GetDiagnosticsUseCase(sl()));
  sl.registerLazySingleton(() => GetMedLockersUseCase(sl<MedLockerRepository>()));
  sl.registerLazySingleton(() => GetMedLockerDetailUseCase(sl<MedLockerRepository>()));
  sl.registerLazySingleton(() => AddMedLockerUseCase(sl<MedLockerRepository>()));
  sl.registerLazySingleton(() => CreateOrderUseCase(sl()));
  sl.registerLazySingleton(() => CreateCashfreeOrderUseCase(sl()));
  sl.registerLazySingleton(() => CheckPaymentStatusUseCase(sl()));
  sl.registerLazySingleton(() => GetSubscriptionPlansUseCase(sl()));
  sl.registerLazySingleton(() => CreateSubscriptionOrderUseCase(sl()));
  sl.registerLazySingleton(() => SubmitSubscriptionUseCase(sl()));
  sl.registerLazySingleton(() => GetFamilyMembersUseCase(sl()));
  sl.registerLazySingleton(() => BookDiagnosticUseCase(sl()));
  sl.registerLazySingleton(() => GetOngoingFetchBookingsUseCase(sl()));
  sl.registerLazySingleton(() => GetCompletedFetchBookingsUseCase(sl()));
  sl.registerLazySingleton(() => GetBookingFetchDetailUseCase(sl()));
  sl.registerLazySingleton(() => CreateLabTestOrderUseCase(sl()));
  sl.registerLazySingleton(() => GetOngoingLabTestBookingsUseCase(sl()));
  sl.registerLazySingleton(() => GetCompletedLabTestBookingsUseCase(sl()));
  sl.registerLazySingleton(() => GetLabTestBookingDetailUseCase(sl()));
  sl.registerLazySingleton(() => GetLabSlotsUseCase(sl()));
  sl.registerLazySingleton(() => GetLabCouponsUseCase(sl()));
  sl.registerLazySingleton(() => ApplyLabCouponUseCase(sl()));
  sl.registerLazySingleton(() => CreateLabPaymentBookingUseCase(sl()));
  sl.registerLazySingleton(() => CreateLabCashfreeOrderUseCase(sl()));
  sl.registerLazySingleton(() => GetHospitalFiltersUseCase(sl()));
  sl.registerLazySingleton(() => GetOnlineDoctorsUseCase(sl()));
  sl.registerLazySingleton(() => GetTotalPagesUseCase(sl<OnlineDoctorRepository>())); // new
  sl.registerLazySingleton(() => ClearDoctorCacheUseCase(sl<OnlineDoctorRepository>()));
  sl.registerLazySingleton(() => GetOnlineDoctorSpecialitiesUseCase(sl()));
  sl.registerLazySingleton(() => GetOnlineDoctorSlotsUseCase(sl()));
  sl.registerLazySingleton(() => GetOnlineDoctorCouponsUseCase(sl()));
  sl.registerLazySingleton(() => ApplyOnlineDoctorCouponUseCase(sl()));
  sl.registerLazySingleton(() => GetFilteredHospitalsUseCase(sl()));
  sl.registerLazySingleton(() => GetHospitalMainDataUseCase(sl()));
  sl.registerLazySingleton(() => BookMedicineUseCase(sl()));
  sl.registerLazySingleton(() => BookHospitalDiagnosticUseCase(sl()));
  sl.registerLazySingleton(() => GetHospitalDiagnosticBookingsUseCase(sl()));
  sl.registerLazySingleton(() => GetHospitalPharmacyBookingsUseCase(sl()));
  sl.registerLazySingleton(() => GetHospitalDoctorBookingsUseCase(sl()));
  sl.registerLazySingleton(() => BookAmbulanceUseCase(sl()));
  sl.registerLazySingleton(() => GetPharmacyBookingsUseCase(sl()));
  sl.registerLazySingleton(() => GetECardUseCase(sl()));
  sl.registerLazySingleton(() => GetOnlineDoctorBookingsUseCase(sl()));
  sl.registerLazySingleton(() => GetDoctorSlotsUseCase(sl()));
  sl.registerLazySingleton(() => GetDoctorCouponsUseCase(sl()));
  sl.registerLazySingleton(() => ApplyDoctorCouponUseCase(sl()));
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => GetUnreadCountUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllNotificationsReadUseCase(sl()));
  sl.registerLazySingleton(() => AddFamilyMemberUseCase(sl()));
  sl.registerLazySingleton(() => GetCoverageCategories(sl()));
  sl.registerLazySingleton(() => GetDashboardUseCase(sl()));
  sl.registerLazySingleton(() => GetFreeLabPackagesUseCase(sl()));
  sl.registerLazySingleton(() => GetFreeLabSlotsUseCase(sl()));
  sl.registerLazySingleton(() => GetUserSubscriptionUseCase(sl()));
  sl.registerLazySingleton(() => GetFreeLabReports(sl<FreeLabReportRepository>()));
  sl.registerLazySingleton(() => SubmitAdmission(sl<AdmissionRepository>()));
  sl.registerLazySingleton(() => GetLabTestCategories(sl<LabTestCategoryRepository>()));
  sl.registerLazySingleton(() => GetPackagesByCategoryId(sl<FreeLabRepository>()));
  sl.registerLazySingleton(() => GetPharmacyCategories(sl<PharmacyRepository>()));
  sl.registerLazySingleton(() => GetPharmacyProducts(sl<PharmacyRepository>()));


  // ========== BLoCs ==========
  sl.registerFactory(() => AuthBloc(sendOtpUseCase: sl()));
  sl.registerFactory(() => OtpVerificationBloc(verifyOtpUseCase: sl()));
  sl.registerFactory(() => AboutBloc(getAboutUseCase: sl()));
  sl.registerFactory(() => ContactUsBloc(submitContactUsUseCase: sl()));
  sl.registerFactory(() => HospitalBloc(getHospitalsUseCase: sl()));
  sl.registerFactory(() => LabTestBloc(getLabTestsUseCase: sl()));
  sl.registerFactory(() => DiagnosticBloc(getDiagnosticsUseCase: sl()));
  sl.registerFactory(() => ProfileBloc(getProfileUseCase: sl(), updateProfileUseCase: sl(),));
  sl.registerFactory(() => AddressBloc(getAddresses: sl(), addAddress: sl(),));
  sl.registerFactory(() => PharmacyBloc(getPharmaciesUseCase: sl()));
  sl.registerFactory(() => RegistrationBloc(registerUserUseCase: sl()));
  sl.registerFactory(() => LanguageBloc());
  sl.registerFactory(() => MedLockerBloc(getMedLockersUseCase: sl(), getMedLockerDetailUseCase: sl(), addMedLockerUseCase: sl(),));
  sl.registerFactory(() => OrderBloc(createOrderUseCase: sl()));
  sl.registerFactory(() => PaymentBloc(createOrderUseCase: sl(), checkStatusUseCase: sl(),));
  sl.registerFactory(() => SubscriptionBloc(getSubscriptionPlansUseCase: sl()));
  sl.registerFactory(() => DiagnosticBookingBloc(bookDiagnosticUseCase: sl()));
  sl.registerFactory(() => FamilyMembersBloc(getFamilyMembersUseCase: sl()));
  sl.registerFactory(() => LabTestBookingBloc(createOrderUseCase: sl()));
  sl.registerFactory(() => DiagnosticBookingFetchListBloc(getOngoingUseCase: sl(), getCompletedUseCase: sl(),));
  sl.registerFactory(() => DiagnosticBookingFetchDetailBloc(getDetailUseCase: sl()));
  sl.registerFactory(() => SubscriptionPaymentBloc(createOrderUseCase: sl(), submitSubscriptionUseCase: sl(), cashfreeService: sl(),));
  sl.registerFactory(() => LabTestBookingFetchListBloc(getOngoingUseCase: sl(), getCompletedUseCase: sl(),));
  sl.registerFactory(() => LabTestBookingFetchDetailBloc(getDetailUseCase: sl()));
  sl.registerFactory(() => LabSlotBloc(getSlotsUseCase: sl()));
  sl.registerFactory(() => LabCouponListBloc(getCouponsUseCase: sl()));
  sl.registerFactory(() => ApplyLabCouponBloc(applyCouponUseCase: sl()));
  sl.registerFactory(() => LabPaymentBookingBloc(createBookingUseCase: sl()));
  sl.registerFactory(() => HospitalFiltersBloc(getFiltersUseCase: sl()));
  sl.registerFactory(() => OnlineDoctorBloc(getDoctorsUseCase: sl(),getTotalPagesUseCase: sl(),  clearCacheUseCase: sl(),));
  sl.registerFactory(() => OnlineDoctorSpecialityBloc(getSpecialitiesUseCase: sl()));
  sl.registerFactory(() => OnlineDoctorSlotBloc(getSlotsUseCase: sl()));
  sl.registerFactory(() => OnlineDoctorCouponBloc(getCouponsUseCase: sl()));
  sl.registerFactory(() => OnlineDoctorApplyCouponBloc(applyCouponUseCase: sl()));
  sl.registerFactory(() => FilteredHospitalsBloc(getFilteredHospitalsUseCase: sl()));
  sl.registerFactory(() => HospitalMainDataBloc(getHospitalDataUseCase: sl()));
  sl.registerFactory(() => MedicineBookingBloc(bookMedicineUseCase: sl()));
  sl.registerFactory(() => HospitalDiagnosticBookingBloc(bookHospitalDiagnosticUseCase: sl(),));
  sl.registerFactory(() => HospitalBookingHistoryBloc(getBookingsUseCase: sl()));
  sl.registerFactory(() => HospitalPharmacyBookingHistoryBloc(getBookingsUseCase: sl()));
  sl.registerFactory(() => HospitalDoctorBookingHistoryBloc(getBookingsUseCase: sl()));
  sl.registerFactory(() => AmbulanceBookingBloc(bookAmbulanceUseCase: sl()));
  sl.registerFactory(() => PharmacyBookingHistoryBloc(getBookingsUseCase: sl()));
  sl.registerFactory(() => ECardBloc(getECardUseCase: sl()));
  sl.registerFactory(() => OnlineDoctorBookingHistoryBloc(getBookingsUseCase: sl()));
  sl.registerFactory(() => DoctorSlotsBloc(getDoctorSlotsUseCase: sl()));
  sl.registerFactory(() => DoctorCouponBloc(getCouponsUseCase: sl(), applyCouponUseCase: sl(),));
  sl.registerFactory(() => DoctorBookingBloc(dioClient: sl(), cashfreeService: sl(),));
  sl.registerFactory(() => OnlineDoctorBookingBloc(dioClient: sl(), cashfreeService: sl(),));
  sl.registerFactory(() => NotificationBloc(getNotificationsUseCase: sl(), markNotificationReadUseCase: sl(),));
  sl.registerFactory(() => AddFamilyBloc(addFamilyMemberUseCase: sl()));
  sl.registerFactory(() => CoverageCategoryBloc(getCoverageCategories: sl()));
  sl.registerFactory(() => DashboardBloc(getDashboardUseCase: sl()));
  sl.registerFactory(() => FreeLabPackagesBloc(getFreeLabPackagesUseCase: sl()));
  sl.registerFactory(() => FreeLabSlotsBloc(getFreeLabSlotsUseCase: sl()));
  sl.registerFactory(() => FreeLabBookingBloc(dioClient: sl()));
  sl.registerFactory(() => SubscriptionStatusBloc(getUserSubscriptionUseCase: sl()));
  sl.registerFactory(() => FreeLabReportBloc(getFreeLabReports: sl<GetFreeLabReports>()));
  sl.registerFactory(() => AdmissionBloc(submitAdmission: sl<SubmitAdmission>()));
  sl.registerFactory(() => LabTestCategoryBloc(getCategories: sl<GetLabTestCategories>()));
  sl.registerFactory(() => LabTestSubcategoryBloc(getPackages: sl<GetPackagesByCategoryId>()));
  sl.registerFactory(() => PharmacyCategoryBloc(getCategories: sl(), getProducts: sl(),
  ));

}