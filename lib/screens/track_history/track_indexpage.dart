import 'dart:convert';

import 'package:ev_tracker/modal/VistiHistory.dart';
import 'package:ev_tracker/modal/appData.dart';
import 'package:ev_tracker/modal/applicationUser.dart';
import 'package:ev_tracker/service/ajax.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TrackIndexPage extends StatefulWidget {
  TrackIndexPage();

  @override
  State<TrackIndexPage> createState() => _TrackIndexPageState();
}

class _TrackIndexPageState extends State<TrackIndexPage> {
  ApplicationUser user = ApplicationUser();
  bool _isReady = false;
  Ajax ajax = Ajax.getInstance();
  List<VisitHistory> _visitHistorylist = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      user = Provider.of<AppData>(context, listen: false).user;
      getHistoryData();
    });
  }

  void getHistoryData() {
    ajax.get("visithistory/get/1").then((value) {
      List<VisitHistory> result = [];
      if(value != null) {
        var dynamicResult = [... value];
        for(final item in dynamicResult) {
          result.add(VisitHistory.fromJson(item));
        }
        debugPrint(jsonEncode(dynamicResult));
      }

      setState(() {
        _isReady = true;
        _visitHistorylist = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return !_isReady
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
                  horizontal: 20,
                ),
                child: const Text(
                  "You visited on Map.",
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
                child: const Text(
                  "This page display your last 30 days history, that you made in your google search.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
                    itemCount: _visitHistorylist.length,
                    prototypeItem: ListTile(
                      title: Text(_visitHistorylist.first.placeName),
                    ),
                    itemBuilder: (ctx, index) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 60,
                                  child: Icon(Icons.local_gas_station),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _visitHistorylist[index].placeName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 160,
                                      child: Text(
                                        _visitHistorylist[index].fullAddress,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ]),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _visitHistorylist[index].time,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                DateFormat("dd, MM yyyy").format(_visitHistorylist[index].visitedOn),
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              )
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          );
  }
}
