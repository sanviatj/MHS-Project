import 'package:flutter/material.dart';
import '../services/purchase_history_service.dart';
import 'user_home_screen.dart'; 

class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({Key? key}) : super(key: key);

  @override
  _PurchaseHistoryScreenState createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  late Future<List<dynamic>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _historyFuture = PurchaseService().fetchCartItems(globalToken);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C111D),
      body: FutureBuilder<List<dynamic>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFECC065)));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off_rounded, size: 60, color: Colors.white24),
                  SizedBox(height: 12),
                  Text('Belum ada riwayat pembelian', style: TextStyle(color: Colors.white38, fontSize: 14)),
                ],
              ),
            );
          }

          final historyList = snapshot.data!;

          return RefreshIndicator(
            color: const Color(0xFFECC065),
            backgroundColor: const Color(0xFF151B2C),
            onRefresh: () async { _loadHistory(); },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                final tx = historyList[index];
                return Card(
                  color: const Color(0xFF151B2C),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: const Color(0xFFECC065).withOpacity(0.1)),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFFECC065).withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.shopping_bag_rounded, color: Color(0xFFECC065)),
                    ),
                    title: Text(
                      (tx['name'] ?? 'Weapon').toString().toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                      'Quantity: ${tx['quantity']} pcs',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    trailing: Text(
                      '${(tx['price'] ?? 0) * (tx['quantity'] ?? 0)} MORA',
                      style: const TextStyle(color: Color(0xFFECC065), fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}