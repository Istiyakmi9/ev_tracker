import 'dart:convert';
import 'dart:io';

import 'package:ev_tracker/modal/Configuration.dart';
import 'package:ev_tracker/modal/appData.dart';
import 'package:ev_tracker/widgets/CustomAppBar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../modal/applicationUser.dart';
import '../../../service/ajax.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final _formKey = GlobalKey<FormState>();
  String _imagePath = "";
  File? _imageFile;
  ApplicationUser? _user;
  bool isSaving = false;
  Ajax ajax = Ajax.getInstance();

  void showPopup(String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('User profile status'),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(msg),
          ),
          actions: [
            ElevatedButton(
              child: const Text("Ok"),
              onPressed: () {
                // your code
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  void _onSubmitted() async {
    _formKey.currentState?.save();

    setState(() {
      isSaving = true;
    });

    try {
      if (_user != null && _user!.userId > 0) {
        var userData = {
          "userId": _user!.userId,
          "firstName": _user!.firstName,
          "lastName": _user!.lastName,
          "dob": DateFormat('yyyy-MM-dd HH:mm:ss').format(_user!.dob),
          "mobile": _user!.mobile,
          "email": _user!.email,
          "firstAddress": _user!.firstAddress,
          "secondAddress": _user!.secondAddress,
          "state": _user!.state,
          "city": _user!.city,
          "country": _user!.country
        };

        var status = await ajax.upload(
            "user/updateUser/${_user!.userId}", _imageFile, userData);
        if (status) {
          debugPrint("Record updated successfully.");
          showPopup("Record updated successfully.");
        } else {
          debugPrint("Fail to updated record.");
          showPopup("Fail to updated record.");
        }

        setState(() {
          isSaving = false;
        });
      }
    } on Exception catch (_) {
      setState(() {
        isSaving = false;
      });
    }
  }

  Future<dynamic> getUserByEmail(String email) async {
    return ajax.get("user/getUserByEmail/$email").then((dynamic value) {
      return value;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var user = Provider.of<AppData>(context, listen: false).user;
      getUserByEmail(user.email).then((value) {
        if (value != null) {
          var currentUser = ApplicationUser.fromJson(value);
          String path = "";
          if (currentUser.filePath != null) {
            path = "${ajax.getImageBaseUrl}/${currentUser.filePath}";
          }

          debugPrint("FilePath: $path");

          setState(() {
            _user = currentUser;
            _imageFile = null;
            _imagePath = path;
          });
        }
      });
    });
  }

  void loadImageFromSystem() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    // Capture a photo.
    // final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    // Pick a video.
    // final XFile? galleryVideo = await picker.pickVideo(source: ImageSource.gallery);
    // Capture a video.
    // final XFile? cameraVideo = await picker.pickVideo(source: ImageSource.camera);
    // Pick multiple images.
    // final List<XFile> images = await picker.pickMultiImage();
    if (image != null) {
      // image.readAsBytes().then((value) {
      //   List<int> imageBytes = value;
      //   var base64ImageData = base64Encode(imageBytes);
      // });
      String path = image.path;
      debugPrint(path);
      setState(() {
        _imageFile = File(image.path);
        _imagePath = path;
      });
    } else {
      debugPrint("Image not selected.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: _user == null
          ? const Center(child: RefreshProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 80,
                            child: ClipOval(
                              child: _imageFile == null
                                  ? Configuration.getImage(
                                      _imagePath,
                                    )
                                  : Image.file(
                                      _imageFile!,
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.fill,
                                    ),
                            ),
                          ),
                          Positioned(
                            right: 10,
                            bottom: 0,
                            child: InkWell(
                              onTap: () {
                                loadImageFromSystem();
                              },
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                          bottom: 10,
                          top: 10,
                        ),
                        child: Text(
                          "${_user!.firstName} ${_user!.lastName}",
                          style: const TextStyle(
                            color: Colors.black45,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          initialValue: _user!.mobile,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Configuration.colorFromHex("#e8ebe9"),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                            border: const OutlineInputBorder(),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            prefixIcon: const Icon(
                              Icons.phone_android_outlined,
                            ),
                            hintText: "Enter user mobile no#",
                          ),
                          textInputAction: TextInputAction.next,
                          onSaved: (value) {
                            _user!.mobile = value!;
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        child: TextFormField(
                          initialValue:
                              "${_user!.firstName} ${_user!.lastName}",
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person),
                            filled: true,
                            fillColor: Configuration.colorFromHex("#e8ebe9"),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                            border: const OutlineInputBorder(),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            hintText: "First name",
                          ),
                          onSaved: (value) {
                            if (value != null) {
                              var nameValues = value.split(" ");
                              if (value.isNotEmpty && nameValues.length > 1) {
                                _user!.firstName = nameValues.first;
                                _user!.lastName = nameValues.last;
                              }
                            }
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        child: TextFormField(
                          initialValue: _user!.email,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: Configuration.colorFromHex("#e8ebe9"),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                            border: const OutlineInputBorder(),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            hintText: "Email",
                          ),
                          onSaved: (value) {
                            _user!.email = value!;
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        child: TextFormField(
                          initialValue: _user!.country,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.map_outlined),
                            filled: true,
                            fillColor: Configuration.colorFromHex("#e8ebe9"),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                            border: const OutlineInputBorder(),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            hintText: "Country",
                          ),
                          onSaved: (value) {
                            _user!.country = value!;
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        child: TextFormField(
                          initialValue: _user!.city,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.location_city),
                            filled: true,
                            fillColor: Configuration.colorFromHex("#e8ebe9"),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                            border: const OutlineInputBorder(),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            hintText: "City",
                          ),
                          onSaved: (value) {
                            _user!.city = value!;
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        child: TextFormField(
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          minLines: 4,
                          initialValue: _user!.firstAddress,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.home_outlined),
                            filled: true,
                            fillColor: Configuration.colorFromHex("#e8ebe9"),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            border: const OutlineInputBorder(),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            hintText: "Address",
                          ),
                          onSaved: (value) {
                            _user!.firstAddress = value!;
                          },
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 40,
                        padding: const EdgeInsets.all(0.0),
                        margin: const EdgeInsets.only(
                          bottom: 20,
                        ),
                        child: ElevatedButton.icon(
                          icon: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    backgroundColor: Colors.transparent,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save),
                          onPressed: _onSubmitted,
                          label: isSaving
                              ? const Text("Updating ...")
                              : const Text("Update"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
