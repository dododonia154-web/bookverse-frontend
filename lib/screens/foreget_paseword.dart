import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  
  int _currentStep = 0; // 0: Email, 1: OTP, 2: New Password
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isSuccess ? Colors.green : Colors.red),
    );
  }

  Future<void> _handleSendOTP() async {
    if (_emailController.text.isEmpty) {
      _showMessage('Please enter your email', false);
      return;
    }
    setState(() => _isLoading = true);
    final result = await ApiService.sendForgotPasswordOTP(_emailController.text);
    setState(() => _isLoading = false);

    if (result['success']) {
      _showMessage(result['message'], true);
      if (result['otp_debug'] != null) {
        print('DEBUG OTP: ${result['otp_debug']}'); // للمساعدة في التجربة
      }
      setState(() => _currentStep = 1);
    } else {
      _showMessage(result['message'], false);
    }
  }

  Future<void> _handleVerifyOTP() async {
    if (_otpController.text.length < 6) {
      _showMessage('Please enter 6-digit OTP', false);
      return;
    }
    setState(() => _isLoading = true);
    final result = await ApiService.verifyOTP(_emailController.text, _otpController.text);
    setState(() => _isLoading = false);

    if (result['success']) {
      _showMessage(result['message'], true);
      setState(() => _currentStep = 2);
    } else {
      _showMessage(result['message'], false);
    }
  }

  Future<void> _handleResetPassword() async {
    if (_newPasswordController.text.length < 6) {
      _showMessage('Password must be at least 6 characters', false);
      return;
    }
    setState(() => _isLoading = true);
    final result = await ApiService.resetPassword(
      _emailController.text, 
      _otpController.text, 
      _newPasswordController.text
    );
    setState(() => _isLoading = false);

    if (result['success']) {
      _showMessage(result['message'], true);
      Navigator.pop(context);
    } else {
      _showMessage(result['message'], false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentStep == 0 ? 'Forgot Password' : (_currentStep == 1 ? 'Verify OTP' : 'New Password'),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
              ),
              const SizedBox(height: 12),
              Text(
                _currentStep == 0 
                  ? 'Enter your email to receive a verification code.' 
                  : (_currentStep == 1 
                      ? 'Enter the 6-digit code sent to ${_emailController.text}' 
                      : 'Enter your new password below.'),
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 40),
              
              if (_currentStep == 0) ...[
                _buildTextField(_emailController, 'Email', Icons.email_outlined),
                const SizedBox(height: 32),
                _buildButton('Send OTP', _handleSendOTP),
              ] else if (_currentStep == 1) ...[
                _buildTextField(_otpController, 'OTP Code', Icons.lock_clock_outlined, keyboardType: TextInputType.number),
                const SizedBox(height: 32),
                _buildButton('Verify OTP', _handleVerifyOTP),
                TextButton(
                  onPressed: () => setState(() => _currentStep = 0),
                  child: const Text('Change Email', style: TextStyle(color: Color(0xFFD4AF37))),
                )
              ] else ...[
                _buildTextField(_newPasswordController, 'New Password', Icons.lock_outline, obscureText: true),
                const SizedBox(height: 32),
                _buildButton('Reset Password', _handleResetPassword),
              ],
              
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: const Color(0xFFD4AF37)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white24)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD4AF37))),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
