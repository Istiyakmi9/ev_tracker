import 'dart:convert';

import 'package:ev_tracker/modal/RatingHistory.dart';
import 'package:ev_tracker/modal/VistiHistory.dart';
import 'package:ev_tracker/modal/appData.dart';
import 'package:ev_tracker/modal/applicationUser.dart';
import 'package:ev_tracker/service/ajax.dart';
import 'package:ev_tracker/widgets/CustomAppBar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../modal/SettingPreferences.dart';

class RatingHistory extends StatefulWidget {
  const RatingHistory({super.key});

  @override
  State<RatingHistory> createState() => _RatingHistoryState();
}

class _RatingHistoryState extends State<RatingHistory> {
  ApplicationUser user = ApplicationUser();
  bool _isReady = false;
  Ajax ajax = Ajax.getInstance();
  List<RatingHistoryModel> _ratingHistoryModel = [];
  late SettingPreferences _settings;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      user = Provider.of<AppData>(context, listen: false).user;
      getHistoryData();
    });
  }

  Future<void> getHistoryData() async {
    _settings = await SettingPreferences.getSettingDetail();
    ajax.get("ratinghistory/getRatingDetail/${user.userId}").then((value) {
      List<RatingHistoryModel> result = [];
      if (value != null) {
        var dynamicResult = [...value];
        debugPrint(jsonEncode(dynamicResult));
        for (final item in dynamicResult) {
          result.add(RatingHistoryModel.fromJson(item));
        }
      }

      setState(() {
        _isReady = true;
        _ratingHistoryModel = result;
      });
    });
  }

  Widget getAddressLetterWidget(int index) {
    String letter = "N";
    if(_ratingHistoryModel[index].visitingAddress.isNotEmpty) {
      letter = _ratingHistoryModel[index].visitingAddress[0];
    }
    return Text(
      letter,
      style: const TextStyle(
        color: Colors.black,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: !_isReady
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    top: 20,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                  ),
                  child: const Text(
                    "Your map rating & comments history.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromARGB(255, 40, 17, 78),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 20,
                    bottom: 20,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Text(
                    "This page display your last ${_settings.durationForRatingInDays} days history, that you made in your google search.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 0,
                      right: 20,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _ratingHistoryModel.length,
                      prototypeItem: ListTile(
                        title: Text(
                          _ratingHistoryModel.first.visitingAddress,
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      itemBuilder: (ctx, index) {
                        return Container(
                          margin: const EdgeInsets.only(
                            left: 14,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.black12,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  width: 60,
                                  child: CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                    child: getAddressLetterWidget(index),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _ratingHistoryModel[index]
                                            .visitingAddress,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 160,
                                        child: Text(
                                          _ratingHistoryModel[index].comment,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat("EEEE").format(
                                          _ratingHistoryModel[index].feedbackOn),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      DateFormat("d MMM, yyyy").format(
                                          _ratingHistoryModel[index].feedbackOn),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
