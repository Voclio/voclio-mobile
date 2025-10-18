import 'package:flutter/material.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';

import '../../../../core/language/lang_keys.dart';
import '../widgets/auth_title_info.dart';
import '../widgets/dark_and_Lang_bar.dart';

class LoginBodyScreen extends StatelessWidget {
  const LoginBodyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // color change and language change
            DarkAndLangBar(),

            // title info
            AuthTitleInfo(
              title: context.translate(LangKeys.login),
              description: context.translate(LangKeys.welcome),
            ),
          ],
        ),
      ),
    );
  }
}
