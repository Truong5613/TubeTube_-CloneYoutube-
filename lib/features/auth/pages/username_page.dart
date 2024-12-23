import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubetube/cores/widgets/flat_button.dart';
import 'package:tubetube/features/auth/repository/auth_service.dart';
import 'package:tubetube/features/auth/repository/user_data_service.dart';

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
  bool isValidate = true;

  void validateUsername() async {
    final usersMap = await FirebaseFirestore.instance.collection("users").get();
    final users = usersMap.docs.map((user) => user).toList();
    String? targetedUsername;

    for (var user in users) {
      if (usernameController.text == user.data()["username"]) {
        targetedUsername = user.data()["username"];
        isValidate = false;
        setState(() {});
      }
      if (usernameController.text != targetedUsername) {
        isValidate = true;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 26, horizontal: 14),
                child: Text(
                  "Chọn tên người dùng",
                  style: TextStyle(color: Colors.blueGrey),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Form(
                  child: TextFormField(
                    onChanged: (username) {
                      validateUsername();
                    },
                    autovalidateMode: AutovalidateMode.always,
                    validator: (username) {
                      return isValidate ? null : "Tên người dùng đã tồn tại!";
                    },
                    key: formKey,
                    controller: usernameController,
                    decoration: InputDecoration(
                      suffixIcon: isValidate
                          ? const Icon(Icons.verified_user_rounded)
                          : const Icon(Icons.cancel),
                      suffixIconColor: isValidate ? Colors.green : Colors.red,
                      hintText: "Nhập tên người dùng",
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 40, left: 10, right: 10),
                child: FlatButton(
                    text: "Tiếp tục",
                    onPressed: () async {
                      // add users data inside datebase
                      isValidate
                          ? await ref
                          .read(userDataServiceProvider)
                          .addUserDataToFirestore(
                        displayName: widget.displayName,
                        username: usernameController.text,
                        email: widget.email,
                        description: "",
                        profilePic: widget.profilePic,
                      )
                          : null;
                    },
                    colour: isValidate ? Colors.green : Colors.green.shade100),
              ),
            ],
          ),
        ));
  }
}
