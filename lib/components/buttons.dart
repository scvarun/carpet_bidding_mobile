import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

enum CustomButtonIconPosition { left, right }

class PrimaryButton extends StatelessWidget {
  final String title;
  final Color? color;
  final bool disabled;
  final bool inverted;
  final Function onPressed;
  final IconData? icon;
  final CustomButtonIconPosition iconPosition;
  final EdgeInsets iconMargin;
  final Color iconColor;
  final double iconSize;
  final TextStyle? style;
  final EdgeInsets padding;

  const PrimaryButton(
      {Key? key,
      required this.title,
      this.color,
      this.disabled = false,
      required this.onPressed,
      this.inverted = false,
      this.icon,
      this.iconPosition = CustomButtonIconPosition.right,
      this.iconMargin = EdgeInsets.zero,
      this.iconColor = Colors.black,
      this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      this.style,
      this.iconSize = 24})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: disabled,
      child: TextButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(generateColor(context)),
            padding: MaterialStateProperty.all<EdgeInsets>(padding),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ))),
        onPressed: () {
          if (!disabled) {
            onPressed();
          }
        },
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          icon != null && iconPosition == CustomButtonIconPosition.left
              ? _iconWidget(context)
              : Container(),
          Expanded(
            child: Text(
              title,
              style: textStyle(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          icon != null && iconPosition == CustomButtonIconPosition.right
              ? _iconWidget(context)
              : Container(),
        ]),
      ),
    );
  }

  Widget _iconWidget(context) {
    return Container(
        margin: iconMargin,
        child: Icon(
          icon,
          color: iconColor,
          size: iconSize,
        ));
  }

  Color generateColor(context) {
    var c = color ?? Theme.of(context).colorScheme.primary;
    if (inverted) {
      return Colors.transparent;
    } else if (disabled) {
      return c.withOpacity(.6);
    }
    return c;
  }

  TextStyle? textStyle(context) {
    if (style != null) {
      return style;
    } else if (inverted && disabled) {
      return TextStyle(
        fontSize: 14.sp,
        color: Theme.of(context).colorScheme.primary.withOpacity(.3),
        fontWeight: FontWeight.w600,
      );
    } else if (inverted) {
      return TextStyle(
        fontSize: 14.sp,
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w600,
      );
    } else {
      return TextStyle(
        fontSize: 14.sp,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      );
    }
  }
}
