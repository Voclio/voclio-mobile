import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';


class HomeDashboard extends StatelessWidget {
  const HomeDashboard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Container(
        width: double.infinity,
        height: 150.h,
        decoration: BoxDecoration(
            color: context.colors.primaryDark,
            borderRadius: BorderRadius.circular(22.r)
        ),
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 15.w,vertical: 5.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DashBoard',style: context.textStyle.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
                color: context.colors.white,

              ),),
              SizedBox(height: 10.h,),
              SizedBox(
                height: 90.h,
                child: Row(

                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('3',style: context.textStyle.copyWith(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w500,
                          color: context.colors.white,
                        ),),
                        Text('\t\t\t\tTasks\nCompleted',style: context.textStyle.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: context.colors.white,
                        ),),
                      ],
                    ),
                    SizedBox(width: 18.w,),
                    Column(
                      children: [
                        Text('5',style: context.textStyle.copyWith(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w500,
                          color: context.colors.white,
                        ),),
                        Text('\t\t\tTasks\nremaining',style: context.textStyle.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: context.colors.white,
                        ),),
                      ],
                    ),
                    SizedBox(width: 18.w,),
                    VerticalDivider(
                      indent: 5,
                      endIndent: 20,
                      color: context.colors.white,
                      thickness: 1,
                    ),

                    Column(
                      children: [
                        Text('3h',style: context.textStyle.copyWith(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w500,
                          color: context.colors.white,
                        ),),
                        Text('Total\n\ttime',style: context.textStyle.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: context.colors.white,
                        ),),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 20,bottom: 15),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 70.w,
                            height: 70.w,
                            child: CircularProgressIndicator(
                              value: 0.6, // نسبة التقدم 60%
                              strokeWidth: 8,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                            ),
                          ),
                          Text(
                            "60%",
                            style: context.textStyle.copyWith(
                              color: context.colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18.sp,
                            ),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

