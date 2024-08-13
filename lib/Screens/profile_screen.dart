import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ourchat/Models/chat_user_model.dart';
import 'package:ourchat/utils.dart';

import '../API/api.dart';
import '../Auth/login_screen.dart';
import '../Controllers/ThemeController.dart';
import '../main.dart';

//profile screen -- to show signed in user info
class ProfileScreen extends StatefulWidget {
  final ChatUserModel user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard
      onTap: FocusScope.of(context).unfocus,
      child: GetBuilder<ThemeController>(
          id: "0",
          builder: (theme) {
            return Scaffold(
              backgroundColor: theme.backgroundColor2,
                //app bar
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_outlined, color: theme.textColor,),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                    backgroundColor: theme.appbar,
                    title: Text(
                  'Profile Screen',
                  style: TextStyle(color: theme.textColor),
                )),

                //body
                body: Form(
                  key: _formKey,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // for adding some space
                          SizedBox(width: mq.width, height: mq.height * .03),

                          //user profile picture
                          Stack(
                            children: [
                              //profile picture
                              _image != null
                                  ?

                                  //local image
                                  ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(mq.height * .1),
                                      child: Image.file(File(_image!),
                                          width: mq.height * .2,
                                          height: mq.height * .2,
                                          fit: BoxFit.cover))
                                  :

                                  //image from server
                                  ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(mq.height * .1),
                                      child: CachedNetworkImage(
                                        width: mq.height * .2,
                                        height: mq.height * .2,
                                        fit: BoxFit.cover,
                                        imageUrl: widget.user.image,
                                        errorWidget: (context, url, error) =>
                                            const CircleAvatar(
                                                child: Icon(
                                                    CupertinoIcons.person)),
                                      ),
                                    ),

                              //edit image button
                              Positioned(
                                bottom: 0,
                                right: 0,
                                left: 100,
                                child: MaterialButton(
                                  elevation: 1,
                                  onPressed: () {
                                    _showBottomSheet();
                                  },
                                  shape: const CircleBorder(),
                                  color: Colors.white,
                                  child: const Icon(Icons.edit,
                                      color: Colors.blue),
                                ),
                              )
                            ],
                          ),

                          // for adding some space
                          SizedBox(height: mq.height * .03),

                          // user email label
                          Text(widget.user.email,
                              style: TextStyle(
                                  color: theme.textColor, fontSize: 16)),

                          // for adding some space
                          SizedBox(height: mq.height * .05),

                          // name input field
                          TextFormField(
                            initialValue: widget.user.name,
                            onSaved: (val) => APIs.me.name = val ?? '',
                            validator: (val) => val != null && val.isNotEmpty
                                ? null
                                : 'Required Field',
                            style: TextStyle(color: theme.textColor),
                            decoration: InputDecoration(
                                hintStyle: TextStyle(color: theme.textColor),
                                prefixIcon: Icon(Icons.person,
                                    color: theme.textColor),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                hintText: 'eg. John Doe',
                                label: Text(
                                  'Name',
                                  style: TextStyle(color: theme.textColor),
                                )),
                          ),

                          // for adding some space
                          SizedBox(height: mq.height * .02),

                          // about input field
                          TextFormField(
                            initialValue: widget.user.about,
                            onSaved: (val) => APIs.me.about = val ?? '',
                            validator: (val) => val != null && val.isNotEmpty
                                ? null
                                : 'Required Field',
                            style: TextStyle(color: theme.textColor),
                            decoration: InputDecoration(
                                hintStyle: TextStyle(color: theme.textColor),
                                prefixIcon: Icon(Icons.info_outline,
                                    color: theme.textColor),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                hintText: 'eg. Feeling Happy',
                                label: Text(
                                  'About',
                                  style: TextStyle(color: theme.textColor),
                                )),
                          ),

                          // for adding some space
                          SizedBox(height: mq.height * .05),

                          // update profile button
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                foregroundColor: theme.textColor,
                                backgroundColor: theme.appbar,
                                shape: const StadiumBorder(),
                                minimumSize:
                                    Size(mq.width * .5, mq.height * .06)),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                APIs.updateUserInfo().then((value) {
                                  Utils.showSnackbar(
                                      'Successful!', 'Profile Updated Successfully!');
                                });
                              }
                            },
                            icon: Icon(
                              Icons.edit,
                              size: 20,
                              color: theme.textColor,
                            ),
                            label: Text('UPDATE',
                                style: TextStyle(
                                    fontSize: 16, color: theme.textColor)),
                          )
                        ],
                      ),
                    ),
                  ),
                ));
          }),
    );
  }

  // bottom sheet for picking a profile picture for user
  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return GetBuilder<ThemeController>(
              id: "0",
              builder: (theme) {
                return Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20.0),
                        topLeft: Radius.circular(20.0)),
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.only(
                        top: mq.height * .03, bottom: mq.height * .05),
                    children: [
                      //pick profile picture label
                      Text('Pick Profile Picture',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: theme.textColor)),

                      //for adding some space
                      SizedBox(height: mq.height * .02),

                      //buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          //pick from gallery button
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: const CircleBorder(),
                                  fixedSize:
                                      Size(mq.width * .2, mq.height * .10)),
                              onPressed: () async {
                                final ImagePicker picker = ImagePicker();

                                // Pick an image
                                final XFile? image = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 80,
                                  preferredCameraDevice: CameraDevice.front
                                );
                                if (image != null) {
                                  log('Image Path: ${image.path}');
                                  setState(() {
                                    _image = image.path;
                                  });

                                  APIs.updateProfilePicture(File(_image!));

                                  // for hiding bottom sheet
                                  if (mounted) Navigator.pop(context);
                                }
                              },
                              child: Image.asset('images/gallery.png',)),

                          //take picture from camera button
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: const CircleBorder(),
                                  fixedSize:
                                      Size(mq.width * .2, mq.height * .10)),
                              onPressed: () async {
                                final ImagePicker picker = ImagePicker();

                                // Pick an image
                                final XFile? image = await picker.pickImage(
                                    source: ImageSource.camera,
                                    imageQuality: 50);
                                if (image != null) {
                                  log('Image Path: ${image.path}');
                                  setState(() {
                                    _image = image.path;
                                  });

                                  APIs.updateProfilePicture(File(_image!));

                                  // for hiding bottom sheet
                                  if (mounted) Navigator.pop(context);
                                }
                              },
                              child: Image.asset('images/camera.png')),
                        ],
                      )
                    ],
                  ),
                );
              });
        });
  }
}
