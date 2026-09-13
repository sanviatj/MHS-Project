import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'dart:typed_data'; 
import '../models/weapon_model.dart';
import '../services/admin_service.dart';
import '../widgets/custom_text_field.dart';

class AdminFormScreen extends StatefulWidget {
  final Weapon? weapon;
  final String token;

  const AdminFormScreen({Key? key, this.weapon, required this.token}) : super(key: key);

  @override
  _AdminFormScreenState createState() => _AdminFormScreenState();
}

class _AdminFormScreenState extends State<AdminFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final AdminService _adminService = AdminService();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _stockController;
  late TextEditingController _priceController;
  late String _selectedType;

  Uint8List? _webImage; 
  final ImagePicker _picker = ImagePicker();
  String _imageName = 'placeholder.png';

  final List<String> _weaponTypes = ['Weapon', 'Artifact'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.weapon?.name ?? '');
    _descController = TextEditingController(text: widget.weapon?.description ?? '');
    _stockController = TextEditingController(text: widget.weapon?.stock.toString() ?? '');
    _priceController = TextEditingController(text: widget.weapon?.price.toString() ?? '');
    _imageName = widget.weapon?.image ?? 'placeholder.png';
    
    final initialType = widget.weapon?.type ?? 'Weapon';
    _selectedType = _weaponTypes.contains(initialType) ? initialType : 'Weapon';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      var f = await pickedFile.readAsBytes(); 
      setState(() {
        _webImage = f;
        _imageName = pickedFile.name;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      Weapon weaponData = Weapon(
        id: widget.weapon?.id,
        name: _nameController.text,
        type: _selectedType,
        description: _descController.text,
        stock: int.parse(_stockController.text),
        image: _imageName,
        price: int.parse(_priceController.text),
      );

bool success = widget.weapon == null
    ? await _adminService.createWeapon(weaponData, widget.token, _webImage, _imageName) 
    : await _adminService.updateWeapon(weaponData, widget.token, _webImage, _imageName);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data successfully saved!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save data.'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C111D),
      appBar: AppBar(
        title: Text(widget.weapon == null ? 'Add Item' : 'Edit Item', style: const TextStyle(color: Color(0xFFECC065), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF151B2C),
        iconTheme: const IconThemeData(color: Color(0xFFECC065)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFF151B2C),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFECC065).withOpacity(0.3), width: 2),
                    ),
                    child: _webImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.memory(_webImage!, fit: BoxFit.contain),
                          )
                        : widget.weapon != null && widget.weapon!.image.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.network(
                                  'http://localhost:3000/images/${widget.weapon!.image}', 
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.image, size: 44, color: Color(0xFFECC065));
                                  },
                                ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined, color: Color(0xFFECC065), size: 44),
                                  SizedBox(height: 6),
                                  Text('Add Image', style: TextStyle(color: Colors.white54, fontSize: 11)),
                                ],
                              ),
                  ),
                ),
              ),
              if (_webImage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Center(
                    child: Text(_imageName, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ),
                ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _nameController,
                label: 'Item Name',
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                dropdownColor: const Color(0xFF151B2C),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Item Type',
                  labelStyle: TextStyle(color: Color(0xFFECC065)),
                ),
                items: _weaponTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _stockController,
                label: 'Stock',
                keyboardType: TextInputType.number,
                validator: (val) => val == null || int.tryParse(val) == null || int.parse(val) < 0 ? 'Invalid stock' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _priceController,
                label: 'Price (Mora)',
                keyboardType: TextInputType.number,
                validator: (val) => val == null || int.tryParse(val) == null || int.parse(val) < 1000 ? 'Min 1,000 Mora' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descController,
                label: 'Description',
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFECC065),
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _submitForm,
                child: Text(widget.weapon == null ? 'Insert' : 'Update', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}