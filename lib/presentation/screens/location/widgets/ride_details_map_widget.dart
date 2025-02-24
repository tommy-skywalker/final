import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovorideuser/core/helper/string_format_helper.dart';
import 'package:ovorideuser/core/route/route.dart';
import 'package:ovorideuser/core/utils/app_status.dart';
import 'package:ovorideuser/core/utils/dimensions.dart';
import 'package:ovorideuser/core/utils/my_color.dart';
import 'package:ovorideuser/core/utils/my_icons.dart';
import 'package:ovorideuser/core/utils/my_strings.dart';
import 'package:ovorideuser/core/utils/style.dart';
import 'package:ovorideuser/core/utils/util.dart';
import 'package:ovorideuser/data/controller/ride/ride_details/ride_details_controller.dart';
import 'package:ovorideuser/presentation/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:ovorideuser/presentation/components/buttons/icon_button.dart';
import 'package:ovorideuser/presentation/components/buttons/rounded_button.dart';
import 'package:ovorideuser/presentation/components/column_widget/card_column.dart';
import 'package:ovorideuser/presentation/packages/simple_ripple_animation.dart';
import 'package:ovorideuser/presentation/screens/location/widgets/driver_profile_widget.dart';
import 'package:ovorideuser/presentation/screens/location/widgets/driver_searching_widget.dart';
import 'package:ovorideuser/presentation/screens/location/widgets/ride_cancel_bottom_sheet_body.dart';
import 'package:ovorideuser/presentation/screens/location/widgets/ride_details_review_bottom_sheet.dart';
import 'package:ovorideuser/presentation/screens/location/widgets/ride_otp_widget.dart';
import 'package:ovorideuser/presentation/screens/location/widgets/ride_sos_bottom_sheet_body.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RideDetailsMapWidget extends StatelessWidget {
  final ScrollController scrollController;
  final BoxConstraints constraints;
  final DraggableScrollableController draggableScrollableController;
  const RideDetailsMapWidget({super.key, required this.scrollController, required this.constraints, required this.draggableScrollableController});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideDetailsController>(
      builder: (controller) {
        final ride = controller.ride;
        final currency = controller.currency;

        return Container(
          decoration: const BoxDecoration(color: MyColor.colorWhite, borderRadius: BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18))),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                clipBehavior: Clip.hardEdge,
                width: context.width,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: Dimensions.space10),
                margin: EdgeInsets.only(top: ride.driver == null ? 60 : 0),
                decoration: const BoxDecoration(),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (ride.driver != null) ...[
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            height: 5,
                            width: 50,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: MyColor.colorGrey.withOpacity(0.2)),
                          ),
                        ),
                        const SizedBox(height: Dimensions.space20),
                      ],
                      if (ride.driver != null) ...[
                        DriverProfileWidget(ride: ride, driverImage: '${controller.driverImagePath}/${ride.driver?.avatar ?? ''}', serviceImage: '${controller.serviceImagePath}/${ride.service?.image ?? ''}'),
                        const SizedBox(height: Dimensions.space20),
                      ],
                      if (ride.status == "2") ...[
                        RideOtpWidget(ride: ride),
                        const SizedBox(height: Dimensions.space20),
                      ],
                      //messages
                      Row(
                        children: [
                          Expanded(
                            child: CustomIconButton(
                              name: MyStrings.message,
                              icon: MyIcons.messageIcon,
                              isSvg: true,
                              bgColor: (ride.status != AppStatus.RIDE_RUNNING && ride.status != AppStatus.RIDE_ACTIVE && ride.status != AppStatus.RIDE_PAYMENT_REQUESTED) ? MyColor.colorGrey : MyColor.primaryColor,
                              press: () {
                                if (ride.status == AppStatus.RIDE_RUNNING || ride.status == AppStatus.RIDE_ACTIVE || ride.status == AppStatus.RIDE_PAYMENT_REQUESTED) {
                                  Get.toNamed(RouteHelper.rideMessageScreen, arguments: ride.id.toString());
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: Dimensions.space10),
                          Expanded(
                            child: CustomIconButton(
                              name: MyStrings.call,
                              icon: MyIcons.callIcon,
                              isSvg: true,
                              textColor: MyColor.getTextColor(),
                              iconColor: MyColor.colorBlack,
                              bgColor: (ride.status != AppStatus.RIDE_RUNNING && ride.status != AppStatus.RIDE_ACTIVE && ride.status != AppStatus.RIDE_PAYMENT_REQUESTED) ? MyColor.colorGrey : MyColor.primaryColor,
                              isOutline: true,
                              press: () {
                                if (ride.status == AppStatus.RIDE_RUNNING || ride.status == AppStatus.RIDE_ACTIVE || ride.status == AppStatus.RIDE_PAYMENT_REQUESTED) {
                                  MyUtils.launchPhone('${ride.driver?.mobile}');
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.space20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: Dimensions.space15),
                        decoration: BoxDecoration(color: MyColor.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(Dimensions.mediumRadius)),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(width: Dimensions.space20),
                              rideCardDetails(title: '${ride.distance}${MyStrings.km.tr}', description: MyStrings.distanceAway),
                              const SizedBox(width: Dimensions.space25),
                              rideCardDetails(title: '${ride.duration}', description: MyStrings.estimatedDuration),
                              const SizedBox(width: Dimensions.space25),
                              rideCardDetails(title: '${Converter.formatNumber(ride.amount.toString())} $currency', description: MyStrings.rideFare),
                              const SizedBox(width: Dimensions.space20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.space20),
                      if (ride.status == AppStatus.RIDE_RUNNING) ...[
                        const SizedBox(height: Dimensions.space20),
                        RoundedButton(
                          text: MyStrings.sos,
                          color: MyColor.redCancelTextColor,
                          isLoading: controller.isSosLoading,
                          press: () {
                            CustomBottomSheet(child: RideDetailsSosBottomSheetBody(controller: controller, id: ride.id ?? '-1')).customBottomSheet(context);
                          },
                        ),
                      ],
                      if (ride.status == AppStatus.RIDE_ACTIVE || ride.status == AppStatus.RIDE_PENDING) ...[
                        const SizedBox(height: Dimensions.space20),
                        RoundedButton(
                          text: MyStrings.cancelRide.tr,
                          press: () {
                            CustomBottomSheet(child: const RideCancelBottomSheetBody()).customBottomSheet(context);
                          },
                          color: MyColor.redCancelTextColor,
                        ),
                      ] else if (ride.paymentStatus == '1' && ride.driverReview == null) ...[
                        RoundedButton(
                          text: MyStrings.review,
                          isOutlined: false,
                          press: () {
                            CustomBottomSheet(child: RideDetailsReviewBottomSheet(ride: controller.ride)).customBottomSheet(context);
                          },
                          textColor: MyColor.colorWhite,
                        ),
                      ] else if (controller.ride.status == "4") ...[
                        if (ride.paymentStatus == '2' && controller.isPaymentRequested == false) ...[
                          SizedBox(height: Dimensions.space20),
                          RoundedButton(
                            text: MyStrings.paymentNow,
                            isOutlined: false,
                            press: () {
                              Get.toNamed(RouteHelper.paymentScreen, arguments: ride);
                            },
                            textColor: MyColor.colorWhite,
                          ).animate().shakeX(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut),
                        ] else ...[
                          Column(
                            children: [
                              const SizedBox(height: Dimensions.space10),
                              RippleAnimation(
                                repeat: true,
                                color: MyColor.primaryColor,
                                minRadius: 18,
                                child: Container(padding: const EdgeInsets.all(Dimensions.space15), decoration: BoxDecoration(color: MyColor.primaryColor.withOpacity(0.1), shape: BoxShape.circle)),
                              ),
                              const SizedBox(height: Dimensions.space20),
                              Center(
                                child: Text(
                                  MyStrings.waitForDriverResponse,
                                  style: boldDefault.copyWith(color: MyColor.primaryColor),
                                ).animate(
                                  onComplete: (controller) {
                                    controller.repeat();
                                    MyUtils.vibrate();
                                  },
                                ).shimmer(duration: const Duration(seconds: 2), curve: Curves.easeInOut),
                              ),
                              const SizedBox(height: Dimensions.space10),
                            ],
                          ),
                          SizedBox(height: Dimensions.space20),
                        ]
                      ] else if (controller.ride.status == "1") ...[
                        const SizedBox(height: Dimensions.space25),
                        Container(
                          width: context.width,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: MyColor.greenSuccessColor.withOpacity(0.1), borderRadius: BorderRadius.circular(Dimensions.mediumRadius)),
                          child: Center(child: Text(MyStrings.rideCompleted.tr, style: boldDefault.copyWith(color: MyColor.greenSuccessColor))),
                        )
                      ] else if (ride.status == AppStatus.RIDE_CANCELED) ...[
                        const SizedBox(height: Dimensions.space20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(Dimensions.space15),
                          decoration: BoxDecoration(color: MyUtils.getRideStatusColor(AppStatus.RIDE_CANCELED).withOpacity(0.1), borderRadius: BorderRadius.circular(Dimensions.mediumRadius), border: Border.all(color: MyUtils.getRideStatusColor(AppStatus.RIDE_CANCELED), width: 1)),
                          child: Center(
                            child: Text(MyStrings.rideCanceled.tr, style: boldDefault.copyWith(color: MyUtils.getRideStatusColor(AppStatus.RIDE_CANCELED))),
                          ),
                        ),
                      ],

                      const SizedBox(height: Dimensions.space20)
                    ],
                  ),
                ),
              ),
              if (ride.driver == null && ride.status == '0') ...[
                DriverSearchWidget(
                  bids: controller.totalBids.toString(),
                  onTap: () {
                    printx(ride.id.toString());
                    Get.toNamed(RouteHelper.rideBidScreen, arguments: ride.id.toString());
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  CardColumn rideCardDetails({required String title, required String description}) {
    return CardColumn(
      header: title.tr,
      body: description.tr,
      headerTextStyle: boldMediumLarge.copyWith(color: MyColor.primaryColor),
      bodyTextStyle: regularMediumLarge.copyWith(color: MyColor.bodyText),
      alignmentCenter: true,
    );
  }
}
