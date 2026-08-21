import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

class AuthMockDataSourceImpl implements AuthRemoteDataSource {
  UserModel? _currentUser;

  AuthMockDataSourceImpl() {
    _currentUser = null; // Fresh start as unauthenticated guest
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final isClinic = email.toLowerCase().contains('clinic') ||
        email.toLowerCase().contains('apex');

    _currentUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: isClinic
          ? 'Apex Dental Care & Implant Center'
          : (email.toLowerCase().contains('tanvir')
              ? 'Dr. Tanvir Ahmed, BDS'
              : email.split('@').first.toUpperCase()),
      phone: '+880 1712-345678',
      userType: isClinic ? 'b2b' : 'b2c',
      clinicName: isClinic ? 'Apex Dental Care & Implant Center' : null,
      dentalInsuranceProvider: isClinic
          ? 'B2B Clinical Direct Wholesale Plan'
          : 'Standard Dental Retail Plan',
    );
    return _currentUser!;
  }

  @override
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final isClinic = name.contains('(') ||
        name.toLowerCase().contains('clinic') ||
        email.toLowerCase().contains('clinic');

    _currentUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      phone: '+880 1700-000000',
      userType: isClinic ? 'b2b' : 'b2c',
      clinicName: isClinic ? name : null,
      dentalInsuranceProvider: isClinic
          ? 'B2B Clinical Direct Wholesale Plan'
          : 'Standard Dental Retail Plan',
    );
    return _currentUser!;
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _currentUser;
  }
}
