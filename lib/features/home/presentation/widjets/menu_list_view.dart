import 'package:flutter/cupertino.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MenuListView extends StatelessWidget {
  const MenuListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90.h,
      child: ListView(
        physics: AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          SizedBox(width: 10.w,),
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: context.colors.primaryLight
                  ?.withOpacity(0.4),
              borderRadius: BorderRadius.circular(
                22.r,
              ),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.center,
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/speak.png',width: 50.w,),
                SizedBox(height: 4.h,),
                Text(
                  'Record',
                  style: context.textStyle
                      .copyWith(fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: context.colors.primaryDarkmode,
                      fontFamily: 'poppins'
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w,),
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: context.colors.primaryLight
                  ?.withOpacity(0.4),
              borderRadius: BorderRadius.circular(
                22.r,
              ),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.center,
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/task-list.png',width: 45.w,),
                SizedBox(height: 4.h,),
                Text(
                  'Tasks',
                  style: context.textStyle
                      .copyWith(fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: context.colors.primaryDarkmode,
                      fontFamily: 'poppins'
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w,),
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: context.colors.primaryLight
                  ?.withOpacity(0.4),
              borderRadius: BorderRadius.circular(
                22.r,
              ),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.center,
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/note.png',width: 45.w,),
                SizedBox(height: 4.h,),
                Text(
                  'Notes',
                  style: context.textStyle
                      .copyWith(fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: context.colors.primaryDarkmode,
                      fontFamily: 'poppins'
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w,),
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: context.colors.primaryLight
                  ?.withOpacity(0.4),
              borderRadius: BorderRadius.circular(
                22.r,
              ),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.center,
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/calendar.png',width: 45.w,),
                SizedBox(height: 4.h,),
                Text(
                  'Calender',
                  style: context.textStyle
                      .copyWith(fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: context.colors.primaryDarkmode,
                      fontFamily: 'poppins'
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
