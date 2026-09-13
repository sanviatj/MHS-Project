import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart'; 

class AuthService {
  final String baseUrl = "http://127.0.0.1:3000"; 
  
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final response = await http.post(
        Uri.parse("$baseUrl/users/google-login"), 
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": googleUser.email,
          "name": googleUser.displayName,
          "googleId": googleUser.id,
          "idToken": googleAuth.idToken,
        }),
      );

      print("Google Auth Backend Status Code: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'token': data['token'],
          'role': data['user']['role'] ?? 'user' 
        };
      }
      return null;
    } catch (e) {
      print("🚨 Error di AuthService Google Sign-In: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/users/login"), 
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("Login Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'token': data['token'],
          'role': data['user']['role']
        };
      }
      return null;
    } catch (e) {
      print("Error di AuthService Login: $e");
      return null;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/users/register"), 
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("Register Status Code: ${response.statusCode}");

      return response.statusCode == 201;
    } catch (e) {
      print("Error di AuthService Register: $e");
      return false;
    }
  }
}