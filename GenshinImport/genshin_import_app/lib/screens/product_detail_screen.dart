import 'package:flutter/material.dart';
import '../models/weapon_model.dart';
import '../services/purchase_history_service.dart';
import 'user_home_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _isProcessing = false;
  
  bool _adaTransaksiSukses = false; 

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    
    late Weapon product;
    late String token;

    if (args is Weapon) {
      product = args;
      token = globalToken;
    } else if (args is Map<String, dynamic>) {
      product = args['weapon'];
      token = args['token'] ?? globalToken;
    } else {
      return const Scaffold(
        backgroundColor: Color(0xFF0C111D),
        body: Center(child: Text('Data produk tidak valid', style: TextStyle(color: Colors.white))),
      );
    }

    return PopScope(
      canPop: false, 
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        Navigator.pop(context, _adaTransaksiSukses);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0C111D),
        appBar: AppBar(
          title: const Text('GENSHIN IMPORT', style: TextStyle(color: Color(0xFFECC065), fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
          backgroundColor: const Color(0xFF151B2C),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFECC065)),
            onPressed: () => Navigator.pop(context, _adaTransaksiSukses), 
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 280,
                decoration: const BoxDecoration(
                  color: Color(0xFF151B2C),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Image.network(
                      'http://localhost:3000/images/${product.image}', 
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.shield_moon_outlined, size: 100, color: Color(0xFFECC065)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: product.type == 'Weapon' ? Colors.redAccent.withOpacity(0.15) : Colors.blueAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: product.type == 'Weapon' ? Colors.redAccent : Colors.blueAccent),
                      ),
                      child: Text(
                        product.type,
                        style: TextStyle(color: product.type == 'Weapon' ? Colors.redAccent : Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product.name.toUpperCase(),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      product.description,
                      style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF151B2C),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFECC065).withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Price', style: TextStyle(color: Colors.white54, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text('${product.price} MORA', style: const TextStyle(color: Color(0xFFECC065), fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Stock', style: TextStyle(color: Colors.white54, fontSize: 12)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.inventory_2_outlined, color: Color(0xFFECC065), size: 16),
                                  const SizedBox(width: 6),
                                  Text('${product.stock}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Text('Qty:', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(width: 16),
                        Container(
                          decoration: BoxDecoration(color: const Color(0xFF151B2C), borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, color: Color(0xFFECC065)), 
                                onPressed: () { if (_quantity > 1) setState(() => _quantity--); },
                              ),
                              Text('$_quantity', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add, color: Color(0xFFECC065)), 
                                onPressed: () { if (_quantity < product.stock) setState(() => _quantity++); },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('= ${product.price * _quantity} Mora', style: const TextStyle(color: Colors.white38, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFECC065),
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: _isProcessing 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : const Icon(Icons.shopping_bag_outlined),
                      label: Text(_isProcessing ? 'Buying...' : 'Buy Now', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: _isProcessing || product.stock <= 0 ? null : () async {
                        setState(() => _isProcessing = true);
                        
                        Map<String, dynamic> productData = {
                          "id": product.id,        
                          "quantity": _quantity,   
                        };

                        bool success = await PurchaseService().addToCart(token, productData);
                        
                        setState(() => _isProcessing = false);

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pembelian Berhasil!'), backgroundColor: Colors.green),
                          );
                          
                          setState(() {
                            product.stock -= _quantity; 
                            _adaTransaksiSukses = true;  
                            _quantity = 1;              
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pembelian Gagal! Periksa stok kembali.'), backgroundColor: Colors.redAccent),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}