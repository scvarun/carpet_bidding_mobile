import 'package:flutter/material.dart';

class TouchSpin extends StatelessWidget {
  final IconData addIcon;
  final IconData subtractIcon;
  final int value;
  final TextStyle textStyle;
  final VoidCallback addAction;
  final VoidCallback subtractAction;
  final double iconSize;
  final EdgeInsets iconPadding;
  final EdgeInsets inputPadding;
  final int min;
  final int max;

  const TouchSpin(
      {Key? key,
      required this.addIcon,
      required this.subtractIcon,
      required this.value,
      required this.addAction,
      required this.subtractAction,
      this.min = 1,
      this.max = 100,
      this.iconSize = 24,
      this.iconPadding =
          const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      this.inputPadding =
          const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      this.textStyle = const TextStyle()})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 1, color: Colors.black.withOpacity(.1)),
      ),
      child: Row(children: [
        GestureDetector(
            onTap: value > min ? subtractAction : () {},
            child: Container(
                decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(
                          width: 1, color: Colors.black.withOpacity(.1))),
                ),
                padding: iconPadding,
                child: Icon(subtractIcon, size: iconSize))),
        Container(
            padding: inputPadding,
            child: Text(value.toString(), style: textStyle)),
        GestureDetector(
            onTap: value < max ? addAction : () {},
            child: Container(
                decoration: BoxDecoration(
                  border: Border(
                      left: BorderSide(
                          width: 1, color: Colors.black.withOpacity(.1))),
                ),
                padding: iconPadding,
                child: Icon(addIcon, size: iconSize))),
      ]),
    );
  }
}
