import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ovorideuser/core/helper/string_format_helper.dart';

import 'package:ovorideuser/core/utils/dimensions.dart';
import 'package:ovorideuser/core/utils/my_color.dart';
import 'package:ovorideuser/core/utils/my_strings.dart';
import 'package:ovorideuser/core/utils/style.dart';
import 'package:ovorideuser/core/utils/util.dart';
import 'package:ovorideuser/data/controller/home/home_controller.dart';
import 'package:ovorideuser/presentation/screens/home/widgets/service_card.dart';

class RideServiceSection extends StatelessWidget {
  const RideServiceSection({super.key});

  @override
  Widget build(BuildContext context) {
    loggerX("controller.selectedLocations.length ${Get.find<HomeController>().selectedLocations.length}");
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          decoration: BoxDecoration(color: MyColor.colorWhite, borderRadius: BorderRadius.circular(Dimensions.space12), boxShadow: MyUtils.getCardTopShadow()),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(MyStrings.selectService.tr, style: boldLarge.copyWith(color: MyColor.getRideTitleColor(), fontWeight: FontWeight.w600, fontSize: 17)),
              ),
              SizedBox(height: Dimensions.space5 - 2),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(
                    controller.appServices.length,
                    (index) => GestureDetector(
                      onTap: () {
                        controller.selectService(controller.appServices[index]);
                      },
                      child: ServiceCard(service: controller.appServices[index], controller: controller),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
