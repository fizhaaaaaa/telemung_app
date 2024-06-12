import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> tambahItemKeKeranjang(Map<String, dynamic> item) async {
    try {
      await _firestore.collection('keranjang').add(item);
    } catch (e) {
      print('Error: $e');
    }
  }
}
