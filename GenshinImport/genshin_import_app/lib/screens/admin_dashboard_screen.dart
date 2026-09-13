import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/weapon_model.dart';
import '../services/admin_service.dart';
import '../widgets/weapon_card_admin.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String token;

  const AdminDashboardScreen({Key? key, required this.token}) : super(key: key);

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  List<Weapon> _weapons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeapons();
  }

  Future<void> _fetchWeapons() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse("http://127.0.0.1:3000/products"));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _weapons = data.map((item) => Weapon.fromJson(item)).toList();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load weapons from server')),
      );
    }
  }

  void _deleteWeapon(String id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151B2C),
        title: const Text('Delete Item', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this item?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: const Text('Cancel', style: TextStyle(color: Colors.grey))
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      bool success = await _adminService.deleteWeapon(id, widget.token);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item deleted successfully'), backgroundColor: Colors.green));
        _fetchWeapons(); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete item'), backgroundColor: Colors.redAccent));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C111D),
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(color: Color(0xFFECC065), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF151B2C),
        elevation: 0,
        automaticallyImplyLeading: false, 
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFECC065)), 
            onPressed: _fetchWeapons
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF151B2C),
                  title: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  content: const Text('Apakah kamu yakin ingin keluar dari halaman Admin?', style: TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); 
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false); 
                      },
                      child: const Text('Keluar', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFECC065)))
          : _weapons.isEmpty
              ? const Center(child: Text('No weapons or artifacts found.', style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _weapons.length,
                  itemBuilder: (context, index) {
                    final weapon = _weapons[index];
                    return WeaponCardAdmin(
                      weapon: weapon,
                      onEdit: () async {
                        bool? dynamicRefresh = await Navigator.pushNamed(
                          context,
                          '/admin-form',
                          arguments: {'weapon': weapon, 'token': widget.token},
                        ) as bool?;
                        if (dynamicRefresh == true) _fetchWeapons();
                      },
                      onDelete: () => _deleteWeapon(weapon.id!),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFECC065),
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () async {
          bool? dynamicRefresh = await Navigator.pushNamed(
            context,
            '/admin-form',
            arguments: {'token': widget.token},
          ) as bool?;
          if (dynamicRefresh == true) _fetchWeapons();
        },
      ),
    );
  }
}