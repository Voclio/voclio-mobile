import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/language/lang_keys.dart';
class HomeListTile extends StatelessWidget {
  const HomeListTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        context.translate(LangKeys.welcoming),
        style: context.textStyle.copyWith(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: context.colors.primary,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          'Alex',
          style: context.textStyle.copyWith(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: context.colors.primary,
          ),
        ),
      ),
      trailing: Container(
        decoration: BoxDecoration(
          color: context.colors.primary!.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.notifications,
            color: context.colors.primary,
          ),
        ),
      ),
    );
  }
}
