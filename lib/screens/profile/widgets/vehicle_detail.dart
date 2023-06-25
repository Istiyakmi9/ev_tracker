import 'dart:io';
import 'package:ev_tracker/modal/vehicle.dart';
import 'package:ev_tracker/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../modal/Configuration.dart';
import '../../../modal/appData.dart';
import '../../../service/ajax.dart';
import '../../../widgets/CustomAppBar.dart';

class VehicleDetail extends StatefulWidget {
  const VehicleDetail({Key? key}) : super(key: key);

  @override
  State<VehicleDetail> createState() => _VehicleDetailState();
}

class _VehicleDetailState extends State<VehicleDetail> {
  final _formKey = GlobalKey<FormState>();
  String _imagePath = "";
  File? _imageFile;
  Vehicle? _vehicle;
  bool isSaving = false;
  bool _isDefaultImage = false;
  Ajax ajax = Ajax.getInstance();

  void showPopup(String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('User vehicle status'),
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
      if (_vehicle != null && _vehicle!.userId > 0) {
        var vehicleDetail = {
          'vehicleId': _vehicle!.vehicleId,
          'vehicleNo': _vehicle!.vehicleNo,
          'brandName': _vehicle!.brandName,
          'make': _vehicle!.make,
          'model': _vehicle!.model,
          'varient': _vehicle!.varient,
          'vehicleType': _vehicle!.vehicleType,
          'series': _vehicle!.series,
          'userId': _vehicle!.userId,
          'filePath': _vehicle!.filePath
        };

        var status = await ajax.uploadVehicle(
            "vehicledetail/updateVehicle/${_vehicle!.vehicleId}",
            _imageFile,
            vehicleDetail);
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
      } else {
        showPopup("Please check your form and re-submit it.");
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

  Future<void> updateImage(Vehicle vehicle) async {
    File? imageFile;
    String path = "";
    path = "assets/images/car_placeholder.png";

    setState(() {
      _vehicle = vehicle;
      _isDefaultImage = true;
      _imageFile = imageFile;
      _imagePath = path;
    });
  }

  void getVehicleData(int userId) {
    ajax.get("vehicledetail/getVehicleByUserId/$userId").then((value) {
      File? imageFile;
      Vehicle? vehicle;
      var path = "assets/images/car_placeholder.png";
      bool isDefaultImage = false;
      if (value != null) {
        vehicle = Vehicle.fromJson(value);
        vehicle.userId = userId;
        if (vehicle.filePath != null && vehicle.filePath!.isEmpty) {
          isDefaultImage = false;
        }

        path = "${ajax.getImageBaseUrl}/${vehicle.filePath!}";
      } else {
        vehicle = Vehicle();
        vehicle.userId = userId;
        isDefaultImage = true;
      }

      setState(() {
        _vehicle = vehicle;
        _isDefaultImage = isDefaultImage;
        _imageFile = imageFile;
        _imagePath = path;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var user = Provider.of<AppData>(context, listen: false).user;
      getVehicleData(user.userId);
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
        _isDefaultImage = false;
        _imageFile = File(image.path);
        _imagePath = path;
      });
    } else {
      debugPrint("Image not selected.");
    }
  }

  Widget getImage() {
    if (_isDefaultImage) {
      return Image.asset(_imagePath);
    } else if (_imageFile == null) {
      return Configuration.getImage(
        _imagePath,
      );
    } else {
      return Image.file(
        _imageFile!,
        width: 150,
        height: 500,
        fit: BoxFit.fill,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: _vehicle == null
          ? const Center(child: RefreshProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            width: 300,
                            height: 300,
                            child: getImage(),
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
                          _vehicle!.brandName,
                          style: const TextStyle(
                            color: Colors.black45,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const ListTile(
                              title: Text('Vehicle Detail'),
                              subtitle: Text(
                                  'Fill your vehicle information like: Brand, Make, Model etc.'),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 15,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      width: 0.5,
                                      color: Colors.lightBlue.shade900),
                                ),
                                color: Colors.white,
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                initialValue: _vehicle!.brandName,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      Configuration.colorFromHex("#ffffff"),
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
                                    Icons.car_repair_outlined,
                                  ),
                                  hintText: "Your vehicle brand name",
                                ),
                                textInputAction: TextInputAction.next,
                                onSaved: (value) {
                                  _vehicle!.brandName =
                                      value ??= Constants.Empty;
                                },
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 15,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      width: 0.5,
                                      color: Colors.lightBlue.shade900),
                                ),
                                color: Colors.white,
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                initialValue: _vehicle!.vehicleNo,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      Configuration.colorFromHex("#ffffff"),
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
                                    Icons.plagiarism_outlined,
                                  ),
                                  hintText: "Enter your vehicle no#",
                                ),
                                textInputAction: TextInputAction.next,
                                onSaved: (value) {
                                  _vehicle!.vehicleNo =
                                      value ??= Constants.Empty;
                                },
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 15,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      width: 0.5,
                                      color: Colors.lightBlue.shade900),
                                ),
                                color: Colors.white,
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                initialValue: _vehicle!.vehicleType,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      Configuration.colorFromHex("#ffffff"),
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
                                    Icons.offline_bolt_sharp,
                                  ),
                                  hintText: "Vehicle Type",
                                ),
                                textInputAction: TextInputAction.next,
                                onSaved: (value) {
                                  _vehicle!.vehicleType =
                                      value ??= Constants.Empty;
                                },
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 15,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      width: 0.5,
                                      color: Colors.lightBlue.shade900),
                                ),
                                color: Colors.white,
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                initialValue: _vehicle!.series,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      Configuration.colorFromHex("#ffffff"),
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
                                    Icons.panorama_photosphere_select,
                                  ),
                                  hintText: "Enter vehicle serial no.#",
                                ),
                                textInputAction: TextInputAction.next,
                                onSaved: (value) {
                                  _vehicle!.series = value ??= Constants.Empty;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const ListTile(
                              title: Text('Model Detail'),
                              subtitle: Text(
                                  'Enter your make, model and varient detail.'),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 15,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      width: 0.5,
                                      color: Colors.lightBlue.shade900),
                                ),
                                color: Colors.white,
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                initialValue: _vehicle!.make,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      Configuration.colorFromHex("#ffffff"),
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
                                    Icons.zoom_in_map_outlined,
                                  ),
                                  hintText: "Enter vehicle make value",
                                ),
                                textInputAction: TextInputAction.next,
                                onSaved: (value) {
                                  _vehicle!.make = value ??= Constants.Empty;
                                },
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 15,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      width: 0.5,
                                      color: Colors.lightBlue.shade900),
                                ),
                                color: Colors.white,
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                initialValue: _vehicle!.model,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      Configuration.colorFromHex("#ffffff"),
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
                                    Icons.model_training_sharp,
                                  ),
                                  hintText: "Enter vehicle model value",
                                ),
                                textInputAction: TextInputAction.next,
                                onSaved: (value) {
                                  _vehicle!.model = value ??= Constants.Empty;
                                },
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 15,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      width: 0.5,
                                      color: Colors.lightBlue.shade900),
                                ),
                                color: Colors.white,
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                initialValue: _vehicle!.varient,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      Configuration.colorFromHex("#ffffff"),
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
                                    Icons.view_agenda_outlined,
                                  ),
                                  hintText: "Enter vehicle varient value",
                                ),
                                textInputAction: TextInputAction.next,
                                onSaved: (value) {
                                  _vehicle!.varient = value ??= Constants.Empty;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: double.infinity,
                        height: 40,
                        padding: const EdgeInsets.all(0.0),
                        margin: const EdgeInsets.only(
                          bottom: 20,
                          left: 2,
                          right: 2,
                          top: 10,
                        ),
                        child: ElevatedButton.icon(
                          icon: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    backgroundColor: Colors.transparent,
                                    color: Colors.black87,
                                  ),
                                )
                              : const Icon(
                                  Icons.save,
                                  color: Colors.black45,
                                ),
                          onPressed: _onSubmitted,
                          label: isSaving
                              ? Text(
                                  "Updating ...",
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                                )
                              : Text(
                                  "Update",
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                                ),
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
