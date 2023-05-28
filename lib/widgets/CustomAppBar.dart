import 'package:ev_tracker/modal/appData.dart';
import 'package:ev_tracker/modal/applicationUser.dart';
import 'package:ev_tracker/service/db/DbService.dart';
import 'package:ev_tracker/utilities/NavigationPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  // TODO: implement preferredSize
  final Size preferredSize = const Size.fromHeight(80);
}

class _CustomAppBarState extends State<CustomAppBar> {
  ApplicationUser? _user;

  @override
  void initState() {
    super.initState();
    ApplicationUser user = Provider.of<AppData>(context, listen: false).user;
    loadProfileDetail(user);
  }

  void loadProfileDetail(ApplicationUser user) async {
    // var result = await User.getUser();
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: widget.preferredSize,
      child: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.power_settings_new_outlined,
              color: Colors.black87,
            ),
            onPressed: () {
              DbService db = DbService();
              db.deleteUser();
              Navigator.of(context).pushNamedAndRemoveUntil(
                  NavigationPage.LoginPage, (route) => false);
            },
          )
        ],
        title: Container(
          margin: const EdgeInsets.only(
            top: 10,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _user == null
                      ? const Text("...")
                      : Text(
                          "Hello, ${_user?.firstName}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  const SizedBox(
                    height: 6,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.grey,
                        size: 12,
                      ),
                      _user == null
                          ? const Text("...")
                          : Text(
                              "${_user!.firstAddress}, ${_user!.city}",
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            )
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
