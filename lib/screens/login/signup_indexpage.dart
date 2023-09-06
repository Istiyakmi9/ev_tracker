import 'dart:ui';

import 'package:ev_tracker/modal/Configuration.dart';
import 'package:ev_tracker/modal/appData.dart';
import 'package:ev_tracker/modal/applicationUser.dart';
import 'package:ev_tracker/service/ajax.dart';
import 'package:ev_tracker/service/db/DbService.dart';
import 'package:ev_tracker/utilities/NavigationPage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UserSignup extends StatefulWidget {
  const UserSignup({Key? key}) : super(key: key);

  @override
  State<UserSignup> createState() => _UserSignupState();
}

class _UserSignupState extends State<UserSignup> {
  final _formKey = GlobalKey<FormState>();
  ApplicationUser _user = ApplicationUser();
  Ajax ajax = Ajax.getInstance();
  DbService db = DbService();
  bool isSigning = false;

  String? _validateUserInputs() {
    if (_user.fullName.isEmpty) {
      return "Invalid full name";
    }

    if (_user.mobile.isEmpty) {
      return "Invalid mobile number";
    }

    if (_user.email.isEmpty) {
      return "Invalid email id.";
    }

    if (_user.firstAddress.isEmpty) {
      return "Invalid location and city";
    }

    if (_user.password.isEmpty) {
      return "Invalid password";
    }

    if (_user.password != _user.confirmPassword) {
      return "Password is mismatching";
    }

    return null;
  }

  void _onSubmitted() async {
    setState(() {
      isSigning = true;
    });

    _formKey.currentState?.save();
    var status = _validateUserInputs();
    if (status == null) {
      var dateOfBirth = DateFormat('yyyy-MM-dd HH:mm:ss')
          .format(_user.dob ?? DateTime(1900, 1, 1));
      var spaceIndex = _user.fullName.indexOf(' ');
      if (spaceIndex != -1) {
        _user.firstName = _user.fullName.substring(0, spaceIndex);
        _user.lastName = _user.fullName.substring(spaceIndex+1);
      }
      try {
        var data = {
          "userId": 0,
          "firstName": _user.firstName,
          "lastName": _user.lastName,
          "dob": dateOfBirth,
          "mobile": _user.mobile,
          "email": _user.email,
          "firstAddress": _user.firstAddress,
          "secondAddress": _user.secondAddress,
          "state": _user.state,
          "city": _user.city,
          "country": _user.country,
          "password": _user.password,
        };

        ajax.post("/user/createUser", data).then((value) {
          if (value != null) {
            Fluttertoast.showToast(msg: "Registration done successfully");
            Navigator.pushNamedAndRemoveUntil(
              context,
              NavigationPage.LoginPage,
                  (route) => false,
            );
          } else {
            Fluttertoast.showToast(msg: "Ohh!!!. Please contact admin.");
            showPopup(
                "Ohh!!!. Fail to register your account. Please contact admin.");
            setState(() {
              isSigning = false;
            });
          }
        }).onError((error, stackTrace) {
          debugPrint(stackTrace.toString());
          setState(() {
            isSigning = true;
          });
        });
      } on Exception catch (_, ex) {
        Fluttertoast.showToast(msg: "Ohh!!!. Please contact admin.");
        setState(() {
          isSigning = false;
        });
      }


      // ajax.post("/authenticate", {
      //   "mobile": _user.mobile,
      //   "password": _user.password
      // }).then((value) async {
      //   _user = ApplicationUser.fromJson(value);
      //   Provider.of<AppData>(context, listen: false).updateUser(_user);
      //   if (db.addUser(_user)) {
      //     Navigator.pushNamedAndRemoveUntil(
      //       context,
      //       NavigationPage.HomePage,
      //       (route) => false,
      //     );
      //   } else {
      //     debugPrint("Fail to add record into database");
      //   }
      // }).catchError((error) {
      //   setState(() {
      //     isSigning = false;
      //   });
      // });
    } else {
      Fluttertoast.showToast(msg: status);
      setState(() {
        isSigning = false;
      });
    }

  }

  Future<ApplicationUser> getLocalStorageData() async {
    ApplicationUser? data = db.getUser();
    if (data != null && data.userId > 0) {
      _user = data;
    }

    return _user;
  }

