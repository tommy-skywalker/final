import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovorideuser/core/helper/string_format_helper.dart';
import 'package:ovorideuser/core/route/route_middleware.dart';
import 'package:ovorideuser/environment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ovorideuser/core/helper/shared_preference_helper.dart';
import 'package:ovorideuser/core/route/route.dart';
import 'package:ovorideuser/core/utils/my_strings.dart';
import 'package:ovorideuser/data/model/auth/sign_up_model/registration_response_model.dart';
import 'package:ovorideuser/data/model/auth/sign_up_model/sign_up_model.dart';
import 'package:ovorideuser/data/model/country_model/country_model.dart';
import 'package:ovorideuser/data/model/general_setting/general_setting_response_model.dart';
import 'package:ovorideuser/data/model/global/response_model/response_model.dart';
import 'package:ovorideuser/data/model/model/error_model.dart';
import 'package:ovorideuser/data/repo/auth/general_setting_repo.dart';
import 'package:ovorideuser/data/repo/auth/signup_repo.dart';
import 'package:ovorideuser/presentation/components/snack_bar/show_custom_snackbar.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegistrationController extends GetxController {
  RegistrationRepo registrationRepo;
  GeneralSettingRepo generalSettingRepo;

  RegistrationController({required this.registrationRepo, required this.generalSettingRepo});

  bool isLoading = true;
  bool agreeTC = false;
  bool isReferralEnable = false;

  GeneralSettingResponseModel generalSettingMainModel = GeneralSettingResponseModel();

  final GoogleSignIn googleSignIn = GoogleSignIn();
  bool checkPasswordStrength = false;
  bool needAgree = true;

  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  final FocusNode firstNameFocusNode = FocusNode();
  final FocusNode lastNameFocusNode = FocusNode();
  final FocusNode countryNameFocusNode = FocusNode();
  final FocusNode mobileFocusNode = FocusNode();
  final FocusNode userNameFocusNode = FocusNode();
  final FocusNode companyNameFocusNode = FocusNode();
  final FocusNode referNameFocusNode = FocusNode();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cPasswordController = TextEditingController();
  final TextEditingController fNameController = TextEditingController();
  final TextEditingController lNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController referNameController = TextEditingController();

  String? email;
  String? password;
  String? confirmPassword;
  String? countryName;
  String? countryCode;
  String? mobileCode;
  String? userName;
  String? phoneNo;
  String? firstName;
  String? lastName;

  RegExp regex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
  bool submitLoading = false;

  signUpUser() async {
    if (needAgree && !agreeTC) {
      CustomSnackBar.error(
        errorList: [MyStrings.agreePolicyMessage],
      );
      return;
    }

    submitLoading = true;
    update();

    SignUpModel model = getUserData();
    final responseModel = await registrationRepo.registerUser(model);

    if (responseModel.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
      CustomSnackBar.success(successList: responseModel.message ?? [MyStrings.success.tr]);
      RouteMiddleware.checkNGotoNext(
        accessToken: responseModel.data?.accessToken ?? '',
        tokenType: responseModel.data?.tokenType ?? '',
        user: responseModel.data?.user,
      );
      // checkAndGotoNextStep(responseModel);
    } else {
      CustomSnackBar.error(errorList: responseModel.message ?? [MyStrings.somethingWentWrong.tr]);
    }

    submitLoading = false;
    update();
  }

  setCountryNameAndCode(String cName, String countryCode, String mobileCode) {
    countryName = cName;
    this.countryCode = countryCode;
    this.mobileCode = mobileCode;
    update();
  }

  updateAgreeTC() {
    agreeTC = !agreeTC;
    update();
  }

  SignUpModel getUserData() {
    SignUpModel model = SignUpModel(
      referName: referNameController.text.toString(),
      mobile: mobileController.text.toString(),
      email: emailController.text.toString(),
      agree: generalSettingRepo.apiClient.isAgreePolicyEnable()
          ? agreeTC
              ? true
              : false
          : false,
      username: '',
      fName: fNameController.text,
      lName: lNameController.text,
      password: passwordController.text.toString(),
      country: '',
      mobileCode: "",
      countryCode: '',
    );

    return model;
  }

  void checkAndGotoNextStep(RegistrationResponseModel responseModel) async {
    bool needEmailVerification = responseModel.data?.user?.ev == "1" ? false : true;
    bool needSmsVerification = responseModel.data?.user?.sv == "1" ? false : true;

    SharedPreferences preferences = registrationRepo.apiClient.sharedPreferences;

    await preferences.setString(SharedPreferenceHelper.userIdKey, responseModel.data?.user?.id.toString() ?? '-1');
    await preferences.setString(SharedPreferenceHelper.accessTokenKey, responseModel.data?.accessToken ?? '');
    await preferences.setString(SharedPreferenceHelper.accessTokenType, responseModel.data?.tokenType ?? '');
    await preferences.setString(SharedPreferenceHelper.userEmailKey, responseModel.data?.user?.email ?? '');
    await preferences.setString(SharedPreferenceHelper.userNameKey, responseModel.data?.user?.username ?? '');
    await preferences.setString(SharedPreferenceHelper.userPhoneNumberKey, responseModel.data?.user?.mobile ?? '');

    //attention: await registrationRepo.sendUserToken();

    bool isProfileCompleteEnable = responseModel.data?.user?.profileComplete.toString() == '0'
        ? true
        : responseModel.data?.user?.profileComplete.toString() == 'null'
            ? true
            : false;
    printx('responseModel.data?.user?.profileCompleted ${responseModel.data?.user?.loginBy}');
    printx('responseModel.data?.user?.profileCompleted ${responseModel.data?.user?.profileComplete}');
    bool isTwoFactorEnable = false;

    if (needEmailVerification == false && needSmsVerification == false) {
      if (isProfileCompleteEnable) {
        Get.offAndToNamed(RouteHelper.profileCompleteScreen);
      } else {
        Get.offAndToNamed(RouteHelper.dashboard);
      }
    } else if (needEmailVerification == true && needSmsVerification == true) {
      Get.offAndToNamed(RouteHelper.emailVerificationScreen, arguments: [true, isProfileCompleteEnable, isTwoFactorEnable]);
    } else if (needEmailVerification) {
      Get.offAndToNamed(RouteHelper.emailVerificationScreen, arguments: [false, isProfileCompleteEnable, isTwoFactorEnable]);
    } else if (needSmsVerification) {
      Get.offAndToNamed(RouteHelper.smsVerificationScreen, arguments: [isProfileCompleteEnable, isTwoFactorEnable]);
    }
  }

  void closeAllController() {
    isLoading = false;
    emailController.text = '';
    passwordController.text = '';
    cPasswordController.text = '';
    fNameController.text = '';
    lNameController.text = '';
    mobileController.text = '';
    countryController.text = '';
    userNameController.text = '';
    companyNameController.text = '';
  }

  clearAllData() {
    closeAllController();
  }

  List<ErrorModel> passwordValidationRules = [
    ErrorModel(text: MyStrings.hasUpperLetter.tr, hasError: true),
    ErrorModel(text: MyStrings.hasLowerLetter.tr, hasError: true),
    ErrorModel(text: MyStrings.hasDigit.tr, hasError: true),
    ErrorModel(text: MyStrings.hasSpecialChar.tr, hasError: true),
    ErrorModel(text: MyStrings.minSixChar.tr, hasError: true),
  ];

  bool isCountryLoading = true;
  void initData() async {
    isLoading = true;
    update();
    //   await getCountryData();

    ResponseModel response = await generalSettingRepo.getGeneralSetting();
    if (response.statusCode == 200) {
      GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(response.responseJson));
      if (model.status?.toLowerCase() == 'success') {
        generalSettingMainModel = model;
        isReferralEnable = generalSettingMainModel.data?.generalSetting?.riderReferral == '1' ? true : false;
        registrationRepo.apiClient.storeGeneralSetting(model);
      } else {
        List<String> message = [MyStrings.somethingWentWrong.tr];
        CustomSnackBar.error(errorList: model.message ?? message);
        return;
      }
    } else {
      if (response.statusCode == 503) {
        noInternet = true;
        update();
      }
      CustomSnackBar.error(errorList: [response.message]);
      return;
    }

    needAgree = generalSettingMainModel.data?.generalSetting?.agree.toString() == '0' ? false : true;
    checkPasswordStrength = generalSettingMainModel.data?.generalSetting?.securePassword.toString() == '0' ? false : true;

    isLoading = false;
    update();
  }

  bool countryLoading = true;
  List<Countries> countryList = [];
  List<Countries> filteredCountries = [];

  TextEditingController searchController = TextEditingController();
  Countries selectedCountryData = Countries(countryCode: '-1');

  selectCountryData(Countries value) {
    selectedCountryData = value;
    printx('value.country ${value.country}');
    printx('value.dialCode ${value.countryCode}');
    printx('value.dialCode ${value.dialCode}');
    update();
  }

  Future<dynamic> getCountryData() async {
    ResponseModel mainResponse = await registrationRepo.getCountryList();

    if (mainResponse.statusCode == 200) {
      CountryModel model = CountryModel.fromJson(jsonDecode(mainResponse.responseJson));
      List<Countries>? tempList = model.data?.countries;

      if (tempList != null && tempList.isNotEmpty) {
        countryList.addAll(tempList);
        filteredCountries.addAll(tempList);
      }
      var selectDefCountry = tempList!.firstWhere(
        (country) => country.countryCode!.toLowerCase() == Environment.defaultCountryCode.toLowerCase(),
        orElse: () => Countries(),
      );
      if (selectDefCountry.dialCode != null) {
        selectCountryData(selectDefCountry);
        setCountryNameAndCode(selectDefCountry.country.toString(), selectDefCountry.countryCode.toString(), selectDefCountry.dialCode.toString());
      }
      countryLoading = false;
      update();
      return;
    } else {
      CustomSnackBar.error(errorList: [mainResponse.message]);

      countryLoading = false;
      update();
      return;
    }
  }

  String? validatePassword(String value) {
    if (value.isEmpty) {
      return MyStrings.enterYourPassword_.tr;
    } else {
      if (checkPasswordStrength) {
        if (!regex.hasMatch(value)) {
          return MyStrings.invalidPassMsg.tr;
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
  }

  bool noInternet = false;
  void changeInternet(bool hasInternet) {
    noInternet = false;
    initData();
    update();
  }

  void updateValidationList(String value) {
    passwordValidationRules[0].hasError = value.contains(RegExp(r'[A-Z]')) ? false : true;
    passwordValidationRules[1].hasError = value.contains(RegExp(r'[a-z]')) ? false : true;
    passwordValidationRules[2].hasError = value.contains(RegExp(r'[0-9]')) ? false : true;
    passwordValidationRules[3].hasError = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')) ? false : true;
    passwordValidationRules[4].hasError = value.length >= 6 ? false : true;

    update();
  }

  bool hasPasswordFocus = false;
  void changePasswordFocus(bool hasFocus) {
    hasPasswordFocus = hasFocus;
    update();
  }

  //SIGN IN With Google
  bool isSocialSubmitLoading = false;
  bool isGoogle = false;
  bool remember = false;

  Future<void> signInWithGoogle() async {
    try {
      isGoogle = true;
      update();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        isGoogle = false;
        update();
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      await socialLoginUser(provider: 'google', accessToken: googleAuth.accessToken ?? '');
    } catch (e) {
      printx(e.toString());

      CustomSnackBar.error(errorList: [e.toString()]);
    }
  }

  //Social Login API PART

  Future socialLoginUser({
    String accessToken = '',
    String? provider,
  }) async {
    isSocialSubmitLoading = true;

    update();

    try {
      ResponseModel responseModel = await registrationRepo.socialLoginUser(
        accessToken: accessToken,
        provider: provider,
      );
      if (responseModel.statusCode == 200) {
        RegistrationResponseModel regModel = RegistrationResponseModel.fromJson(jsonDecode(responseModel.responseJson));
        if (regModel.status.toString().toLowerCase() == MyStrings.success.toLowerCase()) {
          remember = true;
          update();
          checkAndGotoNextStep(regModel);
        } else {
          isSocialSubmitLoading = false;
          update();
          CustomSnackBar.error(errorList: regModel.message ?? [MyStrings.loginFailedTryAgain.tr]);
        }
      } else {
        isSocialSubmitLoading = false;
        update();
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printx(e.toString());
    }

    isGoogle = false;
    isSocialSubmitLoading = false;
    update();
  }

  bool checkUserAccessTokeSaved() {
    String token = registrationRepo.apiClient.sharedPreferences.getString(SharedPreferenceHelper.accessTokenKey) ?? '';

    return !((token == '' || token == 'null'));
  }
}
