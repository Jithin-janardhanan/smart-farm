import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/view/profile.dart';

class home extends StatelessWidget {
  const home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Smart farm'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () => Get.to(ProfilePage()),
              icon: Icon(Icons.person),
            ),
          ),
        ],
      ),
    );
  }
}
