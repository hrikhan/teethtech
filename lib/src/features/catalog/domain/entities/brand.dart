import 'package:equatable/equatable.dart';

class DentalBrand extends Equatable {
  final String id;
  final String name;
  final String logo;
  final String origin;
  final int productCount;
  final String description;

  const DentalBrand({
    required this.id,
    required this.name,
    required this.logo,
    required this.origin,
    required this.productCount,
    this.description = '',
  });

  @override
  List<Object?> get props => [id, name, logo, origin, productCount, description];
}
