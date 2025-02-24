import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovorideuser/core/helper/string_format_helper.dart';
import 'package:ovorideuser/core/route/route.dart';
import 'package:ovorideuser/core/utils/dimensions.dart';
import 'package:ovorideuser/core/utils/my_color.dart';
import 'package:ovorideuser/core/utils/my_strings.dart';
import 'package:ovorideuser/core/utils/style.dart';
import 'package:ovorideuser/data/controller/auth/auth/registration_controller.dart';
import 'package:ovorideuser/presentation/components/buttons/rounded_button.dart';
import 'package:ovorideuser/presentation/components/text-form-field/custom_text_field.dart';
import 'package:ovorideuser/presentation/screens/auth/registration/widget/validation_widget.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  bool isNumberBlank = false;
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegistrationController>(
      builder: (controller) {
        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                animatedLabel: true,
                needOutlineBorder: true,
                labelText: MyStrings.firstName.tr,
                controller: controller.fNameController,
                focusNode: controller.firstNameFocusNode,
                textInputType: TextInputType.text,
                nextFocus: controller.lastNameFocusNode,
                validator: (value) {
                  if (value!.isEmpty) {
                    return MyStrings.kFirstNameNullError.tr;
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {
                  return;
                },
              ),
              const SizedBox(height: Dimensions.space20),
              CustomTextField(
                animatedLabel: true,
                needOutlineBorder: true,
                labelText: MyStrings.lastName.tr,
                controller: controller.lNameController,
                focusNode: controller.lastNameFocusNode,
                textInputType: TextInputType.text,
                nextFocus: controller.emailFocusNode,
                validator: (value) {
                  if (value!.isEmpty) {
                    return MyStrings.kLastNameNullError.tr;
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {
                  return;
                },
              ),
              const SizedBox(height: Dimensions.space20),
              CustomTextField(
                animatedLabel: true,
                needOutlineBorder: true,
                labelText: MyStrings.email.tr,
                controller: controller.emailController,
                focusNode: controller.emailFocusNode,
                nextFocus: controller.passwordFocusNode,
                textInputType: TextInputType.emailAddress,
                inputAction: TextInputAction.next,
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return MyStrings.enterYourEmail.tr;
                  } else if (!MyStrings.emailValidatorRegExp.hasMatch(value ?? '')) {
                    return MyStrings.invalidEmailMsg.tr;
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {
                  return;
                },
              ),
              const SizedBox(height: Dimensions.space20),
              Focus(
                  onFocusChange: (hasFocus) {
                    controller.changePasswordFocus(hasFocus);
                  },
                  child: CustomTextField(
                    animatedLabel: true,
                    needOutlineBorder: true,
                    isShowSuffixIcon: true,
                    isPassword: true,
                    labelText: MyStrings.password.tr,
                    controller: controller.passwordController,
                    focusNode: controller.passwordFocusNode,
                    nextFocus: controller.confirmPasswordFocusNode,
                    textInputType: TextInputType.text,
                    onChanged: (value) {
                      if (controller.checkPasswordStrength) {
                        controller.updateValidationList(value);
                      }
                    },
                    validator: (value) {
                      return controller.validatePassword(value ?? '');
                    },
                  )),
              Visibility(
                visible: controller.hasPasswordFocus && controller.checkPasswordStrength,
                child: ValidationWidget(list: controller.passwordValidationRules),
              ),
              const SizedBox(height: Dimensions.space20),
              CustomTextField(
                animatedLabel: true,
                needOutlineBorder: true,
                labelText: MyStrings.confirmPassword.tr,
                controller: controller.cPasswordController,
                focusNode: controller.confirmPasswordFocusNode,
                nextFocus: controller.referNameFocusNode,
                inputAction: TextInputAction.done,
                isShowSuffixIcon: true,
                isPassword: true,
                onChanged: (value) {},
                validator: (value) {
                  if (controller.passwordController.text.toLowerCase() != controller.cPasswordController.text.toLowerCase()) {
                    return MyStrings.kMatchPassError.tr;
                  } else {
                    return null;
                  }
                },
              ),
              const SizedBox(height: Dimensions.space25),
              Visibility(
                visible: controller.needAgree,
                child: Row(
                  children: [
                    SizedBox(
                      width: 25,
                      height: 25,
                      child: Checkbox(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.defaultRadius)),
                        activeColor: MyColor.primaryColor,
                        checkColor: MyColor.colorWhite,
                        value: controller.agreeTC,
                        side: WidgetStateBorderSide.resolveWith((states) => BorderSide(width: 1.0, color: controller.agreeTC ? MyColor.getTextFieldEnableBorder() : MyColor.getTextFieldDisableBorder())),
                        onChanged: (bool? value) {
                          controller.updateAgreeTC();
                        },
                      ),
                    ),
                    if (controller.generalSettingRepo.apiClient.isAgreePolicyEnable()) ...[
                      const SizedBox(width: Dimensions.space8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            controller.updateAgreeTC();
                          },
                          child: RichText(
                            text: TextSpan(
                              text: MyStrings.regTerm.tr,
                              style: lightDefault.copyWith(color: MyColor.colorGrey, fontSize: 14),
                              children: [
                                TextSpan(
                                  text: " ${MyStrings.privacyPolicy.tr}",
                                  style: boldDefault.copyWith(color: MyColor.colorGrey, fontWeight: FontWeight.w600, height: 1.7, fontSize: 14),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.toNamed(RouteHelper.privacyScreen);
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.space30),
              RoundedButton(
                isLoading: controller.submitLoading,
                text: MyStrings.signUp.tr,
                press: () {
                  if (formKey.currentState!.validate()) {
                    controller.signUpUser();
                  }
                },
              ),
              const SizedBox(height: Dimensions.space30),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(MyStrings.alreadyAccount.tr, overflow: TextOverflow.ellipsis, style: lightLarge.copyWith(color: MyColor.getBodyTextColor(), fontWeight: FontWeight.normal)),
                  const SizedBox(width: Dimensions.space5),
                  InkWell(
                    onTap: () {
                      Get.offAllNamed(RouteHelper.loginScreen);
                      loggerX('tap');
                    },
                    child: Text(MyStrings.signIn.tr, maxLines: 2, overflow: TextOverflow.ellipsis, style: boldLarge.copyWith(color: MyColor.getPrimaryColor())),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
