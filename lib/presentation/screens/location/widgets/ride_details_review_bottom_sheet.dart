import 'package:ovorideuser/core/helper/string_format_helper.dart';
import 'package:ovorideuser/core/utils/dimensions.dart';
import 'package:ovorideuser/core/utils/my_color.dart';
import 'package:ovorideuser/core/utils/my_icons.dart';
import 'package:ovorideuser/core/utils/my_images.dart';
import 'package:ovorideuser/core/utils/my_strings.dart';
import 'package:ovorideuser/core/utils/style.dart';
import 'package:ovorideuser/core/utils/util.dart';
import 'package:ovorideuser/data/controller/ride/ride_details/ride_details_controller.dart';
import 'package:ovorideuser/data/model/global/app/ride_model.dart';
import 'package:ovorideuser/presentation/components/bottom-sheet/bottom_sheet_header_row.dart';
import 'package:ovorideuser/presentation/components/buttons/rounded_button.dart';
import 'package:ovorideuser/presentation/components/divider/custom_divider.dart';
import 'package:ovorideuser/presentation/components/image/custom_svg_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:ovorideuser/presentation/components/image/my_network_image_widget.dart';
import 'package:ovorideuser/presentation/components/snack_bar/show_custom_snackbar.dart';
import 'package:ovorideuser/presentation/components/text-form-field/custom_text_field.dart';

class RideDetailsReviewBottomSheet extends StatelessWidget {
  RideModel ride;
  RideDetailsReviewBottomSheet({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideDetailsController>(builder: (controller) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BottomSheetHeaderRow(),
          Align(alignment: Alignment.center, child: Text(MyStrings.reviewForDriver.tr, style: regularDefault.copyWith(fontSize: Dimensions.fontOverLarge - 1))),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: Dimensions.space20),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: MyColor.colorWhite, border: Border.all(color: MyColor.borderColor), shape: BoxShape.circle),
                  child: MyImageWidget(
                    imageUrl: '${controller.driverImagePath}/${ride.driver?.avatar ?? ''}',
                    height: 85,
                    width: 85,
                    radius: 50,
                    isProfile: true,
                    errorWidget: Image.asset(
                      MyImages.defaultAvatar,
                      height: 85,
                      width: 85,
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.space8),
                Text("${ride.driver?.firstname} ${ride.driver?.lastname}", style: regularDefault.copyWith(fontSize: 16)),
                const SizedBox(height: Dimensions.space8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: MyColor.colorYellow),
                        Text(
                          Converter.formatNumber(ride.driver?.avgRating ?? '0.0'),
                          style: boldDefault.copyWith(color: MyColor.colorGrey, fontSize: Dimensions.fontDefault, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Container(height: 10, margin: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(border: Border.all(color: MyColor.colorGrey, width: .5))),
                    GestureDetector(
                      onTap: () => MyUtils.launchPhone(ride.driver?.mobile),
                      child: Row(
                        children: [
                          const CustomSvgPicture(image: MyIcons.callIcon, color: MyColor.bodyText, height: 15, width: 15),
                          const SizedBox(width: Dimensions.space5 - 1),
                          Text("+${ride.driver?.mobile}", style: boldDefault.copyWith(color: MyColor.colorGrey, fontSize: Dimensions.fontDefault, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
                const CustomDivider(space: Dimensions.space10, color: MyColor.bodyText),
                const SizedBox(height: Dimensions.space30),
                Text(MyStrings.ratingDriver.tr, style: semiBoldDefault.copyWith(fontSize: Dimensions.fontOverLarge + 2)),
                const SizedBox(height: Dimensions.space20),
                RatingBar.builder(
                  initialRating: controller.rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (rating) {
                    controller.updateRating(rating);
                  },
                ),
                const SizedBox(height: Dimensions.space25 - 1),
                Text(MyStrings.whatCouldBetter.tr, style: mediumDefault.copyWith(fontSize: Dimensions.fontOverLarge - 1)),
                const SizedBox(height: Dimensions.space12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: CustomTextField(needOutlineBorder: true, animatedLabel: false, labelText: '', onChanged: (v) {}, controller: controller.reviewMsgController, hintText: MyStrings.reviewMsgHintText.tr, maxLines: 5),
                ),
                const SizedBox(height: Dimensions.space30 + 2),
                RoundedButton(
                  text: MyStrings.submit,
                  textColor: MyColor.colorWhite,
                  isLoading: controller.isReviewLoading,
                  press: () {
                    printx(controller.rating);
                    printx(controller.reviewMsgController.text);
                    if (controller.rating > 0 && controller.reviewMsgController.text.isNotEmpty) {
                      controller.reviewRide(ride.id.toString());
                    } else {
                      CustomSnackBar.error(errorList: [MyStrings.ratingRequiredMsg]);
                    }
                  },
                )
              ],
            ),
          ),
        ],
      );
    });
  }
}
