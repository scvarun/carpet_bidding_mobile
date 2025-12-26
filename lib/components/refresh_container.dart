import 'package:flutter/material.dart';

class RefreshContainer extends StatelessWidget {
  final VoidCallback onRefresh;
  final Widget child;

  const RefreshContainer(
      {Key? key, required this.onRefresh, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
      },
      child: Container(
          constraints: const BoxConstraints.expand(),
          child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), child: child)),
    );
  }
}
