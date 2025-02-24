import 'package:ovorideuser/core/utils/method.dart';
import 'package:ovorideuser/core/utils/url_container.dart';
import 'package:ovorideuser/data/model/global/response_model/response_model.dart';
import 'package:ovorideuser/data/services/api_service.dart';

class CouponRepo {
  ApiClient apiClient;
  CouponRepo({required this.apiClient});
  //
  Future<ResponseModel> geCouponList() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.couponList}";
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> applyCoupon({required String rideId, required String code}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.applyCoupon}/$rideId";
    Map<String, String> params = {'ride_id': rideId, 'coupon_code': code};
    ResponseModel responseModel = await apiClient.request(url, Method.postMethod, params, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> removeCoupon({required String rideId, required String code}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.removeCoupon}/$rideId";
    Map<String, String> params = {'ride_id': rideId, 'coupon_code': code};
    ResponseModel responseModel = await apiClient.request(url, Method.postMethod, params, passHeader: true);
    return responseModel;
  }
}
