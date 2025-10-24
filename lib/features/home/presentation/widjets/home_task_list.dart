import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';

class HomeTasksList extends StatelessWidget {
  const HomeTasksList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 15.w,
      ),
      child: Container(
        width: double.infinity,
        height: 70.h,
        decoration: BoxDecoration(
          color: context.colors.primaryDark,
          borderRadius: BorderRadius.circular(
            22.r,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 8.w,
          ),
          child: Row(
            children: [
              Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  color:
                  context.colors.primaryLight,
                  borderRadius:
                  BorderRadius.circular(22.r),
                ),
                child: Icon(
                  Icons.task_alt_rounded,
                  size: 30,
                  color: context.colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 18,
                  left: 8,
                ),
                child: Column(
                  children: [
                    Text(
                      'Design review meeting',
                      style: context.textStyle
                          .copyWith(
                          color:
                          context
                              .colors
                              .white,
                          fontSize: 17.sp,
                          fontWeight:
                          FontWeight.bold,
                          fontFamily: 'poppins'
                      ),
                    ),
                    Text(
                      'task . Tomorrow,10 AM',
                      style: context.textStyle
                          .copyWith(
                          color:
                          context
                              .colors
                              .white?.withOpacity(0.5),
                          fontSize: 14.sp,
                          fontWeight:
                          FontWeight.w500,
                          fontFamily: 'poppins'
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              IconButton(onPressed: (){} ,icon:Icon( FontAwesomeIcons.ellipsis,size:26,color: Colors.white, ))
            ],
          ),
        ),
      ),
    );
  }
}
