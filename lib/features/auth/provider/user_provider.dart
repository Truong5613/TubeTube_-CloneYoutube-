import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubetube/features/Model/user_model.dart';
import 'package:tubetube/features/auth/repository/user_data_service.dart';

final currentUserProvider = FutureProvider<UserModel>((ref) async {
  final UserModel user =
      await ref.watch(userDataServiceProvider).fetchCurrentUserData();
  return user;
});

final anyUserDataProvider = FutureProvider.family((ref, userId) async {
  final UserModel user =
      await ref.watch(userDataServiceProvider).fetchAnyUserData(userId);
  return user;
});
