import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:ovorideuser/core/utils/dimensions.dart';
import 'package:ovorideuser/core/utils/my_color.dart';
import 'package:ovorideuser/core/utils/my_strings.dart';
import 'package:ovorideuser/core/utils/style.dart';
import 'package:ovorideuser/data/controller/privacy/privacy_controller.dart';
import 'package:ovorideuser/data/repo/privacy_repo/privacy_repo.dart';
import 'package:ovorideuser/data/services/api_service.dart';
import 'package:ovorideuser/presentation/components/app-bar/custom_appbar.dart';
import 'package:ovorideuser/presentation/components/buttons/category_button.dart';
import 'package:ovorideuser/presentation/components/custom_loader/custom_loader.dart';
import 'package:ovorideuser/presentation/components/shimmer/privacy_policy_shimmer.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(PrivacyRepo(apiClient: Get.find()));
    final controller = Get.put(PrivacyController(repo: Get.find()));

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PrivacyController>(builder: (controller) {
      return Scaffold(
        backgroundColor: MyColor.colorWhite,
        appBar: CustomAppBar(
          title: controller.isLoading ? MyStrings.privacyPolicy : controller.list[controller.selectedIndex].dataValues?.title ?? '',
          bgColor: MyColor.primaryColor,
          isTitleCenter: true,
        ),
        body: controller.isLoading
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return PrivacyPolicyShimmer();
                  },
                ),
              )
            : SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: Dimensions.space10, top: Dimensions.space15),
                      child: SizedBox(
                        height: 30,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: List.generate(
                              controller.list.length,
                              (index) => Row(
                                children: [
                                  CategoryButton(
                                      color: controller.selectedIndex == index ? MyColor.primaryColor : MyColor.secondaryColor,
                                      horizontalPadding: 8,
                                      verticalPadding: 7,
                                      textColor: controller.selectedIndex == index ? MyColor.colorWhite : MyColor.colorBlack,
                                      text: controller.list[index].dataValues?.title ?? '',
                                      press: () {
                                        controller.changeIndex(index);
                                      }),
                                  const SizedBox(width: Dimensions.space10)
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.space15),
                    Expanded(
                        child: Center(
                      child: SingleChildScrollView(child: Container(padding: const EdgeInsets.all(20), width: double.infinity, color: Colors.transparent, child: HtmlWidget(controller.selectedHtml, textStyle: regularDefault.copyWith(color: Colors.black), onLoadingBuilder: (context, element, loadingProgress) => const Center(child: CustomLoader())))),
                    ))
                  ],
                ),
              ),
      );
    });
  }
}
