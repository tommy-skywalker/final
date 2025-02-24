import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ovorideuser/core/helper/string_format_helper.dart';
import 'package:ovorideuser/core/utils/my_strings.dart';
import 'package:ovorideuser/core/utils/util.dart';
import 'package:ovorideuser/data/model/authorization/authorization_response_model.dart';
import 'package:ovorideuser/data/model/bid/bid_list_response_model.dart';
import 'package:ovorideuser/data/model/global/bid/bid_model.dart';
import 'package:ovorideuser/data/model/global/response_model/response_model.dart';
import 'package:ovorideuser/data/model/global/app/ride_model.dart';
import 'package:ovorideuser/data/model/ride/all_ride_response_model.dart';
import 'package:ovorideuser/data/repo/ride/ride_repo.dart';
import 'package:ovorideuser/presentation/components/snack_bar/show_custom_snackbar.dart';

class RideHistoryController extends GetxController {
  RideRepo repo;
  RideHistoryController({required this.repo});

  bool isLoading = true;
  TextEditingController cancelReasonController = TextEditingController();
  String imagePath = "";
  String defaultCurrency = "";
  String defaultCurrencySymbol = "";
  String username = "";
  bool isInterCity = false;
  String? nextPageUrl;
  int page = 0;
  Future<void> initialData({required bool isIntraCity, required String status}) async {
    defaultCurrency = repo.apiClient.getCurrencyOrUsername();
    defaultCurrencySymbol = repo.apiClient.getCurrencyOrUsername(isSymbol: true);
    username = repo.apiClient.getCurrencyOrUsername(isCurrency: false);
    rideList = [];
    isInterCity = isIntraCity;
    page = 0;
    update();
  }

  List<RideModel> rideList = [];

  Future<void> getRideList(String status) async {
    isLoading = true;
    page++;
    update();

    try {
      ResponseModel responseModel = await repo.getRideList(rideType: isInterCity ? '1' : '2', status: status, page: page.toString());
      if (responseModel.statusCode == 200) {
        AllResponseModel model = AllResponseModel.fromJson(jsonDecode(responseModel.responseJson));
        if (model.status == "success") {
          rideList = model.data?.rides?.data ?? [];
          update();
        } else {
          CustomSnackBar.error(errorList: model.message ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printx(e);
    }

    isLoading = false;
    update();
  }

//
  List<BidModel> bids = [];
  RideModel ride = RideModel(id: "-1");
  Future<void> getRideBidList(String id) async {
    isLoading = true;
    update();
    try {
      ResponseModel responseModel = await repo.getRideBidList(id: id);
      if (responseModel.statusCode == 200) {
        BidListResponseModel model = BidListResponseModel.fromJson(jsonDecode(responseModel.responseJson));
        if (model.status == "success") {
          bids = model.data?.bids ?? [];
          ride = model.data?.ride ?? RideModel(id: "-1");
          // CustomSnackBar.success(successList: model.message?? ["Success"]);
          update();
        } else {
          CustomSnackBar.error(errorList: model.message ?? ["Error"]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printx(e);
    }
    isLoading = false;
    update();
  }

  //
  TextEditingController sosMsgController = TextEditingController();
  bool isSosLoading = false;
  String sosId = "-1";
  Future<void> sos(String id) async {
    isSosLoading = true;
    sosId = id;
    update();
    Position position = await MyUtils.getCurrentPosition();
    try {
      ResponseModel responseModel = await repo.sos(id: sosId, msg: sosMsgController.text, latLng: LatLng(position.latitude, position.longitude));
      if (responseModel.statusCode == 200) {
        AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(jsonDecode(responseModel.responseJson));
        if (model.status == "success") {
          sosMsgController.text = '';
          update();
          CustomSnackBar.success(successList: model.message ?? ["Success"]);
        } else {
          CustomSnackBar.error(errorList: model.message ?? ["Error"]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printx(e);
    }

    isSosLoading = false;
    sosId = "-1";
    update();
  }

  bool hasNext() {
    return nextPageUrl != null && nextPageUrl!.isNotEmpty && nextPageUrl != 'null' ? true : false;
  }

//
  clearData() {}
}
