import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> addProduct({
  required String name,
  required double price,
  required int quantity,
  String imageUrl = '',
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception('User not logged in');
  }

  final productData = {
    'name': name,
    'price': price,
    'quantity': quantity,
    'imageUrl': imageUrl,
    'createdAt': FieldValue.serverTimestamp(),
    'createdBy': user.uid,
  };

  await FirebaseFirestore.instance.collection('products').add(productData);
}

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  Future<void> _submitProduct() async {
    if (_formKey.currentState!.validate()) {
      // TODO: Save product to Firebase or another backend
      await addProduct(
        name: _nameController.text,
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        imageUrl: '',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product submitted!')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter product name' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Product Price',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter price';
                  final price = double.tryParse(value);
                  return price == null || price <= 0 ? 'Enter valid price' : null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Product Quantity (min 10)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter quantity';
                  final qty = int.tryParse(value);
                  return qty == null || qty < 10
                      ? 'Minimum quantity is 10'
                      : null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Browse Image (Disabled)',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.image_outlined),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _submitProduct,
                icon: const Icon(Icons.save),
                label: const Text('Submit Product'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
