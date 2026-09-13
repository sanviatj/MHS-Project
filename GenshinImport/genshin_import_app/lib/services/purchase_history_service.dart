import 'dart:convert';
import 'package:http/http.dart' as http;

class PurchaseService {
  final String baseUrl = "http://localhost:3000/purchase_history";

  Future<List<dynamic>> fetchCartItems(String token) async {
  try {
    final response = await http.get(
      Uri.parse("http://127.0.0.1:3000/purchase_history"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); 
    }
    return [];
  } catch (e) {
    print("Error fetchCartItems: $e");
    return [];
  }
}

Future<bool> addToCart(String token, Map<String, dynamic> productData) async {
  try {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(productData),
    );
    return response.statusCode == 201;
  } catch (e) {
    print("Error addToCart: $e");
    return false;
  }
}
}