import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carpet_app/layouts/main_layout.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';

class AdminOrderSingleScreen extends StatelessWidget {
  static const routeName = '/admin/orders/single';

  const AdminOrderSingleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      removeScroll: true,
      title: 'Orders',
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoggedInState) return const Text('admin');
          return Container();
        },
      ),
    );
  }
}

class _AdminOrderSingleRender extends StatefulWidget {
  const _AdminOrderSingleRender({Key? key}) : super(key: key);

  @override
  State<_AdminOrderSingleRender> createState() =>
      __AdminOrderSingleRenderState();
}

class __AdminOrderSingleRenderState extends State<_AdminOrderSingleRender> {
  @override
  Widget build(BuildContext context) {
    return const Text('order single');
  }
}
