import 'package:flutter/material.dart';
import '../widgets/weapon_card_user.dart';
import '../models/weapon_model.dart';
import 'purchase_history_screen.dart'; 
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'profile_screen.dart';

String globalToken = "";

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({Key? key}) : super(key: key);

  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 0; 
  bool _isTokenLoaded = false;
  String _userEmail = ""; 
  
  List<Weapon> _allProducts = [];
  bool _isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _fetchProductsFromDatabase();
  }

  Future<void> _fetchProductsFromDatabase() async {
    try {
      if (!mounted) return;
      setState(() => _isLoadingProducts = true);

      print("🔄 Memperbarui katalog produk dari MySQL...");
      final response = await http.get(Uri.parse("http://127.0.0.1:3000/products"));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _allProducts = data.map((item) => Weapon.fromJson(item)).toList();
            _isLoadingProducts = false;
          });
        }
        print("✅ Berhasil memuat ${_allProducts.length} produk.");
      }
    } catch (e) {
      print("🚨 Error fetch products di Home: $e");
      if (mounted) setState(() => _isLoadingProducts = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isTokenLoaded) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      globalToken = args?['token'] ?? '';
      _userEmail = args?['email'] ?? ''; 
      _isTokenLoaded = true;
    }

    Widget currentScreen;
    if (_currentIndex == 0) {
      currentScreen = _buildWeaponsCatalog();
    } else if (_currentIndex == 1) {
      currentScreen = const PurchaseHistoryScreen(); 
    } else {
      currentScreen = ProfileScreen(userEmail: _userEmail);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0C111D),
      body: currentScreen,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
            _fetchProductsFromDatabase();
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF151B2C),
        selectedItemColor: const Color(0xFFECC065), 
        unselectedItemColor: Colors.white38,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), 
            activeIcon: Icon(Icons.home), 
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined), 
            activeIcon: Icon(Icons.history), 
            label: 'Purchase History', 
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), 
            activeIcon: Icon(Icons.person), 
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildWeaponsCatalog() {
    return Scaffold(
      backgroundColor: const Color(0xFF0C111D),
      appBar: AppBar(
        title: const Text('GENSHIN IMPORT', style: TextStyle(color: Color(0xFFECC065), fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.2)),
        backgroundColor: const Color(0xFF151B2C),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _isLoadingProducts
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFECC065)))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('WEAPONS CATALOG', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _allProducts.length,
                      itemBuilder: (context, index) {
                        final weapon = _allProducts[index];
                        return WeaponCardUser(
                          weapon: weapon,
                          onBuy: () async {
                            final result = await Navigator.pushNamed(
                              context, 
                              '/product-detail', 
                              arguments: {'weapon': weapon, 'token': globalToken}
                            );

                            if (result == true) {
                              _fetchProductsFromDatabase();
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}