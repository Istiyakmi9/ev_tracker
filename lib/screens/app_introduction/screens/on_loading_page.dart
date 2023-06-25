import 'dart:ui';

import 'package:ev_tracker/utilities/constants.dart';
import 'package:flutter/material.dart';

class OnLoadingPage extends StatefulWidget {
  String? title;
  String? message1;
  String? message2;
  String? imgPath;

  OnLoadingPage(
      {super.key,
      required this.title,
      required this.imgPath,
      required this.message1,
      this.message2});

  @override
  State<OnLoadingPage> createState() => _OnLoadingPageState();
}

class _OnLoadingPageState extends State<OnLoadingPage> {
  String? title;
  String? message1;
  String? message2;
  String? imgPath;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    debugPrint("Data: ${widget.imgPath}");

    setState(() {
      title = widget.title;
      message1 = widget.message1;
      message2 = widget.message2;
      imgPath = widget.imgPath;
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("At page render time $imgPath");
    return imgPath == null
        ? const Center(
            child: Text("Please wait ..."),
          )
        : Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  imgPath!,
                  fit: BoxFit.fitWidth,
                ),
                const SizedBox(
                  height: 40,
                ),
                Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 25,
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        message1!,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        message2!,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
  }
}
