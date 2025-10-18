import 'package:flutter/material.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import '../../styles/fonts/font_family_helper.dart';
import '../../styles/fonts/font_weight_helper.dart';
import '../inputs/text_app.dart';

class NoNetworkScreen extends StatelessWidget {
  const NoNetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.signal_wifi_bad,size: 150,color: context.colors.primary),
            SizedBox(height: 15,),
            TextApp(
              text: 'No Network Please Open Internet',
              theme: context.textStyle.copyWith(
                fontSize: 22,
                color: context.colors.black,
                fontWeight: FontWeightHelper.medium,
                fontFamily: FontFamilyHelper.poppinsEnglish,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
