import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class EditMenuPage extends StatefulWidget {
  final DocumentSnapshot document;

  const EditMenuPage({Key? key, required this.document}) : super(key: key);

  @override
  _EditMenuPageState createState() => _EditMenuPageState();
}

class _EditMenuPageState extends State<EditMenuPage> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> data = widget.document.data()! as Map<String, dynamic>;
    _nameController = TextEditingController(text: data['name']);
    _priceController = TextEditingController(text: data['price'].toString());
    _stockController = TextEditingController(text: data['stock'].toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Menu'),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
            ),
            TextField(
              controller: _stockController,
              decoration: InputDecoration(labelText: 'Stock'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                _pickImage();
              },
              child: Text('Pick Image'),
            ),
            SizedBox(height: 20),
            _imageFile == null
                ? Container()
                : Image.file(
                    _imageFile!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String name = _nameController.text;
                String priceText = _priceController.text;
                String stockText = _stockController.text;

                if (name.isNotEmpty &&
                    priceText.isNotEmpty &&
                    stockText.isNotEmpty) {
                  int price = int.parse(priceText);
                  int stock = int.parse(stockText);

                  if (_imageFile != null) {
                    // Upload new image to Firebase Storage
                    Reference ref = FirebaseStorage.instance.ref().child(
                        'menu_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
                    UploadTask uploadTask = ref.putFile(_imageFile!);
                    TaskSnapshot taskSnapshot =
                        await uploadTask.whenComplete(() => null);
                    String imageUrl = await taskSnapshot.ref.getDownloadURL();

                    // Update document in Firestore with new image URL
                    await widget.document.reference.update({
                      'name': name,
                      'price': price,
                      'stock': stock,
                      'image': imageUrl,
                    });
                  } else {
                    // Update document in Firestore without changing the image
                    await widget.document.reference.update({
                      'name': name,
                      'price': price,
                      'stock': stock,
                    });
                  }

                  // Show a snackbar to indicate success
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Menu updated successfully')),
                  );

                  // Navigate back to previous screen
                  Navigator.pop(context);
                } else {
                  // Show an error message if any field is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in all fields')),
                  );
                }
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }
}
