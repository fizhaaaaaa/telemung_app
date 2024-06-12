import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _totalPrice = 0;
  Map<String, int> _cartItems = {};
  Map<String, Map<String, dynamic>> _selectedItems = {};

  void _addToSelectedItems(
      String itemId, String name, String image, int price) {
    setState(() {
      if (_selectedItems.containsKey(itemId)) {
        _selectedItems[itemId]!['quantity']++;
      } else {
        _selectedItems[itemId] = {
          'name': name,
          'image': image,
          'price': price,
          'quantity': 1
        };
      }
      _totalPrice += price;
    });
  }

  void _removeFromSelectedItems(String itemId, int price) {
    setState(() {
      if (_selectedItems.containsKey(itemId)) {
        if (_selectedItems[itemId]!['quantity'] > 1) {
          _selectedItems[itemId]!['quantity']--;
        } else {
          _selectedItems.remove(itemId);
        }
        _totalPrice -= price;
      }
    });
  }

  Future<void> _addAllToCart() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    final cartRef = FirebaseFirestore.instance
        .collection('keranjang')
        .doc(uid)
        .collection('items');

    for (var entry in _selectedItems.entries) {
      final itemId = entry.key;
      final itemData = entry.value;

      final cartItemSnapshot = await cartRef.doc(itemId).get();

      if (cartItemSnapshot.exists) {
        await cartRef.doc(itemId).update({
          'quantity': FieldValue.increment(itemData['quantity']),
        });
      } else {
        await cartRef.doc(itemId).set({
          'name': itemData['name'],
          'image': itemData['image'],
          'price': itemData['price'],
          'quantity': itemData['quantity'],
        });
      }
    }

    setState(() {
      _selectedItems.clear();
      _totalPrice = 0;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Menu Berhasil Ditambahkan'),
          content: Text('Cek keranjang kamu buat checkout.'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.black, // Warna latar belakang tombol menjadi merah
              ),
              child: Text(
                'Yes',
                style:
                    TextStyle(color: Colors.white), // Warna teks menjadi putih
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuCard(String name, String assetPath, String price, int stock,
      String itemId, String description) {
    return GestureDetector(
      onTap: () {
        _showMenuDetailsDialog(name, assetPath, price, stock, description);
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(assetPath, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    price,
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          _removeFromSelectedItems(
                              itemId,
                              int.parse(price
                                  .replaceAll('Rp ', '')
                                  .replaceAll(',', '')));
                        },
                        icon: Icon(Icons.remove),
                        color: Colors.black,
                      ),
                      Text(
                        _selectedItems.containsKey(itemId)
                            ? _selectedItems[itemId]!['quantity'].toString()
                            : '0',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _addToSelectedItems(
                              itemId,
                              name,
                              assetPath,
                              int.parse(price
                                  .replaceAll('Rp ', '')
                                  .replaceAll(',', '')));
                        },
                        icon: Icon(Icons.add),
                        color: Colors.black,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMenuDetailsDialog(String name, String assetPath, String price,
      int stock, String description) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(name),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(assetPath),
              const SizedBox(height: 10),
              Text('$price'),
              Text('Stock: $stock'),
              if (description.isNotEmpty) Text('$description'),
              if (description.isEmpty) Text('Description not available'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.black, // Warna teks putih
                padding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10), // Padding tombol
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Bentuk sudut tombol
                ),
              ),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('menu').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var menuItems = snapshot.data!.docs;

          if (menuItems.isEmpty) {
            return Center(
              child: Text(
                'Yah menu masih kosong nih tunggu yaa :(',
                style: GoogleFonts.poppins(fontSize: 18),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Menu',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3 / 4,
                    ),
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      var item = menuItems[index];
                      return _buildMenuCard(
                        item['name'],
                        item['image'],
                        'Rp ${item['price']}',
                        item['stock'],
                        item.id,
                        item['description'],
                      );
                    },
                  ),
                ),
                if (_totalPrice > 0)
                  Container(
                    padding: EdgeInsets.all(16),
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: Rp $_totalPrice',
                          style: GoogleFonts.poppins(
                              fontSize: 18, color: Colors.black),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _addAllToCart();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            textStyle: GoogleFonts.poppins(color: Colors.white),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Add to cart',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
