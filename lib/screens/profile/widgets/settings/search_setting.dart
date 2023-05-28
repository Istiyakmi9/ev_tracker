import 'package:ev_tracker/modal/settings.dart';
import 'package:flutter/material.dart';

class SearchSetting extends StatefulWidget {
  late Settings settings;
  SearchSetting({super.key, required settings});

  @override
  State<SearchSetting> createState() => _SearchSettingState();
}

class _SearchSettingState extends State<SearchSetting> {
  void showPopup(String msg, String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('User profile status'),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(msg),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "[$text]",
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Search text',
                  ),
                )
              ],
            ),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Search & History",
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
              onTap: () {
                // showPopup("Show app information");
              },
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
          child: const ListTile(
            leading: Icon(Icons.history),
            title: Text(
              "Keep history for no.# of days",
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
            trailing: SizedBox(
              width: 30,
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: "days"),
              ),
            ),
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.only(
            top: 4,
            bottom: 8,
          ),
          margin: const EdgeInsets.only(
            bottom: 2,
          ),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.storage_outlined),
                title: const Text(
                  "Tab to change default search keyword used by default for Search page.",
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                trailing: IconButton(
                  onPressed: () {
                    showPopup(
                        "Default search text used for current application is",
                        "Electric vehicle charging station near me");
                  },
                  icon: Icon(Icons.keyboard_double_arrow_right_sharp),
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    "Default: ",
                    style: TextStyle(
                      color: Colors.black45,
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: Text(
                      "electric charging station lkdsjalsda jflsdajfklsdajflsajflkjsdalkfskfsflj flsdjflksdj",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
