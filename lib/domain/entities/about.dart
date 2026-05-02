import 'package:equatable/equatable.dart';

class About extends Equatable {
  final int id;
  final String content;   // the 'name' field from API

  const About({required this.id, required this.content});

  @override
  List<Object> get props => [id, content];
}