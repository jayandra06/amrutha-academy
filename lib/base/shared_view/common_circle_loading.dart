import 'package:flutter/material.dart';

import '../../resource/generated/assets.gen.dart';

class CommonCircleLoading extends StatelessWidget {
  const CommonCircleLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Assets.animations.loading.lottie(width: 100));
  }
}
