import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/appurls/app_urls.dart';
import '../../core/network/dio_client.dart';
import '../../domain/entities/admission_request.dart';

abstract class AdmissionRemoteDataSource {
  Future<void> requestAdmission(AdmissionRequest request);
}

class AdmissionRemoteDataSourceImpl implements AdmissionRemoteDataSource {
  final DioClient dioClient;

  AdmissionRemoteDataSourceImpl(this.dioClient);
  @override
  Future<void> requestAdmission(AdmissionRequest request) async {
    try {
      final formData = FormData.fromMap({
        'patient_name': request.patientName,
        'age': request.age.toString(),
        'gender': request.gender,
        'phone': request.phone,
        'symptoms': request.symptoms,
        'department_required': request.departmentRequired,
        'admission_type': request.admissionType,
        'preferred_location': request.preferredLocation,
      });

      // Add files with keys: prescription, reports, insurance_card (no brackets)
      Future<void> addFiles(String key, List<String> paths) async {
        for (final path in paths) {
          final file = File(path);
          if (await file.exists()) {
            formData.files.add(MapEntry(key, await MultipartFile.fromFile(path)));
          }
        }
      }

      await addFiles('prescription', request.prescriptionPaths);
      await addFiles('reports', request.reportsPaths);
      await addFiles('insurance_card', request.insuranceCardPaths);

      // ==== Enhanced Debug ====
      print('===== ADMISSION REQUEST DETAILS =====');
      print('Fields:');
      for (var field in formData.fields) {
        print('  ${field.key}: ${field.value}');
      }
      print('Files:');
      for (var file in formData.files) {
        print('  ${file.key}: ${file.value.filename} (exists: ${File(file.value.filename!).existsSync()})');
      }
      print('=====================================');

      final response = await dioClient.dio.post(
        AppUrls.requestAdmission,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.data['status'] != 200) {
        throw Exception(response.data['message'] ?? 'Failed to submit admission request');
      }
    } on DioException catch (e) {
      print('Dio error: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }
}