import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubetube/features/Model/user_model.dart';
import 'package:tubetube/features/Provider&Repository/user_data_service.dart';

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
final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final List<UserModel> allUsers =
  await ref.watch(userDataServiceProvider).fetchAllUsers();
  final currentUser = await ref.watch(currentUserProvider.future);
  return allUsers.where((user) => user.userId != currentUser.userId).toList();
});

