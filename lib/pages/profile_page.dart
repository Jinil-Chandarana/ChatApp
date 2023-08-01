import 'dart:io';

import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth_service.dart';
import 'auth/login_page.dart';
import 'home_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  ProfilePage({super.key, required this.email, required this.userName});
  String userName;
  String email;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? profileImageUrl = "";
  File? profileImageFile;
  final profilePic =
      DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .getProfilePics();

  Future profilePickImage() async {
    try {
      final profileImageFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (profileImageFile == null) return;
      final String imgDevicePath = profileImageFile.path;
      final String imgID =
          "${widget.userName} " + " ${imgDevicePath.replaceAll('/', '')}";
      Reference imgRef =
          FirebaseStorage.instance.ref().child('profile').child(imgID);
      await imgRef.putFile(File(imgDevicePath));
      profileImageUrl = await imgRef.getDownloadURL();
      if (profileImageUrl == null) {
        profileImageUrl = "";
      }
      // imgURL = await imgRef.getDownloadURL();
      final profileimageTemporary = File(imgDevicePath);
      setState(() {
        this.profileImageFile = profileimageTemporary;

        print("=== for url mage ====${profileImageUrl}");
        // print("=== url mage ====${profileImageFile}");
      });

      await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .addProfileImage(profileImageUrl!);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
              color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: Drawer(
          child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 50),
        children: <Widget>[
          FutureBuilder<String>(
            future: profilePic,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || snapshot.data == null) {
                // Handle any errors or if profilePic is null
                // You can display a default image or an icon indicating no image
                return const CircleAvatar(
                  backgroundImage: AssetImage("assets/default_profile_pic.png"),
                  radius: 50,
                );
              } else {
                String profilePicUrl = snapshot.data!;

                return CircleAvatar(
                  backgroundImage: NetworkImage(profilePicUrl),
                  radius: 60,
                );
              }
            },
          ),
          Text(
            widget.userName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 30,
          ),
          const Divider(
            height: 2,
          ),
          ListTile(
            onTap: () {
              nextPage(context, const HomePage());
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.group),
            title: const Text(
              "Groups",
              style: TextStyle(color: Colors.black),
            ),
          ),
          ListTile(
            onTap: () {},
            selected: true,
            selectedColor: Theme.of(context).primaryColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.person),
            title: const Text(
              "Profile",
              style: TextStyle(color: Colors.black),
            ),
          ),
          ListTile(
            onTap: () async {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await authService.signOut();
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                                (route) => false);
                          },
                          icon: const Icon(
                            Icons.done,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    );
                  });
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.exit_to_app),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      )),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 40,
        ),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 15,
            ),
            GestureDetector(
              onTap: () {
                profilePickImage();
              },
              child: profileImageUrl! != null
                  ? CircleAvatar(
                      radius: 90,
                      backgroundImage: NetworkImage(profileImageUrl!),
                    )
                  : CircleAvatar(
                      radius: 90,
                    ),
            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Full Name", style: TextStyle(fontSize: 17)),
                Text(widget.userName, style: const TextStyle(fontSize: 17)),
              ],
            ),
            const Divider(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Email", style: TextStyle(fontSize: 17)),
                Text(widget.email, style: const TextStyle(fontSize: 17)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
