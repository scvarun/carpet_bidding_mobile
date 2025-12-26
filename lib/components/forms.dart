import 'package:flutter/material.dart';

class Label extends StatelessWidget {
  final String title;
  final TextStyle? style;

  const Label({Key? key, required this.title, this.style}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: Text(title,
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(
                    fontSize:
                        Theme.of(context).textTheme.bodyText1!.fontSize! * .9)
                .merge(style)));
  }
}

class CustomSwitch extends StatelessWidget {
  final bool value;
  final _CustomOnChanged onChanged;
  final double size;
  final double width;
  final Color? activeBgColor;
  final Color? inactiveBgColor;
  final Color? activeSeekColor;
  final Color? inactiveSeekColor;
  final Duration duration;
  final double padding;

  const CustomSwitch(
      {Key? key,
      required this.value,
      required this.onChanged,
      this.size = 20,
      this.width = 50,
      this.padding = 3,
      this.duration = const Duration(milliseconds: 200),
      this.activeBgColor,
      this.inactiveBgColor,
      this.activeSeekColor,
      this.inactiveSeekColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor = Theme.of(context).colorScheme.primary;
    Color seekColor =
        Theme.of(context).textTheme.bodyText1!.color!.withOpacity(.1);

    if (value) {
      bgColor = activeBgColor ?? Theme.of(context).colorScheme.secondary;
      seekColor = activeSeekColor ?? Colors.white;
    } else {
      bgColor = inactiveBgColor ??
          Theme.of(context).textTheme.bodyText1!.color!.withOpacity(.2);
      seekColor = inactiveSeekColor ??
          Theme.of(context).textTheme.bodyText1!.color ??
          seekColor;
    }

    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: AnimatedContainer(
          duration: duration,
          padding: EdgeInsets.all(padding),
          width: width,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(100),
          ),
          child: AnimatedAlign(
            alignment: Alignment(value ? 1 : -1, 0),
            duration: duration,
            child: AnimatedContainer(
              duration: duration,
              width: size,
              height: size,
              decoration: BoxDecoration(
                  color: seekColor, borderRadius: BorderRadius.circular(100)),
            ),
          )),
    );
  }
}

typedef _CustomOnChanged = void Function(bool value);
