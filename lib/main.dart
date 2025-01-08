import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubetube/cores/firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubetube/cores/screens/loader.dart';
import 'package:tubetube/features/auth/pages/username_page.dart';
import 'package:tubetube/home_page.dart';
import 'features/auth/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    Phoenix(
      child: ProviderScope(child: MyApp()),
    ),
  );
}


Future<void> clearLocalData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If no user is signed in, show the login page
          if (!snapshot.hasData) {
            clearLocalData();
            return LoginPage();

          }
          else if (snapshot.connectionState == ConnectionState.waiting) {
            return Loader();
          }

          // Otherwise, check if the user's data exists
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(snapshot.data!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              final user = FirebaseAuth.instance.currentUser;

              // If user data is not available or not found, show the username page
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return UsernamePage(
                  displayName: user?.displayName ?? 'Unknown',
                  profilePic: user?.photoURL ?? 'https://firebasestorage.googleapis.com/v0/b/tubetube-1c56c.firebasestorage.app/o/User.png?alt=media&token=123f8c77-4e9f-40c4-a6f5-4e2d5e3fc719',
                  email: user?.email ?? '',
                );
              }
              // If data is still loading, show the loader
              else if (snapshot.connectionState == ConnectionState.waiting) {
                return Loader();
              }
              // If everything is ready, show the home page
              return HomePage();
            },
          );
        },
      ),
    );
  }
}
