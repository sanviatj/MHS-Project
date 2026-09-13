import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import '../services/google_login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFFECC065)),
        ),
      );

      try {
        final result = await _authService.login(_emailController.text, _passwordController.text);
        
        if (mounted) Navigator.pop(context);

        if (result != null) {
          String token = result['token'];
          String role = result['role'];

          if (role == 'admin') {
            Navigator.pushReplacementNamed(
              context, 
              '/admin-dashboard', 
              arguments: {'token': token},
            );
          } else {
            Navigator.pushReplacementNamed(
              context, 
              '/user-home', 
              arguments: {
                'token': token,
                'email': _emailController.text.trim(),
              },
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login failed! Invalid credentials.'), 
              backgroundColor: Colors.redAccent
            ),
          );
        }
      } catch (e) {
        if (mounted) Navigator.pop(context);
        print("Error Login Screen: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot connect to server. Is backend running?'), 
            backgroundColor: Colors.orange
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.login, size: 60, color: Color(0xFFECC065)),
                const SizedBox(height: 16),
                const Text(
                  "WELCOME BACK", 
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFECC065))
                ),
                const Text("Log in to your account", style: TextStyle(color: Colors.white54)),
                const SizedBox(height: 24),
                
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50), 
                    foregroundColor: const Color(0xFFECC065),
                    side: const BorderSide(color: Color(0xFFECC065), width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.g_mobiledata_rounded, color: Color(0xFFECC065), size: 32),
                  label: const Text("CONTINUE WITH GOOGLE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  onPressed: () {
                    GoogleLoginController().prosesSignInGoogle(context);
                  },
                ),
                
                const SizedBox(height: 16),
                const Text("OR", style: TextStyle(color: Colors.white30, fontSize: 12)),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _emailController,
                  label: "Email",
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your email' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: "Password",
                  isPassword: true,
                  validator: (val) => val == null || val.isEmpty ? 'Please enter your password' : null,
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFECC065), 
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _handleLogin,
                  child: const Text("Log in", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/register'),
                  child: const Text.rich(
                    TextSpan(
                      text: "Don't have an account? ", 
                      children: [
                        TextSpan(text: "Create one", style: TextStyle(color: Color(0xFFECC065)))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}