import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_online_sync_app/databases/app_database.dart';
import 'package:offline_online_sync_app/services/api_service.dart';

import '../models/user.dart';

class HomePageCtrl extends GetxController {
  RxList<User> users = <User>[].obs;
  RxBool isLoading = false.obs;

  TextEditingController nameTxtCtrl = TextEditingController();

  Future<List<User>> fetchAllUsers() async {
    isLoading.toggle();
    users.value = await AppDatabase.instance.readAllUsers();
    isLoading.toggle();
    return users;
  }

  onUserTapped(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameTxtCtrl,
                decoration: const InputDecoration(hintText: "New Name"),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () => _onUserDelete(user),
              icon: const Icon(Icons.delete),
            ),
            ElevatedButton(
              onPressed: () => _onCancel(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => _onUserUpdate(context, user),
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  _onUserDelete(User user) {
    Get.dialog(
      const Dialog(
        child: CircularProgressIndicator(),
      ),
    );
    AppDatabase.instance.deleteUser(int.parse(user.id!)).then((value) {
      Get.back();
      fetchAllUsers();
    });
  }

  _onCancel(BuildContext context) => Navigator.pop(context);

  _onUserUpdate(BuildContext context, User user) {
    nameTxtCtrl.text.isEmpty
        ? ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Input new name first",
              ),
            ),
          )
        : AppDatabase.instance
            .updateUser(
            User(
              createdAt: user.createdAt,
              name: nameTxtCtrl.text,
              avatar: user.avatar,
              id: user.id,
            ),
          )
            .then((value) {
            Get.back();
            fetchAllUsers();
          });
    fetchAllUsers();
  }

  onAddUserTapped(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameTxtCtrl,
                decoration: const InputDecoration(
                  hintText: "User Name",
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => _onCancel(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => _onUserCreate(context),
              child: const Text("Post"),
            ),
          ],
        );
      },
    );
  }

  _onUserCreate(BuildContext context) async {
    nameTxtCtrl.text.trim();

    nameTxtCtrl.text.isEmpty
        ? ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Input User Name first",
              ),
            ),
          )
        : await AppDatabase.instance
            .createUser(
            User(
              createdAt: DateTime.now(),
              name: nameTxtCtrl.text,
            ),
          )
            .then((value) async {
            Navigator.pop(context);
            await fetchAllUsers();
          });

    nameTxtCtrl.clear();
  }

  sync(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text("Syncing.."),
          content: LinearProgressIndicator(),
        );
      },
    );

    ApiService().syncWithLocal().then((value) => Get.back());
  }
}
