import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc_template/base/helper/checker.dart';

import '../constants/ui/app_colors.dart';

class CommonImageView extends StatelessWidget {
  const CommonImageView({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double? radius;

  factory CommonImageView.circle({required String imageUrl, double? size}) {
    return CommonImageView(imageUrl: imageUrl, width: size, height: size, radius: 100);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: !empty(radius) ? BorderRadius.circular(radius!) : BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => _defaultPlaceholder(
            child: Icon(
          Icons.info,
          color: AppColors.current.greyscale400,
        )),
        // placeholder: (context, url) => _defaultPlaceholder(),
        progressIndicatorBuilder: (context, url, progress) => _defaultPlaceholder(
          child: SizedBox(
            width: 26,
            height: 26,
            child: FittedBox(
                fit: BoxFit.scaleDown,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.current.primary200,
                )),
          ),
        ),
      ),
    );
  }

  Widget _defaultPlaceholder({Widget? child}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.current.greyscale200,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
