import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:ovorideuser/core/helper/date_converter.dart';
import 'package:ovorideuser/core/helper/string_format_helper.dart';
import 'package:ovorideuser/core/route/route.dart';
import 'package:ovorideuser/core/utils/my_strings.dart';
import 'package:ovorideuser/data/controller/location/app_location_controller.dart';
import 'package:ovorideuser/data/model/dashboard/dashboard_response_model.dart';
import 'package:ovorideuser/data/model/global/app/app_payment_method.dart';
import 'package:ovorideuser/data/model/global/app/app_service_model.dart';
import 'package:ovorideuser/data/model/global/app/ride_model.dart';
import 'package:ovorideuser/data/model/global/response_model/response_model.dart';
import 'package:ovorideuser/data/model/ride/create_ride_request_model.dart';
import 'package:ovorideuser/data/model/global/user/global_user_model.dart';
import 'package:ovorideuser/data/model/ride/create_ride_response_model.dart';
import 'package:ovorideuser/data/model/ride/ride_fare_response_model.dart';
import 'package:ovorideuser/core/utils/util.dart';
import 'package:ovorideuser/data/model/general_setting/general_setting_response_model.dart';
import 'package:ovorideuser/data/model/location/selected_location_info.dart';
import 'package:ovorideuser/data/repo/home/home_repo.dart';
import 'package:ovorideuser/presentation/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:ovorideuser/presentation/components/snack_bar/show_custom_snackbar.dart';
import 'package:ovorideuser/presentation/screens/home/widgets/bottomsheet/ride_distance_warning_bottomSheet.dart';

class HomeController extends GetxController {
  HomeRepo homeRepo;
  AppLocationController appLocationController;
  HomeController({required this.homeRepo, required this.appLocationController});

  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  double mainAmount = 0;
  String email = "";
  bool isLoading = true;
  String username = "";

  String serviceImagePath = "";
  String gatewayImagePath = "";
  String userImagePath = "";

  String defaultCurrency = "";
  String defaultCurrencySymbol = "";
  String currentAddress = "${MyStrings.loading.tr}...";
  int passenger = 1;
  Position? currentPosition;
  GlobalUser user = GlobalUser(id: '-1');
  List<AppService> appServices = [];
  List<AppPaymentMethod> paymentMethodList = [];
  RideModel runningRide = RideModel(id: "-1");
  bool isKycVerified = true;
  bool isKycPending = false;

  updatePassenger(bool isIncrement) {
    if (isIncrement) {
      passenger++;
    } else {
      passenger > 1 ? passenger-- : passenger = 1;
    }
    update();
  }

  GeneralSettingResponseModel generalSettingResponseModel = GeneralSettingResponseModel();
  Future<void> initialData({bool shouldLoad = true}) async {
    isLoading = shouldLoad;
    defaultCurrency = homeRepo.apiClient.getCurrencyOrUsername(isCurrency: true);
    defaultCurrencySymbol = homeRepo.apiClient.getCurrencyOrUsername(isSymbol: true);
    username = homeRepo.apiClient.getCurrencyOrUsername(isCurrency: false, isSymbol: false);
    email = homeRepo.apiClient.getUserEmail();
    generalSettingResponseModel = homeRepo.apiClient.getGSData();
    minimumDistance = double.tryParse(homeRepo.apiClient.minimumRideDistance()) ?? 0.0;
    bool t = await appLocationController.checkPermission();
    if (t == true) {
      currentPosition = await appLocationController.getCurrentPosition();
      currentAddress = appLocationController.currentAddress;
      SelectedLocationInfo l = SelectedLocationInfo(address: currentAddress, fullAddress: currentAddress, latitude: appLocationController.currentPosition.latitude, longitude: appLocationController.currentPosition.longitude);
      addLocationAtIndex(l, 0);
    }
    loggerX("selectedLocations.length ${selectedLocations.length}");
    await loadData(shouldLoad: shouldLoad);
    isLoading = false;
    update();
  }

