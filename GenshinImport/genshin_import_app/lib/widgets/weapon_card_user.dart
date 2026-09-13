import 'package:flutter/material.dart';
import '../models/weapon_model.dart';

class WeaponCardUser extends StatelessWidget {
  final Weapon weapon;
  final VoidCallback onBuy;

  const WeaponCardUser({
    Key? key,
    required this.weapon,
    required this.onBuy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context, 
          '/product-detail', 
          arguments: weapon,
        );
      },
      child: Card(
        color: const Color(0xFF151B2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C111D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'http://localhost:3000/images/${weapon.image}',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.shield_moon_outlined, 
                        size: 50, 
                        color: Color(0xFFECC065)
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                weapon.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
              ),
              const SizedBox(height: 4),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: weapon.type == 'Weapon' 
                      ? Colors.redAccent.withOpacity(0.2) 
                      : Colors.blueAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  weapon.type,
                  style: TextStyle(
                    color: weapon.type == 'Weapon' ? Colors.redAccent : Colors.blueAccent, 
                    fontSize: 10,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${weapon.price}',
                        style: const TextStyle(color: Color(0xFFECC065), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const Text('Mora', style: TextStyle(color: Colors.white30, fontSize: 10)),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFECC065),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: onBuy,
                    child: const Text('Buy', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '• ${weapon.stock} in stock',
                style: const TextStyle(color: Colors.greenAccent, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}