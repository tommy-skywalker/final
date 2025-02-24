import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:ovorideuser/core/helper/string_format_helper.dart';
import 'package:ovorideuser/core/utils/my_strings.dart';
import 'package:ovorideuser/core/utils/util.dart';
import 'package:ovorideuser/presentation/components/snack_bar/show_custom_snackbar.dart';
import 'package:permission_handler/permission_handler.dart';

class AppLocationController extends GetxController {
  Position currentPosition = MyUtils.getDefaultPosition();
  String currentAddress = "Loading...";

  Future<bool> checkPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request().then((value) async {
        if (value.isGranted) {
          return true;
        } else {
          return false;
        }
      }).onError((error, stackTrace) {
        CustomSnackBar.error(errorList: [MyStrings.locationPermissionPermanentDenied]);
        Future.delayed(
          const Duration(seconds: 2),
          () {
            openAppSettings();
          },
        );
        return false;
      });
    } else if (status.isPermanentlyDenied) {
      CustomSnackBar.error(errorList: [MyStrings.locationPermissionPermanentDenied]);
      Future.delayed(
        const Duration(seconds: 2),
        () {
          openAppSettings();
        },
      );
      return false;
    }
    // CustomSnackBar.error(errorList: [MyStrings.locationPermissionPermanentDenied]);
    return true;
  }

  Future<Position?> getCurrentPosition() async {
    try {
      final GeolocatorPlatform geolocator = GeolocatorPlatform.instance;
      currentPosition = await geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        currentPosition.latitude,
        currentPosition.longitude,
      );
      currentAddress = "";
      currentAddress = "${placemarks[0].street} ${placemarks[0].subThoroughfare} ${placemarks[0].thoroughfare},${placemarks[0].subLocality},${placemarks[0].locality},${placemarks[0].country}";
      update();
      printx('appLocations possition $currentAddress');
      return currentPosition;
    } catch (e) {
      CustomSnackBar.error(errorList: [MyStrings.locationPermissionPermanentDenied]);
      Future.delayed(
        const Duration(seconds: 2),
        () {
          openAppSettings();
        },
      );
    }
    return null;
  }
}
