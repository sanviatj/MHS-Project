class Weapon {
  final String? id;
  final String name;
  final String type;
  final String description;
   int stock;
  final String image;
  final int price;

  Weapon({
    this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.stock,
    required this.image,
    required this.price,
  });

  factory Weapon.fromJson(Map<String, dynamic> json) {
    return Weapon(
      id: json['id']?.toString(),
      name: json['name'],
      type: json['type'],
      description: json['description'],
      stock: int.parse(json['stock'].toString()),
      image: json['image'],
      price: int.parse(json['price'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'type': type,
      'description': description,
      'stock': stock,
      'image': image,
      'price': price,
    };
  }
}