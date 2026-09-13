import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: kIsWeb 
      ? "326996309880-2h0enj93dd7d0icvp7oq978l2gqno3ft.apps.googleusercontent.com" 
      : null, 
  scopes: ['email'],
);

class GoogleLoginController {
  
  Future<void> prosesSignInGoogle(BuildContext context) async {
    try {
      print("🔄 Memulai proses Google Sign-In...");
      
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print("💡 Pengguna membatalkan Google Sign-In.");
        return;
      }
      
      print("✅ User memilih akun: ${googleUser.email}");
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        print("🚨 Gagal mendapatkan ID Token dari Google.");
        if (context.mounted) _showSnackBar(context, "Google Token Gagal Diambil", Colors.red);
        return;
      }

      print("🔄 Mengirim token ke backend Express.js...");
      
      final response = await http.post(
        Uri.parse("http://127.0.0.1:3000/users/google"), 
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": idToken}),
      );

      print("📡 Respons Backend diterima. Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        String backendToken = responseBody['token'] ?? '';

        print("✅ Backend sukses memverifikasi Google Akun! Mengalihkan halaman...");

        if (context.mounted) {
          Navigator.pushReplacementNamed(
            context, 
            '/user-home',
            arguments: {
              'token': backendToken,
              'email': googleUser.email.trim(), 
            },
          );
        }
      } else {
        print("🚨 Backend menolak login Google. Status: ${response.statusCode}");
        if (context.mounted) {
          _showSnackBar(context, 'Autentikasi Gagal! Status: ${response.statusCode}', Colors.redAccent);
        }
      }
    } catch (e) {
      print("🚨 Eror fatal pada Google Login Controller: $e");
      if (context.mounted) {
        _showSnackBar(context, 'Google Sign-In Error. Cek log terminal.', Colors.orange);
      }
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}