  @override
  initState() {
    super.initState();

    getLocalStorageData().then((ApplicationUser user) => {
          // ignore: unnecessary_null_comparison
          if (user != null && user.userId > 0)
            {
              getUserByEmail(user.email).then((value) {
                if (value != null) {
                  var appUser = ApplicationUser.fromJson(value);
                  Provider.of<AppData>(context, listen: false)
                      .updateUser(appUser);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    NavigationPage.HomePage,
                    (route) => false,
                  );
                } else {
                  showPopup(
                      "Your account is not registered. Please register one.");
                }
              })
            }
        });
  }

  void showPopup(String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Login'),
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

  Future<dynamic> getUserByEmail(String email) async {
    return ajax.get("user/getUserByEmail/$email").then((dynamic value) {
      return value;
    });
  }

  void saveAndLoadDashboard(ApplicationUser user) {
    ApplicationUser currentUser;
    getUserByEmail(user.email).then((userData) {
      if (userData == null) {
        saveUser(user);
      } else {
        currentUser = ApplicationUser.fromJson(userData);
        if (db.addUser(currentUser)) {
          Provider.of<AppData>(context, listen: false).updateUser(currentUser);
          Navigator.pushNamedAndRemoveUntil(
            context,
            NavigationPage.HomePage,
            (route) => false,
          );
        } else {
          debugPrint("Fail to add record into database");
        }
      }
    });
  }

  void saveUser(ApplicationUser? user) {
    if (user != null && user.email.isNotEmpty && user.firstName.isNotEmpty) {
      // Fluttertoast.showToast(msg: "Please wait. Registering your account.");
      var dateOfBirth = DateFormat('yyyy-MM-dd HH:mm:ss')
          .format(user.dob ?? DateTime(1900, 1, 1));
      try {
        var data = {
          "userId": 0,
          "firstName": user.firstName,
          "lastName": user.lastName,
          "dob": dateOfBirth,
          "mobile": user.mobile,
          "email": user.email,
          "firstAddress": user.firstAddress,
          "secondAddress": user.secondAddress,
          "state": user.state,
          "city": user.city,
          "country": user.country
        };

        ajax.post("/user/createUser", data).then((value) {
          if (value != null) {
            var user = ApplicationUser.fromJson(value);
            Provider.of<AppData>(context, listen: false).updateUser(user);
            if (db.addUser(user)) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                NavigationPage.HomePage,
                (route) => false,
              );
            } else {
              debugPrint("Fail to create/insert update data.");
            }
          } else {
            // Fluttertoast.showToast(msg: "Ohh!!!. Please contact admin.");
            showPopup(
                "Ohh!!!. Fail to register your account. Please contact admin.");
            setState(() {
              isSigning = false;
            });
          }
        }).onError((error, stackTrace) {
          debugPrint(stackTrace.toString());
        });
      } on Exception catch (_, ex) {
        // Fluttertoast.showToast(msg: "Ohh!!!. Please contact admin.");
        setState(() {
          isSigning = false;
        });
      }
    } else {
      showPopup("Got some internal error.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Fluttertoast.showToast(msg: "Please click sing in page instead.");
        return Future.value(false);
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Image.asset(
                  "assets/images/bg.jpg",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.only(
                  top: 150,
                  left: 20,
                  right: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Electric Vehicle Station Locator",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 30, horizontal: 20),
                        child: const Text(
                          "Welcome to electric vehicle station location and traffic system tracker.",
                          style: TextStyle(
                            color: Colors.white54,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                            border: OutlineInputBorder(),
                            fillColor: Colors.white,
                            hintText: "Enter your full name",
                            hintStyle: TextStyle(color: Colors.white54),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 1.0,
                                )),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                              BorderSide(color: Colors.white, width: 1.0),
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                          onSaved: (value) {
                            _user.fullName = value!;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.phone_android_outlined,
                              color: Colors.white,
                            ),
                            border: OutlineInputBorder(),
                            fillColor: Colors.white,
                            hintText: "Enter user mobile no#",
                            hintStyle: TextStyle(color: Colors.white54),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              color: Colors.white,
                              width: 1.0,
                            )),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1.0),
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                          onSaved: (value) {
                            _user.mobile = value!;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: Colors.white,
                            ),
                            border: OutlineInputBorder(),
                            fillColor: Colors.white,
                            hintText: "Enter email id",
                            hintStyle: TextStyle(color: Colors.white54),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              color: Colors.white,
                              width: 1.0,
                            )),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1.0),
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                          onSaved: (value) {
                            _user.email = value!;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.location_city,
                              color: Colors.white,
                            ),
                            border: OutlineInputBorder(),
                            fillColor: Colors.white,
                            hintText: "Your location and city",
                            hintStyle: TextStyle(color: Colors.white54),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              color: Colors.white,
                              width: 1.0,
                            )),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1.0),
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                          onSaved: (value) {
                            _user.firstAddress = value!;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.key_rounded,
                              color: Colors.white,
                            ),
                            border: OutlineInputBorder(),
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1.0),
                            ),
                            hintText: "Enter password",
                            hintStyle: TextStyle(color: Colors.white54),
                          ),
                          obscureText: true,
                          obscuringCharacter: "*",
                          onSaved: (value) {
                            _user.password = value!;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.confirmation_num_outlined,
                              color: Colors.white,
                            ),
                            border: OutlineInputBorder(),
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1.0),
                            ),
                            hintText: "Confirm password",
                            hintStyle: TextStyle(color: Colors.white54),
                          ),
                          obscureText: true,
                          obscuringCharacter: "*",
                          onSaved: (value) {
                            _user.confirmPassword = value!;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Wrap(
                        children: [
                          const Text(
                            "Go back to:",
                            style: TextStyle(
                              color: Colors.white54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                NavigationPage.LoginPage,
                                (route) => false,
                              );
                            },
                            child: const Text(
                              "Sign in page",
                              style: TextStyle(
                                color: Colors.lightBlue,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                          top: 10,
                        ),
                        height: 60,
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: _onSubmitted,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          child: isSigning
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        backgroundColor: Colors.transparent,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Text(
                                      "Signing ...",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.app_registration,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Text(
                                      "Sign up now",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
