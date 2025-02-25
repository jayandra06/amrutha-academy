import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/domain/entity/enum/enum.dart';
import 'package:flutter_bloc_template/resource/generated/assets.gen.dart';

class EditProfileGenderWidget extends StatelessWidget {
  const EditProfileGenderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: Gender.values
          .map<Widget>((e) => ListTile(
                leading: Assets.icons.radioUnselected.svg(),
                title: Text(
                  e.fromTitle(),
                ),
              ))
          .toList(),
    );
  }
}
