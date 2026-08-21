import 'package:equatable/equatable.dart';

class DentalCategory extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String image;
  final int productCount;
  final List<String> subcategories;

  const DentalCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.image,
    required this.productCount,
    required this.subcategories,
  });

  @override
  List<Object?> get props => [id, name, icon, image, productCount, subcategories];
}
