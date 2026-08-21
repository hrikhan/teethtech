import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final String? phone;
  final String? userType; // 'b2b' or 'b2c'
  final String? clinicName;
  final String? dentalInsuranceProvider;

  const AppUser({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.phone,
    this.userType = 'b2c',
    this.clinicName,
    this.dentalInsuranceProvider,
  });

  factory AppUser.empty() => const AppUser(id: '', email: '');

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;
  bool get isB2b => userType?.toLowerCase() == 'b2b';
  bool get isB2c => !isB2b;

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        photoUrl,
        phone,
        userType,
        clinicName,
        dentalInsuranceProvider,
      ];
}
