import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isGoogleProcessing = false; 

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      bool success = await _authService.register(_emailController.text, _passwordController.text);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Please log in.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed.')),
        );
      }
    }
  }


  void _handleGoogleSignIn() async {
    setState(() => _isGoogleProcessing = true);
    try {

      final result = await _authService.signInWithGoogle(); 
      
      if (result != null && result['token'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-In Successful!'), backgroundColor: Colors.green),
        );
        Navigator.pushReplacementNamed(context, '/user-home'); 
      }
    } catch (e) {
      print("🚨 Error Google Sign-In Halaman Register: $e");
    } finally {
      setState(() => _isGoogleProcessing = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C111D),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(Icons.person_add_alt_1, size: 60, color: Color(0xFFECC065)),
                const SizedBox(height: 16),
                const Text("CREATE YOUR ACCOUNT", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFECC065))),
                const Text("Sign up to get started", style: TextStyle(color: Colors.white54)),
                const SizedBox(height: 24),
                
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50), 
                    side: const BorderSide(color: Colors.white24)
                  ),
                  icon: _isGoogleProcessing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber))
                      : const Icon(Icons.g_mobiledata, color: Colors.amber, size: 30),
                  label: Text(
                    _isGoogleProcessing ? "Connecting..." : "Continue with Google", 
                    style: const TextStyle(color: Colors.white)
                  ),
                  onPressed: _isGoogleProcessing ? null : _handleGoogleSignIn,
                ),
                const SizedBox(height: 16),
                const Text("OR", style: TextStyle(color: Colors.white30, fontSize: 12)),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _emailController,
                  label: "Email",
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Email is required';
                    if (!val.contains('@') || !val.contains('.')) return 'Enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _passwordController,
                  label: "Password",
                  validator: (val) => val == null || val.length < 8 ? 'Password must be at least 8 characters' : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _confirmPasswordController,
                  label: "Confirm Password",
                  validator: (val) => val != _passwordController.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFECC065), minimumSize: const Size.fromHeight(50)),
                  onPressed: _handleRegister,
                  child: const Text("Create account", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text.rich(TextSpan(text: "Already have an account? ", children: [TextSpan(text: "Log in", style: TextStyle(color: Color(0xFFECC065)))]))
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}