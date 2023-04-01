import 'package:doc_sys_pro/loginController.dart';
import 'package:doc_sys_pro/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatelessWidget {
  final controller = Get.put(LoginController());

  Map<String, String?> userData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DocSysPro'),
        backgroundColor: const Color.fromARGB(255, 25, 25, 25),
      ),

      body: Center(
        child: Obx(
          () {
            if (controller.googleAccount.value == null) {
              return buildLoginButton();
            } else {
                          
              userData.addAll({
                'id': controller.googleAccount.value!.id,
                'name' : controller.googleAccount.value!.displayName,
                'email' : controller.googleAccount.value!.email,
              });

              return buildProfileView(context);
            }
          }
        ),  
      )
    );
  }

  Column buildProfileView(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          CircleAvatar(
            backgroundImage: Image.network(controller.googleAccount.value?.photoUrl ?? '').image,
            radius: 100,
          ),

          Text(
            controller.googleAccount.value?.displayName ?? '',
            style: Get.textTheme.headline5,
          ),

          Text(
            controller.googleAccount.value?.email ?? '',
            style: Get.textTheme.bodyText1,
          ),

          const SizedBox(height: 16),

          ActionChip(
            label: const Text('Перейти до застосунку'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                  HomeScreen(userData)
                )
              );
            },
          ),

          ActionChip(
            label: const Text('Вийти з акаунту'),
            onPressed: () {
              controller.logout();
            },
          ),
        
        ],
      );
  }

  FloatingActionButton buildLoginButton() {
    return FloatingActionButton.extended(
        label: const Text("Увійти з Google"), 
        onPressed: () {
          controller.login();
        },
        foregroundColor: const Color.fromARGB(255, 246, 246, 246),
        backgroundColor: const Color.fromARGB(255, 40, 40, 40),
      );
  }
}