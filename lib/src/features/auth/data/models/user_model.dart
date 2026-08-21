import '../../domain/entities/user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.photoUrl,
    super.phone,
    super.userType = 'b2c',
    super.clinicName,
    super.dentalInsuranceProvider,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString(),
      photoUrl: json['photoUrl']?.toString() ?? json['photo_url']?.toString(),
      phone: json['phone']?.toString(),
      userType: json['userType']?.toString() ?? json['user_type']?.toString() ?? 'b2c',
      clinicName: json['clinicName']?.toString() ?? json['clinic_name']?.toString(),
      dentalInsuranceProvider: json['dentalInsuranceProvider']?.toString() ??
          json['dental_insurance_provider']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'phone': phone,
      'userType': userType,
      'clinicName': clinicName,
      'dentalInsuranceProvider': dentalInsuranceProvider,
    };
  }

  factory UserModel.fromEntity(AppUser user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      photoUrl: user.photoUrl,
      phone: user.phone,
      userType: user.userType,
      clinicName: user.clinicName,
      dentalInsuranceProvider: user.dentalInsuranceProvider,
    );
  }
}
