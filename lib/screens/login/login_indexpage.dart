import 'dart:ui';
import 'package:ev_tracker/modal/appData.dart';
import 'package:ev_tracker/modal/applicationUser.dart';
import 'package:ev_tracker/service/ajax.dart';
import 'package:ev_tracker/utilities/NavigationPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../service/db/DbService.dart';

class LoginIndexPage extends StatefulWidget {
  const LoginIndexPage();

  @override
  _LoginIndexPageState createState() => _LoginIndexPageState();
}

class _LoginIndexPageState extends State<LoginIndexPage> {
  final _formKey = GlobalKey<FormState>();
  ApplicationUser _user = ApplicationUser();
  Ajax ajax = Ajax.getInstance();
  DbService db = DbService();
  bool isSigning = false;

  void _onSubmitted() async {
    _formKey.currentState?.save();

    setState(() {
      isSigning = true;
    });

    ajax.post("/authenticate", {
      "mobile": _user.mobile,
      "password": _user.password
    }).then((value) async {
      if (value != null) {
        _user = ApplicationUser.fromJson(value);
        Provider.of<AppData>(context, listen: false).updateUser(_user);
        if (db.addUser(_user)) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            NavigationPage.HomePage,
                (route) => false,
          );
        } else {
          debugPrint("Fail to add record into database");
        }
      } else {
        Fluttertoast.showToast(msg: "Invalid username or password");
        setState(() {
          isSigning = false;
        });
      }
    }).catchError((error) {
      setState(() {
        isSigning = false;
      });
    });
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

  void _googleAuthenticate() async {
    try {
      setState(() {
        isSigning = true;
      });

      final FirebaseAuth auth = FirebaseAuth.instance;
      final GoogleSignIn googleSignIn = GoogleSignIn();

      GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount == null) {
        setState(() {
          isSigning = false;
        });

        return;
      }

      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      UserCredential authResult = await auth.signInWithCredential(credential);

      User? user = authResult.user;

      _user.email = user!.email!;
      List<String> userName = user!.displayName!.split(" ");
      if (userName.length >= 2) {
        _user.firstName = userName[0];
        _user.lastName = userName[1];
      } else {
        _user.firstName = userName[0];
      }

      if (user!.phoneNumber != null) {
        _user.mobile = user!.phoneNumber!;
      } else {
        _user.mobile = "N/A";
      }

      if (user!.photoURL != null) {
        _user.imageURL = user!.photoURL!;
      }

      _user.accessToken = authResult!.credential!.accessToken!;
      _user.firstAddress = "NA";
      _user.city = "NA";
      _user.state = "NA";

      saveAndLoadDashboard(_user);
    } on Exception catch (_, error) {
      setState(() {
        isSigning = false;
      });
      debugPrint(error.toString());
    }
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
      setState(() {
        isSigning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            padding: const EdgeInsets.only(
              top: 150,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                          vertical: 40, horizontal: 20),
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
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.key_outlined,
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
                    Container(
                      width: double.infinity,
                      height: 60,
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: _onSubmitted,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white60,
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
                                children: [
                                  Icon(
                                    Icons.subdirectory_arrow_right,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    "Sign in",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                    ),
                                  )
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        top: 20,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Please read terms and condition given link below",
                            style: TextStyle(
                              color: Colors.white54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Wrap(
                            children: [
                              const Text(
                                "For new registration:",
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
                                    NavigationPage.SignUpIndexPage,
                                        (route) => false,
                                  );
                                },
                                child: const Text(
                                  "Sign up now",
                                  style: TextStyle(
                                    color: Colors.lightBlue,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Wrap(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    NavigationPage.ResetPasswordPage,
                                        (route) => false,
                                  );
                                },
                                child: const Text(
                                  "Click to reset password",
                                  style: TextStyle(
                                    color: Colors.lightBlue,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "Few more information",
                            style: TextStyle(
                              color: Colors.white54,
                            ),
                          ),
                          const Text(
                            "Terms & Condition",
                            style: TextStyle(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(
                        top: 10,
                      ),
                      height: 60,
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          _googleAuthenticate();
                        },
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
                                  Image(
                                    image:
                                        AssetImage('assets/images/google.png'),
                                    color: Colors.white,
                                    width: 25,
                                    height: 25,
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    "Sign in with Google",
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
    );
  }
}
