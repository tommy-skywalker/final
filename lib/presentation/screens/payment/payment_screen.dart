import 'package:ovorideuser/core/helper/string_format_helper.dart';
import 'package:ovorideuser/core/route/route.dart';
import 'package:ovorideuser/core/utils/app_status.dart';
import 'package:ovorideuser/core/utils/dimensions.dart';
import 'package:ovorideuser/core/utils/my_color.dart';
import 'package:ovorideuser/core/utils/my_icons.dart';
import 'package:ovorideuser/core/utils/my_strings.dart';
import 'package:ovorideuser/core/utils/style.dart';
import 'package:ovorideuser/core/utils/util.dart';
import 'package:ovorideuser/data/controller/coupon/coupon_controller.dart';
import 'package:ovorideuser/data/controller/payment/ride_payment_controller.dart';
import 'package:ovorideuser/data/model/global/app/ride_model.dart';
import 'package:ovorideuser/data/repo/coupon/coupon_repo.dart';
import 'package:ovorideuser/data/repo/payment/payment_repo.dart';
import 'package:ovorideuser/data/services/api_service.dart';
import 'package:ovorideuser/presentation/components/app-bar/custom_appbar.dart';
import 'package:ovorideuser/presentation/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:ovorideuser/presentation/components/buttons/rounded_button.dart';
import 'package:ovorideuser/presentation/components/divider/custom_divider.dart';
import 'package:ovorideuser/presentation/components/image/my_network_image_widget.dart';
import 'package:ovorideuser/presentation/screens/coupon/widget/coupon_widget.dart';
import 'package:ovorideuser/presentation/screens/payment/widget/payment_bottom_sheet.dart';
import 'package:ovorideuser/presentation/screens/payment/widget/payment_ride_details_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  void initState() {
    RideModel ride = Get.arguments;
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(CouponRepo(apiClient: Get.find()));
    Get.put(CouponController(couponRepo: Get.find(), rideId: ride.id.toString()));
    Get.put(PaymentRepo(apiClient: Get.find()));
    final controller = Get.put(RidePaymentController(repo: Get.find(), couponController: Get.find()));
    super.initState();
    printx(ride.id);
    WidgetsBinding.instance.addPostFrameCallback((time) {
      controller.initialData(ride);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RidePaymentController>(builder: (controller) {
      return Scaffold(
        backgroundColor: MyColor.screenBgColor,
        appBar: CustomAppBar(title: MyStrings.payment),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: Dimensions.screenPaddingHV,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PaymentRideDetailsCard(
                currency: controller.defaultCurrencySymbol,
                ride: controller.ride,
                driverImageUrl: '${controller.driverImagePath}/${controller.ride.driver?.avatar}',
              ),
              const SizedBox(height: Dimensions.space15),
              Container(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space20),
                decoration: BoxDecoration(color: MyColor.colorWhite, boxShadow: MyUtils.getShadow2(blurRadius: 10), borderRadius: BorderRadius.circular(Dimensions.mediumRadius)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [SvgPicture.asset(MyIcons.discount, height: Dimensions.space30, width: Dimensions.space30), const SizedBox(width: Dimensions.space12 - 1), Text(MyStrings.addCouponCode.tr, style: mediumMediumLarge.copyWith())],
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(RouteHelper.couponScreen, arguments: controller.ride.id.toString());
                      },
                      child: Container(width: 32, height: 32, decoration: BoxDecoration(shape: BoxShape.circle, color: MyColor.primaryColor.withOpacity(0.05)), child: const Icon(Icons.add, color: MyColor.primaryColor)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.space12),
              GetBuilder<CouponController>(builder: (couponController) {
                return couponController.selectedCoupon.id != '-1'
                    ? Container(
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space20),
                        decoration: BoxDecoration(color: MyColor.colorWhite, boxShadow: MyUtils.getShadow2(blurRadius: 10), borderRadius: BorderRadius.circular(Dimensions.mediumRadius)),
                        child: Column(
                          children: [
                            MyCouponCard(
                              coupon: couponController.selectedCoupon,
                              currencySym: controller.defaultCurrencySymbol,
                              apply: () {},
                              isApplied: true,
                              remove: () {
                                couponController.removeCoupon(couponController.selectedCoupon);
                              },
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink();
              }),
              const SizedBox(height: Dimensions.space12),
              Container(
                width: context.width,
                padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space20),
                decoration: BoxDecoration(color: MyColor.colorWhite, boxShadow: MyUtils.getShadow2(blurRadius: 10), borderRadius: BorderRadius.circular(Dimensions.mediumRadius)),
                child: GetBuilder<CouponController>(
                  builder: (couponController) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(MyStrings.rideSummary.tr, style: mediumMediumLarge),
                        const SizedBox(height: Dimensions.space12),
                        summaryRow(
                          title: MyStrings.rideAmount,
                          amount: "${controller.defaultCurrencySymbol}${Converter.formatNumber(controller.ride.amount ?? '0')}",
                        ),
                        const CustomDivider(color: MyColor.rideSub, space: Dimensions.space10),
                        summaryRow(
                          title: MyStrings.discount,
                          amount: "${couponController.selectedCoupon.discountType == AppStatus.DISCOUNT_FIXED ? controller.defaultCurrencySymbol : ''}"
                              "${Converter.formatNumber(couponController.selectedCoupon.amount ?? '0', precision: couponController.selectedCoupon.discountType == AppStatus.DISCOUNT_PERCENT ? 0 : 2)}"
                              "${couponController.selectedCoupon.discountType == AppStatus.DISCOUNT_PERCENT ? '%' : ''}",
                        ),
                        const CustomDivider(color: MyColor.rideSub, space: Dimensions.space10),
                        summaryRow(
                          title: MyStrings.paymentMethod,
                          amount: controller.selectedMethod.method?.name ?? '',
                          widget: GestureDetector(
                            onTap: () {
                              CustomBottomSheet(child: const PaymentMethodListBottomSheet()).customBottomSheet(context);
                            },
                            child: controller.selectedMethod.id == "-9" ? Image.asset(controller.selectedMethod.method?.image ?? '', width: Dimensions.space50 + 8, height: Dimensions.fontExtraLarge + 15, color: MyColor.primaryColor) : MyImageWidget(imageUrl: '${controller.imagePath}/${controller.selectedMethod.method?.image}', width: 50, height: 50, radius: 25),
                          ),
                          isTitleBold: true,
                        ),
                        const CustomDivider(color: MyColor.rideSub, space: Dimensions.space10),
                        summaryRow(
                          title: MyStrings.payableAmount,
                          amount: "${controller.defaultCurrencySymbol}${Converter.calculateDiscount(controller.ride.amount ?? '0', couponController.selectedCoupon.amount ?? '0', isPercentageCalculation: couponController.selectedCoupon.discountType == AppStatus.DISCOUNT_PERCENT)}",
                          isTitleBold: true,
                        ),
                        const SizedBox(height: Dimensions.space25 - 1),
                        RoundedButton(
                          text: MyStrings.pay,
                          press: () {
                            controller.submitPayment();
                          },
                          isLoading: controller.isSubmitBtnLoading,
                          isOutlined: false,
                          textStyle: boldMediumLarge.copyWith(color: MyColor.colorWhite),
                        )
                      ],
                    ).animate().shimmer(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Row summaryRow({required String title, required String amount, bool? isTitleBold = false, Widget? widget}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title.tr,
            overflow: TextOverflow.ellipsis,
            style: isTitleBold! ? regularMediumLarge.copyWith(color: MyColor.colorBlack) : regularMediumLarge.copyWith(color: MyColor.rideSub),
          ),
        ),
        // spaceSide(width: Dimensions.space15),
        Flexible(
          child: widget ??
              Text(
                amount.tr,
                overflow: TextOverflow.ellipsis,
                style: boldMediumLarge.copyWith(color: MyColor.colorBlack),
              ),
        ),
      ],
    );
  }
}