  Future<void> loadData({bool shouldLoad = true}) async {
    isLoading = shouldLoad;
    update();
    try {
      ResponseModel responseModel = await homeRepo.getData();
      if (responseModel.statusCode == 200) {
        printx(responseModel.responseJson);
        DashBoardResponseModel model = DashBoardResponseModel.fromJson(jsonDecode(responseModel.responseJson));
        if (model.status == MyStrings.success) {
          appServices.clear();
          appServices = model.data?.services ?? [];
          paymentMethodList.clear();
          paymentMethodList = model.data?.paymentMethod ?? [];
          paymentMethodList.insertAll(0, MyUtils.getDefaultPaymentMethod());
          user = model.data?.userInfo ?? GlobalUser(id: '-1');
          loggerX(user.image);
          serviceImagePath = model.data?.serviceImagePath ?? '';
          gatewayImagePath = model.data?.gatewayImagePath ?? '';
          userImagePath = model.data?.userImagePath ?? '';
          update();
          printx(userImagePath);
        } else {
          CustomSnackBar.error(errorList: model.message ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  bool isSubmitLoading = false;
  Future<void> createRide() async {
    isSubmitLoading = true;
    update();

    try {
      ResponseModel responseModel = await homeRepo.createRide(
        data: CreateRideRequestModel(
          serviceId: selectedService.id!,
          pickUpLocation: selectedLocations[0].placeName ?? '${selectedLocations[0].fullAddress}',
          pickUpLatitude: selectedLocations[0].latitude.toString(),
          pickUpLongitude: selectedLocations[0].longitude.toString(),
          destination: selectedLocations[1].placeName ?? '${selectedLocations[1].fullAddress}',
          destinationLatitude: selectedLocations[1].latitude.toString(),
          destinationLongitude: selectedLocations[1].longitude.toString(),
          isIntercity: '1',
          pickUpDateTime: DateConverter.createRideDate(DateTime.now()),
          numberOfPassenger: passenger.toString(),
          note: noteController.text,
          offerAmount: mainAmount.toString(),
          paymentType: selectedPaymentMethod.id == "-9" ? "2" : '1',
          gatewayCurrencyId: selectedPaymentMethod.id!,
        ),
      );
      if (responseModel.statusCode == 200) {
        CreateRideResponseModel model = CreateRideResponseModel.fromJson(jsonDecode(responseModel.responseJson));
        if (model.status == MyStrings.success) {
          printx(model.remark);
          clearData();
          Get.toNamed(RouteHelper.rideDetailsScreen, arguments: model.data?.ride?.id);
        } else {
          loggerX(model.toJson());
          CustomSnackBar.error(errorList: model.message ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printx(e);
    } finally {
      isSubmitLoading = false;
      update();
    }
  }

  RideFareModel rideFare = RideFareModel(status: '-1');
  Future<void> getRideFare() async {
    try {
      ResponseModel responseModel = await homeRepo.getRideFare(
        data: CreateRideRequestModel(
          serviceId: selectedService.id!,
          pickUpLocation: selectedLocations[0].city.toString(),
          pickUpLatitude: selectedLocations[0].latitude.toString(),
          pickUpLongitude: selectedLocations[0].longitude.toString(),
          destination: selectedLocations[1].city.toString(),
          destinationLatitude: selectedLocations[1].latitude.toString(),
          destinationLongitude: selectedLocations[1].longitude.toString(),
          isIntercity: '1',
          pickUpDateTime: '',
          numberOfPassenger: '',
          note: '',
          offerAmount: '',
          paymentType: '',
          gatewayCurrencyId: '',
        ),
      );
      if (responseModel.statusCode == 200) {
        RideFareResponseModel model = RideFareResponseModel.fromJson(jsonDecode(responseModel.responseJson));
        if (model.status == MyStrings.success) {
          loggerX(model.data?.recommendAmount);
          rideFare = model.data ?? RideFareModel(status: '-1');
          loggerX(rideFare.recommendAmount);
          mainAmount = Converter.formatDouble(rideFare.recommendAmount.toString());
          amountController.text = Converter.formatDouble(rideFare.recommendAmount.toString()).toString();
          distance = double.tryParse(rideFare.distance.toString()) ?? 0.0;
          if (distance < minimumDistance) {
            distanceAlert();
          } else {
            isLocationShake = true;
          }
        } else {
          rideFare = RideFareModel(status: '-1');
          CustomSnackBar.error(errorList: model.message ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        rideFare = RideFareModel(status: '-1');
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printx(e);
    }
    update();
  }

  //Handle Ride Functionality Start From here
  TextEditingController pickUpLocation = TextEditingController();
  SelectedLocationInfo? pickUpLocationInfo;
  TextEditingController pickUpDestination = TextEditingController();
  SelectedLocationInfo? pickUpDestinationInfo;

  List<SelectedLocationInfo> selectedLocations = [];
  bool isServiceShake = false;
  bool isLocationShake = false;
  updateIsServiceShake(bool value) {
    isServiceShake = value;
    update();
  }

  Future<void> addLocationAtIndex(SelectedLocationInfo selectedLocationInfo, int index, {bool getFareData = false}) async {
    SelectedLocationInfo newLocation = selectedLocationInfo;
    if (selectedLocations.length > index && index >= 0) {
      selectedLocations[index] = newLocation;
    } else {
      selectedLocations.add(newLocation);
    }
    update();

    if (selectedLocations.length >= 2 && selectedService.id != "-99" && getFareData == true) {
      getRideFare();
    }
  }

  SelectedLocationInfo? getSelectedLocationInfoAtIndex(int index) {
    if (index >= 0 && index < selectedLocations.length) {
      return selectedLocations[index];
    } else {
      return null;
    }
  }

  double distance = -1;
  double minimumDistance = -1;

  //Handle Ride Functionality Start From here END
  updateMainAmount(double amount) {
    mainAmount = amount;
    amountController.text = amount.toString();
    printx(amount);
    printx(mainAmount);
    printx(amountController.text);
    update();
  }

  AppPaymentMethod selectedPaymentMethod = MyUtils.getDefaultPaymentMethod()[0];
  selectPaymentMethod(AppPaymentMethod method) {
    printx(method.id);
    selectedPaymentMethod = method;
    update();
    Get.back();
  }

  AppService selectedService = AppService(id: '-99');
  void selectService(AppService service) {
    if (selectedLocations.length > 1) {
      selectedService = service;
      update();
      getRideFare();
    } else {
      CustomSnackBar.error(errorList: [MyStrings.pleaseSelectPickupAndDestination]);
    }
  }

// ride alert methods
  void distanceAlert() {
    CustomBottomSheet(
      child: RideDistanceWarningBottomSheetBody(
        distance: minimumDistance.toString(),
        yes: () {
          Get.back();
        },
      ),
    ).customBottomSheet(Get.context!);
  }

  bool isValidForNewRide() {
    if (selectedLocations.isEmpty || selectedLocations.length < 2) {
      CustomSnackBar.error(errorList: [MyStrings.selectDestination]);
      return false;
    } else if (selectedService.id == "-99") {
      CustomSnackBar.error(errorList: [MyStrings.pleaseSelectAService]);
      return false;
    }
    return true;
  }

  clearData() {
    email = "";
    isLoading = true;
    username = "";
    serviceImagePath = "";
    defaultCurrency = "";
    currentAddress = "Loading...";
    defaultCurrencySymbol = "";
    currentPosition;
    mainAmount = 0;
    rideFare = RideFareModel(status: '-1');
    selectedService = AppService(id: '-99');

    amountController.text = '';
    noteController.text = '';
    selectedLocations = [];
    passenger = 1;
    isServiceShake = false;
    isLocationShake = false;
    update();
  }
}
