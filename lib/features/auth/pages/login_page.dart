import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Provider&Repository/auth_service.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Image.asset(
                        "assets/images/youtube-signin.jpg",
                        height: constraints.maxWidth * 0.4,
                      ),
                    ),
                    Text(
                      "Xin chào tới với TuTu",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: constraints.maxWidth * 0.1,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 40),
                    GestureDetector(
                      onTap: () async {
                        await ref.read(authServiceProvider).signInWithGoogle();
                      },
                      child: Image.asset(
                        "assets/images/signinwithgoogle.png",
                        height: constraints.maxWidth * 0.15,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
