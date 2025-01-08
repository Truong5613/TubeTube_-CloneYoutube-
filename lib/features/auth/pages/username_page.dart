import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubetube/cores/widgets/flat_button.dart';
import 'package:tubetube/features/Provider&Repository/user_data_service.dart';

final formKey = GlobalKey<FormState>();

class UsernamePage extends ConsumerStatefulWidget {
  final String displayName;
  final String profilePic;
  final String email;

  const UsernamePage({
    required this.displayName,
    required this.profilePic,
    required this.email,
  });

  @override
  ConsumerState<UsernamePage> createState() => _UsernamePageState();
}

class _UsernamePageState extends ConsumerState<UsernamePage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();
  bool isValidate = true;

  @override
  void initState() {
    super.initState();
  }

  Future<void> validateUsername() async {
    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .where('username', isEqualTo: usernameController.text)
        .get();

    setState(() {
      isValidate = userDoc.docs.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Chọn tên người dùng",
                      style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    onChanged: (username) {
                      validateUsername();
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (username) {
                      return isValidate ? null : "Tên người dùng đã tồn tại!";
                    },
                    controller: usernameController,
                    decoration: InputDecoration(
                      suffixIcon: isValidate
                          ? const Icon(Icons.verified_user_rounded)
                          : const Icon(Icons.cancel),
                      suffixIconColor: isValidate ? Colors.green : Colors.red,
                      hintText: "Nhập tên người dùng",
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Conditional Display Name Text Field
                  if (widget.displayName == "Unknown") ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      // Align to the left edge
                      child: Text(
                        "Nhập Tên Hiển Thị",
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: displayNameController,
                      validator: (value) => value!.isEmpty
                          ? "Tên hiển thị không được để trống!"
                          : null,
                      decoration: const InputDecoration(
                        hintText: "Nhập tên hiển thị",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const Spacer(),

          // Continue Button
          Padding(
            padding: const EdgeInsets.only(bottom: 40, left: 10, right: 10),
            child: FlatButton(
              text: "Tiếp tục",
              onPressed: () async {
                if (isValidate && formKey.currentState?.validate() == true) {
                  await ref
                      .read(userDataServiceProvider)
                      .addUserDataToFirestore(
                        displayName: displayNameController.text.isNotEmpty
                            ? displayNameController.text
                            : widget.displayName,
                        username: usernameController.text,
                        email: widget.email,
                        description: "",
                        profilePic: widget.profilePic,
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tạo tài khoản thành công!')),
                  );
                }
              },
              colour: isValidate ? Colors.green : Colors.green.shade100,
            ),
          ),
        ],
      ),
    ));
  }
}
