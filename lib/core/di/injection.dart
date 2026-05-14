import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/data_sources/about_remote_datasource.dart';
import '../../data/data_sources/address_remote_datasource.dart';
import '../../data/data_sources/auth_remote_datasource.dart';
import '../../data/data_sources/banner_remote_datasource.dart';
import '../../data/data_sources/contact_us_remote_datasource.dart';
import '../../data/data_sources/diagnostic_booking_fetch_remote_datasource.dart';
import '../../data/data_sources/diagnostic_booking_remote_datasource.dart';
import '../../data/data_sources/diagnostic_remote_datasource.dart';
import '../../data/data_sources/family_member_remote_datasource.dart';
import '../../data/data_sources/hospital_remote_datasource.dart';
import '../../data/data_sources/lab_cashfree_order_remote_datasource.dart';
import '../../data/data_sources/lab_coupon_remote_datasource.dart';
import '../../data/data_sources/lab_payment_booking_remote_datasource.dart';
import '../../data/data_sources/lab_slot_remote_datasource.dart';
import '../../data/data_sources/lab_test_booking_fetch_remote_datasource.dart';
import '../../data/data_sources/lab_test_booking_remote_datasource.dart';
import '../../data/data_sources/lab_test_remote_datasource.dart';
import '../../data/data_sources/med_locker_remote_datasource.dart';
import '../../data/data_sources/order_remote_datasource.dart';
import '../../data/data_sources/payment_remote_datasource.dart';
import '../../data/data_sources/pharmacy_remote_datasource.dart';
import '../../data/data_sources/profile_remote_datasource.dart';
import '../../data/data_sources/subscription_payment_remote_datasource.dart';
import '../../data/data_sources/subscription_remote_datasource.dart';
import '../../data/data_sources/user_local_datasource.dart';
import '../../data/repositories/about_repository_impl.dart';
import '../../data/repositories/address_repository_impl.dart';
import '../../data/repositories/contact_us_repository_impl.dart';
import '../../data/repositories/diagnostic_booking_fetch_repository_impl.dart';
import '../../data/repositories/diagnostic_booking_repository_impl.dart';
import '../../data/repositories/diagnostic_repository_impl.dart';
import '../../data/repositories/family_member_repository_impl.dart';
import '../../data/repositories/hospital_repository_impl.dart';
import '../../data/repositories/lab_cashfree_order_repository_impl.dart';
import '../../data/repositories/lab_coupon_repository_impl.dart';
import '../../data/repositories/lab_payment_booking_repository_impl.dart';
import '../../data/repositories/lab_slot_repository_impl.dart';
import '../../data/repositories/lab_test_booking_fetch_repository_impl.dart';
import '../../data/repositories/lab_test_booking_repository_impl.dart';
import '../../data/repositories/lab_test_repository_impl.dart';
import '../../data/repositories/med_locker_repository_impl.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../data/repositories/pharmacy_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/repositories/subscription_payment_repository_impl.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/repositories/about_repository.dart';
import '../../domain/repositories/address_repository.dart';
import '../../domain/repositories/contact_us_repository.dart';
import '../../domain/repositories/diagnostic_booking_fetch_repository.dart';
import '../../domain/repositories/diagnostic_booking_repository.dart';
import '../../domain/repositories/diagnostic_repository.dart';
import '../../domain/repositories/family_member_repository.dart';
import '../../domain/repositories/hospital_repository.dart';
import '../../domain/repositories/lab_cashfree_order_repository.dart';
import '../../domain/repositories/lab_coupon_repository.dart';
import '../../domain/repositories/lab_payment_booking_repository.dart';
import '../../domain/repositories/lab_slot_repository.dart';
import '../../domain/repositories/lab_test_booking_fetch_repository.dart';
import '../../domain/repositories/lab_test_booking_repository.dart';
import '../../domain/repositories/lab_test_repository.dart';
import '../../domain/repositories/med_locker_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/repositories/pharmacy_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/subscription_payment_repository.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../domain/use_cases/add_address_usecase.dart';
import '../../domain/use_cases/add_med_locker_usecase.dart';
import '../../domain/use_cases/apply_lab_coupon_usecase.dart';
import '../../domain/use_cases/book_diagnostic_usecase.dart';
import '../../domain/use_cases/check_payment_status_usecase.dart';
import '../../domain/use_cases/create_cashfree_order_usecase.dart';
import '../../domain/use_cases/create_lab_cashfree_order_usecase.dart';
import '../../domain/use_cases/create_lab_payment_booking_usecase.dart';
import '../../domain/use_cases/create_lab_test_order_usecase.dart';
import '../../domain/use_cases/create_order_usecase.dart';
import '../../domain/use_cases/create_subscription_order_usecase.dart';
import '../../domain/use_cases/get_about_usecase.dart';
import '../../domain/use_cases/get_addresses_usecase.dart';
import '../../domain/use_cases/get_banners_usecase.dart';
import '../../domain/use_cases/get_booking_fetch_detail_usecase.dart';
import '../../domain/use_cases/get_completed_fetch_bookings_usecase.dart';
import '../../domain/use_cases/get_completed_lab_test_bookings_usecase.dart';
import '../../domain/use_cases/get_diagnostics_usecase.dart';
import '../../domain/use_cases/get_family_members_usecase.dart';
import '../../domain/use_cases/get_hospitals_usecase.dart';
import '../../domain/use_cases/get_lab_coupons_usecase.dart';
import '../../domain/use_cases/get_lab_slots_usecase.dart';
import '../../domain/use_cases/get_lab_test_booking_detail_usecase.dart';
import '../../domain/use_cases/get_lab_tests_usecase.dart';
import '../../domain/use_cases/get_med_locker_detail_usecase.dart';
import '../../domain/use_cases/get_med_lockers_usecase.dart';
import '../../domain/use_cases/get_ongoing_fetch_bookings_usecase.dart';
import '../../domain/use_cases/get_ongoing_lab_test_bookings_usecase.dart';
import '../../domain/use_cases/get_pharmacies_usecase.dart';
import '../../domain/use_cases/get_profile_usecase.dart';
import '../../domain/use_cases/get_subscription_plans_usecase.dart';
import '../../domain/use_cases/login_usecase.dart';
import '../../domain/use_cases/register_user_usecase.dart';
import '../../domain/use_cases/submit_contact_us_usecase.dart';
import '../../domain/use_cases/submit_subscription_usecase.dart';
import '../../domain/use_cases/update_profile_usecase.dart';
import '../../domain/use_cases/verify_otp_usecase.dart';
import '../../features/about/presentation/bloc/about_bloc.dart';
import '../../features/contact_us/presentation/bloc/contact_us_bloc.dart';
import '../../features/diagnostic/presentation/bloc/diagnostic_bloc.dart';
import '../../features/diagnostic/presentation/diagnostic_booking_bloc/diagnostic_booking_bloc.dart';
import '../../features/diagnostic/presentation/diagnostic_booking_fetch_detail_bloc/diagnostic_booking_fetch_detail_bloc.dart';
import '../../features/diagnostic/presentation/diagnostic_bookings_bloc/diagnostic_booking_fetch_list_bloc.dart';
import '../../features/diagnostic/presentation/family_members_bloc/family_members_bloc.dart';
import '../../features/home/presentation/address_bloc/address_bloc.dart';
import '../../features/hospital/presentation/bloc/hospital_bloc.dart';
import '../../features/labtest/presentation/apply_lab_coupon_bloc/apply_lab_coupon_bloc.dart';
import '../../features/labtest/presentation/bloc/lab_test_bloc.dart';
import '../../features/labtest/presentation/lab_coupon_list_bloc/lab_coupon_list_bloc.dart';
import '../../features/labtest/presentation/lab_payment_booking_bloc/lab_payment_booking_bloc.dart';
import '../../features/labtest/presentation/lab_slot_bloc/lab_slot_bloc.dart';
import '../../features/labtest/presentation/lab_test_booking_bloc/lab_test_booking_bloc.dart';
import '../../features/labtest/presentation/lab_test_booking_fetch_detail_bloc/lab_test_booking_fetch_detail_bloc.dart';
import '../../features/labtest/presentation/lab_test_booking_fetch_list_bloc/lab_test_booking_fetch_list_bloc.dart';
import '../../features/language/bloc/language_bloc.dart';
import '../../features/medlocker/presentation/add_bloc/add_med_locker_bloc.dart';
import '../../features/medlocker/presentation/bloc/med_locker_bloc.dart';
import '../../features/medlocker/presentation/detail_bloc/med_locker_detail_bloc.dart';
import '../../features/otp/presentation/bloc/otp_verification_bloc.dart';
import '../../features/pedometer/gps/new_gps/gps_bloc.dart';
import '../../features/pharmacy/presentation/bloc/pharmacy_bloc.dart';
import '../../features/pharmacy/presentation/confirm_bloc/order_bloc.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/registration/presentation/bloc/registration_bloc.dart';
import '../../features/subscription/presentation/bloc/subscription_bloc.dart';
import '../../features/subscription/presentation/create_order_bloc/subscription_payment_bloc.dart';
import '../../features/wallet/presentation/bloc/payment_bloc.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/banner_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/banner_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/banners/presentation/bloc/banner_bloc.dart';
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
  sl.registerLazySingleton<BannerRemoteDataSource>(() => BannerRemoteDataSourceImpl(sl()));
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


  // ========== Repositories ==========
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
    remoteDataSource: sl(),
    localDataSource: sl(),
    networkInfo: sl(),
  ));
  sl.registerLazySingleton<BannerRepository>(() => BannerRepositoryImpl(
    remoteDataSource: sl(),
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

  // ========== Use Cases ==========
  sl.registerLazySingleton(() => SendOtpUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));
  sl.registerLazySingleton(() => GetBannersUseCase(sl()));
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
  sl.registerLazySingleton(() => GetMedLockersUseCase(sl()));
  sl.registerLazySingleton(() => GetMedLockerDetailUseCase(sl()));
  sl.registerLazySingleton(() => AddMedLockerUseCase(sl()));
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



  // ========== BLoCs ==========
  sl.registerFactory(() => AuthBloc(sendOtpUseCase: sl()));
  sl.registerFactory(() => OtpVerificationBloc(verifyOtpUseCase: sl()));
  sl.registerFactory(() => BannerBloc(getBannersUseCase: sl()));
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
  sl.registerFactory(() => MedLockerBloc(getMedLockersUseCase: sl()));
  sl.registerFactory(() => MedLockerDetailBloc(getMedLockerDetailUseCase: sl()));
  sl.registerFactory(() => AddMedLockerBloc(addMedLockerUseCase: sl()));
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
  sl.registerFactory(() => GpsBloc());



}