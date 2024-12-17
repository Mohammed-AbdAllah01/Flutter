class Product {
  final String name;
  final double price;
  final String imageUrl;
  final String category;
  final String description;

  Product({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.description,
  });


// Factory constructor to create a Product instance from a map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      category: map['category'],
      name: map['name'],
      imageUrl: map['imageUrl'],
      price: map['price'],
      description: map['description']
    );
  }

}
