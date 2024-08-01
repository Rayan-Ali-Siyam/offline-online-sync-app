import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_page_ctrl.dart';
import '../models/user.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    HomePageCtrl ctrl = Get.put(HomePageCtrl());
    ctrl.fetchAllUsers();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Offline-Online Sync"),
        actions: [
          IconButton(
            onPressed: () => ctrl.sync(context),
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      body: Center(
        child: Obx(
          () {
            if (ctrl.isLoading.value) {
              return const CircularProgressIndicator();
            } else if (ctrl.users.isEmpty) {
              return Center(
                child: Text(
                  "No Users created yet.",
                  style: context.textTheme.labelLarge,
                ),
              );
            } else {
              return ListView.builder(
                itemCount: ctrl.users.length,
                itemBuilder: (context, index) {
                  User user = ctrl.users[index];
                  return ListTile(
                    onTap: () => ctrl.onUserTapped(context, user),
                    leading: Text(user.id!.toString()),
                    title: Text(user.name),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ctrl.onAddUserTapped(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
