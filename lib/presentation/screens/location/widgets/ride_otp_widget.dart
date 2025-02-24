import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovorideuser/core/utils/app_status.dart';
import 'package:ovorideuser/core/utils/dimensions.dart';
import 'package:ovorideuser/core/utils/my_color.dart';
import 'package:ovorideuser/core/utils/my_icons.dart';
import 'package:ovorideuser/core/utils/my_strings.dart';
import 'package:ovorideuser/core/utils/style.dart';
import 'package:ovorideuser/core/utils/util.dart';
import 'package:ovorideuser/data/model/global/app/ride_model.dart';
import 'package:ovorideuser/presentation/components/image/custom_svg_picture.dart';

class RideOtpWidget extends StatelessWidget {
  final RideModel ride;
  const RideOtpWidget({
    super.key,
    required this.ride,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MyColor.colorGrey2.withOpacity(0.5),
        borderRadius: BorderRadius.circular(Dimensions.mediumRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (ride.status == AppStatus.RIDE_ACTIVE.toString()) ...[
            Row(
              children: [
                Text(
                  "${MyStrings.otp.tr}: ${ride.otp}",
                  style: boldDefault.copyWith(color: MyColor.bodyText),
                ),
                const SizedBox(
                  width: Dimensions.space5,
                ),
                InkWell(
                  onTap: () {
                    MyUtils.copy(text: "${ride.otp}");
                  },
                  child: const CustomSvgPicture(
                    image: MyIcons.copy,
                    color: MyColor.bodyText,
                    height: 14,
                    width: 12,
                  ),
                )
              ],
            ),
          ] else ...[
            Text(
              "${MyStrings.date.tr}: ",
              style: boldDefault.copyWith(color: MyColor.bodyText),
            ),
          ],
          Text(
            ride.startTime ?? '',
            style: boldDefault.copyWith(color: MyColor.colorGrey),
          ),
        ],
      ),
    );
  }
}
