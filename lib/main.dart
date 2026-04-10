import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBNXdk7Z2O5z6puh7lhHPj7qOIhv6xiJgA",
      authDomain: "fixly-qatar.firebaseapp.com",
      projectId: "fixly-qatar",
      storageBucket: "fixly-qatar.firebasestorage.app",
      messagingSenderId: "978364693359",
      appId: "1:978364693359:web:c65d8bb2de77215635c69a",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdminOrdersScreen(),
    );
  }
}

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin - Fixly Qatar"),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final o = orders[index];

              // ✅ SAFE DATA (no crash if missing)
              final service = o['service'] ?? '';
              final address = o['address'] ?? '';
              final notes = o['notes'] ?? '';
              final status = o['status'] ?? 'pending';

              // 👇 IMPORTANT FIX HERE
              final phone = o.data().toString().contains('phone')
                  ? o['phone']
                  : 'No phone';

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(service),
                  subtitle: Text(
                    "$address\nPhone: $phone\n$notes",
                  ),
                  isThreeLine: true,
                  trailing: DropdownButton<String>(
                    value: status,
                    items: ["pending", "confirmed", "on the way", "done"]
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            ))
                        .toList(),
                    onChanged: (value) {
                      FirebaseFirestore.instance
                          .collection('orders')
                          .doc(o.id)
                          .update({"status": value});
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}