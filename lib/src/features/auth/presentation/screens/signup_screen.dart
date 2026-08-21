import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:teethtech/src/imports/core_imports.dart';
import '../providers/auth_bloc.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _clinicNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isB2BClinic = true; // Default to clinic B2B
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _clinicNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AuthBloc>().add(
          SignUpRequested(
            context: context,
            name: _isB2BClinic
                ? '${_nameController.text.trim()} (${_clinicNameController.text.trim()})'
                : _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final isLoading = context.select((AuthBloc bloc) => bloc.state.isLoading);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Join TeethTech',
                  style: tt.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select your account type to access specialized pricing and services.',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 20),

                // Account Type Selector (B2B Clinic vs Retail B2C)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _isB2BClinic = true),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _isB2BClinic ? cs.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.business_rounded,
                                  size: 16,
                                  color: _isB2BClinic ? Colors.white : cs.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Dental Clinic (B2B)',
                                  style: tt.labelMedium?.copyWith(
                                    color: _isB2BClinic ? Colors.white : cs.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _isB2BClinic = false),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !_isB2BClinic ? cs.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_rounded,
                                  size: 16,
                                  color: !_isB2BClinic ? Colors.white : cs.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Personal (B2C)',
                                  style: tt.labelMedium?.copyWith(
                                    color: !_isB2BClinic ? Colors.white : cs.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Name
                AppTextField(
                  controller: _nameController,
                  enabled: !isLoading,
                  label: _isB2BClinic ? 'Doctor / Practice Owner Name' : 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 14),

                // Clinic Name (if B2B)
                if (_isB2BClinic) ...[
                  AppTextField(
                    controller: _clinicNameController,
                    enabled: !isLoading,
                    label: 'Dental Practice / Clinic Name',
                    prefixIcon: const Icon(Icons.apartment_rounded),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Clinic name is required for B2B accounts'
                        : null,
                  ),
                  const SizedBox(height: 14),
                ],

                // Email
                AppTextField(
                  controller: _emailController,
                  enabled: !isLoading,
                  label: 'Work Email Address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Phone
                AppTextField(
                  controller: _phoneController,
                  enabled: !isLoading,
                  label: 'Contact Phone (+880)',
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                const SizedBox(height: 14),

                // Password
                AppTextField(
                  controller: _passwordController,
                  enabled: !isLoading,
                  label: 'Password (min 6 characters)',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Register Button
                AppButton(
                  label: _isB2BClinic
                      ? 'Register Dental Practice'
                      : 'Create Account',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _handleRegister,
                  height: ButtonSize.large,
                  isFullWidth: true,
                ),
                const SizedBox(height: 20),

                // Back to login
                Center(
                  child: InkWell(
                    onTap: () => context.push(AppRoutes.login),
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
