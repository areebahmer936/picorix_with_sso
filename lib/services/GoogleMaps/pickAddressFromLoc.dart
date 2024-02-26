import 'package:flutter/material.dart';
import "package:geocoding/geocoding.dart";
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picorix/config/themedata.dart';
import 'package:place_picker/place_picker.dart';

class GetAddress extends StatefulWidget {
  const GetAddress({super.key});

  @override
  State<GetAddress> createState() => _GetAddressState();
}

class _GetAddressState extends State<GetAddress> {
  String address = '';
  LatLng position = const LatLng(24.9620806, 67.0743136);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(address),
              MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                color: primaryColor,
                onPressed: () async {
                  List<Placemark> placemarks =
                      await placemarkFromCoordinates(24.9620806, 67.0743136);
                  setState(() {
                    address =
                        "${placemarks.reversed.last.street}, ${placemarks.reversed.last.subLocality}, ${placemarks.reversed.last.subAdministrativeArea}";
                  });
                },
                child: Text(
                  "get address",
                  style: textTheme.bodyMedium!.copyWith(color: Colors.white),
                ),
              )
            ]),
      ),
    );
  }
}
