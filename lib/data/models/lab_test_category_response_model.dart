import 'lab_test_category_model.dart';

class LabTestCategoryResponseModel {
  final int currentPage;
  final List<LabTestCategoryModel> data;
  final int lastPage;
  final int total;

  LabTestCategoryResponseModel({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.total,
  });

  factory LabTestCategoryResponseModel.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List;
    final categories = dataList.map((e) => LabTestCategoryModel.fromJson(e)).toList();
    return LabTestCategoryResponseModel(
      currentPage: json['current_page'] as int,
      data: categories,
      lastPage: json['last_page'] as int,
      total: json['total'] as int,
    );
  }
}