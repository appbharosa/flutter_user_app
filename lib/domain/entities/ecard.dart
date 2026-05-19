
class ECard {
  final String? uniqueId;
  final String toDate;
  final String name;
  final String? image;

  ECard({
    required this.uniqueId,
    required this.toDate,
    required this.name,
    this.image,
  });
}