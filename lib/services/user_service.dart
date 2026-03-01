// // lib/services/user_service.dart

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class UserService {
//   Future<void> saveUserData({
//     required String name,
//     required String phone,
//   }) async {
//     final user = FirebaseAuth.instance.currentUser;

//     if (user == null) {
//       print('Kullanıcı oturum açmamış!');
//       return;
//     }

//     final docRef =
//         FirebaseFirestore.instance.collection('users').doc(user.uid);

//     await docRef.set(
//       {
//         'name': name,
//         'phone': phone,
//         'updatedAt': FieldValue.serverTimestamp(),
//       },
//       SetOptions(merge: true), // Eski veriyi silmeden ÜZERİNE yazar
//     );

//     print('Kullanıcı verisi kaydedildi / güncellendi ✅');
//   }
// }
