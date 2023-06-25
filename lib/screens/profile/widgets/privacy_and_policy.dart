import 'package:ev_tracker/modal/applicationUser.dart';
import 'package:ev_tracker/service/ajax.dart';
import 'package:ev_tracker/widgets/CustomAppBar.dart';
import 'package:flutter/material.dart';

class PrivacyAndPolicy extends StatelessWidget {
  PrivacyAndPolicy({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  Ajax ajax = Ajax.getInstance();
  ApplicationUser? _user;
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Container(
        margin: const EdgeInsets.only(
          top: 20,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Privacy & Policy",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                color: Colors.white,
                margin: const EdgeInsets.only(
                  bottom: 2,
                ),
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: InkWell(
                    onTap: () {},
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.0,
                      ),
                      child: Text(
                        "About this application, application information will display all the necessary data to handle or manage the app.",
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                margin: const EdgeInsets.only(
                  bottom: 2,
                ),
                child: ListTile(
                  leading: const Icon(Icons.numbers),
                  title: const Text(
                    "Map camera zoom value",
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  trailing: Switch(
                    // thumb color (round icon)
                    activeColor: Colors.amber,
                    activeTrackColor: Colors.cyan,
                    inactiveThumbColor: Colors.blueGrey.shade600,
                    inactiveTrackColor: Colors.grey.shade400,
                    splashRadius: 50.0,
                    // boolean variable value
                    value: true,
                    // changes the state of the switch
                    onChanged: (value) {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
