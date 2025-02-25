import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_text_styles.dart';

import '../../resource/generated/assets.gen.dart';
import '../constants/ui/app_colors.dart';

class CommonTextField extends StatefulWidget {
  const CommonTextField({
    super.key,
    this.label,
    this.hintText,
    this.errorText,
    this.onChanged,
    this.keyboardType,
    this.isRequired = false,
    this.obscureText = false,
    this.enable = true,
    this.obscuringCharacter,
    this.suffixIcon,
    this.prefixIcon,
    this.prefixIconPath,
    this.controller,
    this.maxLength,
    this.radius = 12.0,
    this.counterText = '',
    this.innerLabel = false,
    this.autoFocus = false,
    this.readOnly = false,
    this.inputFormatters,
    this.onTap,
    this.ignoring = false,
  });

  final String? label;
  final String? hintText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool isRequired;
  final bool obscureText;
  final bool enable;
  final String? obscuringCharacter;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? prefixIconPath;
  final TextEditingController? controller;
  final int? maxLength;
  final double radius;
  final String counterText;
  final bool innerLabel;
  final bool autoFocus;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? onTap;
  final bool ignoring;

  @override
  State<CommonTextField> createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  late ValueNotifier<bool> visibleNotifier = ValueNotifier(widget.obscureText);
  late final TextEditingController _editingController = widget.controller != null ? widget.controller! : TextEditingController();

  late final FocusNode focusNode = FocusNode();

  bool hasFocus = false;

  bool hasValue = false;

  Color get _colorFocus => hasFocus ? AppColors.current.transparentBlue : AppColors.current.greyscale50;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(_listener);
    _editingController.addListener(_editListener);
  }

  @override
  void dispose() {
    visibleNotifier.dispose();
    focusNode.dispose();
    _editingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: IgnorePointer(
            ignoring: widget.ignoring,
            child: ValueListenableBuilder<bool>(
              valueListenable: visibleNotifier,
              builder: (_, visible, __) {
                return TextFormField(
                  readOnly: widget.readOnly,
                  focusNode: focusNode,
                  inputFormatters: widget.inputFormatters,
                  autofocus: widget.autoFocus,
                  onChanged: widget.onChanged,
                  controller: _editingController,
                  enableSuggestions: false,
                  keyboardType: widget.keyboardType,
                  maxLength: widget.maxLength,
                  autocorrect: false,
                  obscureText: visible,
                  enabled: widget.enable,
                  obscuringCharacter: widget.obscuringCharacter ?? '●',
                  style: AppTextStyles.bodyMediumSemiBold,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _colorFocus,
                    counterText: widget.counterText,
                    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                    prefixIcon: _buildPrefixIcon(),
                    suffixIcon: widget.suffixIcon ?? (widget.obscureText ? _buildSuffixIcon() : null),
                    hintText: widget.hintText,
                    hintStyle: AppTextStyles.bodyMediumRegular.copyWith(color: AppColors.current.greyscale500),
                    border: _inputBorder(),
                    focusedBorder: _inputBorder(AppColors.current.primary500),
                    enabledBorder: _inputBorder(widget.errorText != null ? AppColors.current.error : null),
                    errorBorder: _inputBorder(AppColors.current.error),
                    disabledBorder: _inputBorder(),
                    focusedErrorBorder: _inputBorder(AppColors.current.error),
                  ),
                );
              },
            ),
          ),
        ),
        // if (widget.errorText != null) ...[
        //   const SizedBox(height: 6),
        //   Row(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Icon(Icons.clear, size: 16, color: AppColors.current.error),
        //       const SizedBox(width: 4),
        //       Expanded(child: Text(widget.errorText!, style: AppTextStyles.textBody12.copyWith(color: AppColors.current.errorColor)))
        //     ],
        //   )
        // ],
      ],
    );
  }

  InputBorder _inputBorder([Color? color]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.radius),
        borderSide: BorderSide(color: color ?? AppColors.current.greyscale50),
      );

  Widget _buildSuffixIcon() {
    return ValueListenableBuilder<bool>(
        valueListenable: visibleNotifier,
        builder: (_, visible, __) {
          return IconButton(
            icon: Assets.icons.lock.svg(),
            // icon: visible ? Assets.icons.lock.svg() : CoreAssets.icons.icEyeOpen.svg(),
            onPressed: () {
              visibleNotifier.value = !visibleNotifier.value;
            },
          );
        });
  }

  void _listener() {
    setState(() {
      hasFocus = focusNode.hasFocus;
    });
  }

  _buildPrefixIcon() {
    if (widget.prefixIcon != null) return widget.prefixIcon;
    if (widget.prefixIconPath != null && widget.prefixIconPath != '') {
      return IconButton(
        onPressed: () {},
        icon: SvgGenImage(widget.prefixIconPath!).svg(
            width: 20,
            colorFilter: hasFocus
                ? ColorFilter.mode(
                    AppColors.current.primary500,
                    BlendMode.srcIn,
                  )
                : (hasValue ? ColorFilter.mode(AppColors.current.greyscale900, BlendMode.srcIn) : null)),
      );
    }
  }

  void _editListener() {
    if (_editingController.text.trim().isEmpty) {
      if (!hasValue) return;
      setState(() {
        hasValue = false;
      });
    } else {
      if (hasValue) return;
      setState(() {
        hasValue = true;
      });
    }
  }
}
