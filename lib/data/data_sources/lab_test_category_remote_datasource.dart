import '../models/lab_test_category_response_model.dart';

abstract class LabTestCategoryRemoteDataSource {
  Future<LabTestCategoryResponseModel> getCategories({
    required int page,
    required int perPage,
    required String language,
  });
}