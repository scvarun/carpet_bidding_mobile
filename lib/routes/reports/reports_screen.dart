import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carpet_app/layouts/main_layout.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';

class ReportsScreen extends StatelessWidget {
  static const routeName = '/reports';

  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoggedInState) return const _ReportsRender();
        return Container();
      },
    );
  }
}

class _ReportsRender extends StatefulWidget {
  const _ReportsRender({Key? key}) : super(key: key);

  @override
  State<_ReportsRender> createState() => __ReportsRenderState();
}

class __ReportsRenderState extends State<_ReportsRender> {
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      removeScroll: true,
      title: 'Reports',
      child: Container(
          margin: const EdgeInsets.only(top: 20),
          child: const Text('No reports available yet')),
    );
  }
}
