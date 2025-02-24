import 'package:flutter/material.dart';
import 'package:ovorideuser/core/utils/my_color.dart';
import 'package:ovorideuser/presentation/components/bottom-sheet/bottom_sheet_close_button.dart';

class MyBottomSheetBar extends StatelessWidget {
  const MyBottomSheetBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: 5,
            width: 50,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: MyColor.colorGrey.withOpacity(0.2)),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: const BottomSheetCloseButton(),
        ),
      ],
    );
  }
}
