
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

import '../../../../base/shared_view/common_app_bar.dart';
import '../../../../base/shared_view/common_scaffold.dart';

@RoutePage()
class SettingLanguagePage extends StatefulWidget {
  const SettingLanguagePage({super.key});

  @override
  State<SettingLanguagePage> createState() => _SettingLanguagePageState();
}

class _SettingLanguagePageState extends State<SettingLanguagePage> {
  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      appBar: CommonAppBar(text: 'Language'),
      body: SingleChildScrollView(
        child: Column(
          children: [],
        ),
      ),
    );
  }
}

