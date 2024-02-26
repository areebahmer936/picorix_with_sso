import 'dart:async';

import "package:flutter/material.dart";
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picorix/config/themedata.dart';
// import 'package:petapet/widgets/widgets.dart';

class PlacePickerGoogle extends StatefulWidget {
  const PlacePickerGoogle({super.key});

  @override
  State<PlacePickerGoogle> createState() => _PlacePickerGoogleState();
}

class _PlacePickerGoogleState extends State<PlacePickerGoogle> {
  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _kGooglePlex =
      CameraPosition(target: LatLng(24.9620806, 67.0743136), zoom: 14);

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print("error: $error");
    });
    return await Geolocator.getCurrentPosition();
  }

  final List<Marker> _markers = [];
  bool locSelected = false;
  bool isLocLoading = false;
  String myAddress = '';
  LatLng myLatLng = const LatLng(0, 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _kGooglePlex,
              myLocationButtonEnabled: true,
              markers: Set<Marker>.of(_markers),
              compassEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 6,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Container(
                      color: secondaryColor.withOpacity(0),
                      height: MediaQuery.of(context).size.height / 12,
                      child: MaterialButton(
                        color: Colors.white,
                        onPressed: () {
                          setState(() {
                            isLocLoading = true;
                          });
                          getUserCurrentLocation().then((value) async {
                            print("${value.latitude} ${value.longitude}");

                            setState(() {
                              myLatLng =
                                  LatLng(value.latitude, value.longitude);
                              isLocLoading = false;
                              locSelected = true;
                              _markers.add(Marker(
                                  markerId: const MarkerId('0'),
                                  position:
                                      LatLng(value.latitude, value.longitude),
                                  infoWindow:
                                      const InfoWindow(title: "My Location")));
                            });

                            CameraPosition cameraPosition = CameraPosition(
                                target: LatLng(value.latitude, value.longitude),
                                zoom: 14);
                            final GoogleMapController controller =
                                await _controller.future;
                            controller.animateCamera(
                                CameraUpdate.newCameraPosition(cameraPosition));
                          });
                        },
                        child: Row(
                          children: [
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.my_location,
                              color: secondaryColor,
                            ),
                            const SizedBox(width: 20),
                            Text(
                              "Current Location",
                              style: textTheme.bodyMedium!.copyWith(
                                  color: secondaryColor,
                                  fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: MaterialButton(
                        minWidth: MediaQuery.of(context).size.width,
                        onPressed: locSelected
                            ? () async {
                                List<Placemark> placemarks =
                                    await placemarkFromCoordinates(
                                        myLatLng.latitude, myLatLng.longitude);
                                setState(() {
                                  myAddress =
                                      "${placemarks.reversed.last.street}, ${placemarks.reversed.last.subLocality}, ${placemarks.reversed.last.subAdministrativeArea}";
                                });
                                Navigator.pop(context,
                                    {"address": myAddress, "latlng": myLatLng});
                              }
                            : () {},
                        color: locSelected ? primaryColor : Colors.grey,
                        splashColor: !locSelected
                            ? Colors.grey
                            : Colors.green.withOpacity(0.5),
                        child: Text(
                          "Select this Location",
                          style: textTheme.bodyMedium!
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            isLocLoading
                ? Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white.withOpacity(0.5),
                      child: const Center(
                          child:
                              CircularProgressIndicator(color: primaryColor)),
                    ),
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}
