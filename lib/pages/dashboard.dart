import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:telemung/pages/login.dart';
import 'keranjang.dart';
import 'menu.dart';
import 'pesanan.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const HomeScreen(),
    const MenuScreen(),
    KeranjangScreen(),
    PesananScreen(),
  ];

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to log out?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Logout"),
              onPressed: () {
                Navigator.of(context).pop();
                _signOut(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Text('Telemung App', style: TextStyle(color: Colors.black)),
                    SizedBox(width: 10),
                  ],
                ),
                GestureDetector(
                  onTap: () => _showLogoutDialog(context),
                  child: Image.asset('assets/degan.png', height: 40),
                ),
              ],
            ),
          ),
          body: _pages[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu),
                label: 'Menu',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'Keranjang',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt),
                label: 'Pesanan',
              ),
            ],
            selectedItemColor: Colors.black, // Warna teks yang dipilih
            unselectedItemColor: Colors.black, // Warna teks yang tidak dipilih
            backgroundColor: Colors.white, // Warna latar belakang
            showSelectedLabels: true, // Menampilkan label yang dipilih
            showUnselectedLabels: true, // Menampilkan label yang tidak dipilih
            type: BottomNavigationBarType.fixed, // Memastikan ukuran item tetap
            selectedFontSize: 14, // Ukuran font teks yang dipilih
            unselectedFontSize: 14, // Ukuran font teks yang tidak dipilih
            elevation: 0, // Menghilangkan bayangan bawah
          ),
        ));
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 200.0,
              autoPlay: true,
              enlargeCenterPage: true,
            ),
            items: ['slider1.jpg', 'slider2.jpg', 'slider3.jpg', 'slider4.jpg']
                .map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Image.asset('assets/$i',
                      fit: BoxFit.cover, width: 1000);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Features',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                const SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  childAspectRatio: 0.7,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildFeatureCard(
                        'Dikemas dengan kemasan yang rapih dan higienis',
                        'assets/box.png'),
                    _buildFeatureCard('Baik untuk kesehatan tanpa pengawet',
                        'assets/love.png'),
                    _buildFeatureCard('Bahan diolah dari air kelapa asli',
                        'assets/garpu.png'),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  margin: const EdgeInsets.all(8.0),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            'Telemung Indonesia',
                            style: GoogleFonts.poppins(
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(
                                    color: Colors.black,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '“Menghadirkan sensasi minuman yang tak hanya menyegarkan, tetapi juga memanjakan selera. '
                          'Dengan bahan-bahan pilihan terbaik, kami menciptakan rasa yang luar biasa dalam setiap tegukan, '
                          'memberikan kebahagiaan dalam setiap cangkir. Nikmati kelezatan yang tak terlupakan bersama Telemung Indonesia.”',
                          textAlign: TextAlign.justify,
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 16.0,
                              height: 1.5,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    'Rekomendasi Menu',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                const SizedBox(height: 10),
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance.collection('menu').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    final List<DocumentSnapshot> menus = snapshot.data!.docs;

                    // Ambil 3 item secara acak dari daftar menu
                    final List<DocumentSnapshot> randomMenus = menus
                      ..shuffle(); // Acak urutan item
                    final limitedMenus =
                        randomMenus.take(3).toList(); // Ambil 3 item pertama

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: limitedMenus.map((menuData) {
                            return Expanded(
                              child: _buildMenuCard(
                                context,
                                menuData['name'],
                                menuData['image'],
                                'Rp ${menuData['price']}',
                                menuData,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String description, String assetPath) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(assetPath, height: 80),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String name, String assetPath,
      String price, DocumentSnapshot menuData) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () {
              _showMenuDetailDialog(context, menuData);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(assetPath, height: 150, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
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
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _addToCart(context, menuData);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: Text(
                    'Buy Now',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(BuildContext context, DocumentSnapshot menuData) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Cek apakah item dengan nama yang sama sudah ada dalam keranjang
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('keranjang')
          .doc(uid)
          .collection('items')
          .where('name', isEqualTo: menuData['name'])
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Jika item sudah ada, tambahkan jumlah quantity
        final DocumentSnapshot cartItem = querySnapshot.docs.first;
        int currentQuantity = cartItem['quantity'];
        await cartItem.reference.update({'quantity': currentQuantity + 1});
      } else {
        // Jika item belum ada, tambahkan item baru ke keranjang
        await FirebaseFirestore.instance
            .collection('keranjang')
            .doc(uid)
            .collection('items')
            .add({
          'name': menuData['name'],
          'image': menuData['image'],
          'price': menuData['price'],
          'quantity': 1,
        });
      }

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
                  style: TextStyle(
                      color: Colors.white), // Warna teks menjadi putih
                ),
              ),
            ],
          );
        },
      );
    } catch (error) {
      print('Error adding to cart: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add item to cart. Please try again later.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showMenuDetailDialog(BuildContext context, DocumentSnapshot menuData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(menuData['name']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(menuData['image']),
              SizedBox(height: 10),
              Text(menuData['description']),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
