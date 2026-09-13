import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data'; 
import '../models/weapon_model.dart';

class AdminService {
  final String baseUrl = "http://127.0.0.1:3000"; 

  Map<String, String> _getHeaders(String token) {
    return {
      "Authorization": "Bearer $token",
    };
  }

  Future<bool> createWeapon(Weapon weapon, String token, Uint8List? imageBytes, String? imageName) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/products"));
      
      request.headers.addAll(_getHeaders(token));

      request.fields['name'] = weapon.name;
      request.fields['type'] = weapon.type;
      request.fields['description'] = weapon.description;
      request.fields['stock'] = weapon.stock.toString();
      request.fields['price'] = weapon.price.toString();
      request.fields['image'] = imageName ?? weapon.image;

      if (imageBytes != null && imageName != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'image', 
          imageBytes,
          filename: imageName,
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("🚨 Error create service: $e");
      return false;
    }
  }

  Future<bool> updateWeapon(Weapon weapon, String token, Uint8List? imageBytes, String? imageName) async {
    try {
      print("🔄 Mengirim update Multipart untuk ID: ${weapon.id}");
      
      var request = http.MultipartRequest('PUT', Uri.parse("$baseUrl/products/${weapon.id}"));
      
      request.headers.addAll(_getHeaders(token));

      request.fields['name'] = weapon.name;
      request.fields['type'] = weapon.type;
      request.fields['description'] = weapon.description;
      request.fields['stock'] = weapon.stock.toString();
      request.fields['price'] = weapon.price.toString();
      request.fields['image'] = imageName ?? weapon.image;

      if (imageBytes != null && imageName != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageName,
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("📬 Respon Backend Status Code: ${response.statusCode}");
      print("💬 Respon Body: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("🚨 Error update service: $e");
      return false;
    }
  }

  Future<bool> deleteWeapon(String id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/products/$id"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print("🚨 Error delete service: $e");
      return false;
    }
  }
}