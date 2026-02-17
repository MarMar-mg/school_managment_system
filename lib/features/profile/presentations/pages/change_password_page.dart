// features/profile/presentations/pages/change_password_page.dart
import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/core/services/api_service.dart';
import 'package:school_management_system/commons/responsive_container.dart';

class ChangePasswordPage extends StatefulWidget {
  final int userId;

  const ChangePasswordPage({
    super.key,
    required this.userId,
  });

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Call the new void-returning method
      await ApiService().changePassword(
        userId: widget.userId,
        currentPassword: _currentPasswordController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
      );

      if (!mounted) return;

      // Success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'رمز عبور با موفقیت تغییر یافت',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );

      // Optional: close page after success
      Navigator.pop(context);
    }
    on AppException catch (e) {
      // Known backend validation / business errors
      if (!mounted) return;
      _showSnackBar(
        e.message,
        e.field != null ? Colors.orange : Colors.red,
      );
    }
    catch (e) {
      // Network error, timeout, json parse fail, etc.
      if (!mounted) return;
      _showSnackBar(
        'خطا در ارتباط با سرور\n${e.toString()}',
        Colors.red,
      );
    }
    finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        backgroundColor: color.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'لطفاً رمز عبور را وارد کنید';
    }
    if (value.length < 8) {
      return 'رمز عبور باید حداقل ۸ کاراکتر باشد';
    }
    // You can add more rules: uppercase, number, special char...
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تغییر رمز عبور'),
        centerTitle: true,
        backgroundColor: AppColor.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: ResponsiveContainer(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Header / instruction
                Text(
                  'برای تغییر رمز عبور، لطفاً اطلاعات زیر را وارد کنید',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[800],
                    height: 1.4,
                  ),
                  textDirection: TextDirection.rtl,
                ),

                const SizedBox(height: 32),

                // Current Password
                _buildPasswordField(
                  controller: _currentPasswordController,
                  label: 'رمز عبور فعلی',
                  hint: 'رمز فعلی خود را وارد کنید',
                  obscure: _obscureCurrent,
                  onToggleObscure: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  validator: (v) => v?.isEmpty ?? true ? 'لطفاً رمز فعلی را وارد کنید' : null,
                ),

                const SizedBox(height: 24),

                // New Password
                _buildPasswordField(
                  controller: _newPasswordController,
                  label: 'رمز عبور جدید',
                  hint: 'حداقل ۸ کاراکتر',
                  obscure: _obscureNew,
                  onToggleObscure: () => setState(() => _obscureNew = !_obscureNew),
                  validator: _validatePassword,
                ),

                const SizedBox(height: 24),

                // Confirm New Password
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'تکرار رمز عبور جدید',
                  hint: 'رمز جدید را دوباره وارد کنید',
                  obscure: _obscureConfirm,
                  onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (value) {
                    if (value != _newPasswordController.text) {
                      return 'رمزهای عبور مطابقت ندارند';
                    }
                    return _validatePassword(value);
                  },
                ),

                const SizedBox(height: 40),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _changePassword,
                    icon: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.lock_reset_rounded),
                    label: Text(
                      _isLoading ? 'در حال تغییر...' : 'تغییر رمز عبور',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Center(
                  child: Text(
                    'رمز عبور قوی انتخاب کنید • حداقل ۸ کاراکتر',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggleObscure,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textDirection: TextDirection.ltr,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: AppColor.purple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColor.purple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColor.purple),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            color: AppColor.purple,
          ),
          onPressed: onToggleObscure,
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: validator,
    );
  }
}