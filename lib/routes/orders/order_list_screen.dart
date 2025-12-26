import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carpet_app/layouts/main_layout.dart';
import 'package:carpet_app/lib/refresh_tokens.dart';
import 'package:carpet_app/models/inventory.dart';
import 'package:carpet_app/models/order.dart';
import 'package:carpet_app/routes/index.dart';
import 'package:carpet_app/services/messages.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:carpet_app/store/orders/order_repo.dart' as order_repo;
import 'package:sizer/sizer.dart';

enum _OrderListTabs { all, enquiries, orders, cancelled, pending }

class OrderListScreen extends StatelessWidget {
  static const routeName = '/orders';

  const OrderListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoggedInState) return const _OrderListRender();
        return Container();
      },
    );
  }
}

class _OrderListRender extends StatefulWidget {
  const _OrderListRender({Key? key}) : super(key: key);

  @override
  State<_OrderListRender> createState() => __OrderListRenderState();
}

class __OrderListRenderState extends State<_OrderListRender> {
  late _OrderListTabs _activeTab = _OrderListTabs.all;
  late Future _getOrders;
  late List<ApiOrder>? _orders;
  final _stream = StreamController.broadcast();

  @override
  void initState() {
    super.initState();
    _getOrders = _loadOrders(context);
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    _stream.addStream(
        MessageService().listOrders(authState.auth).asBroadcastStream());
    _stream.stream.asBroadcastStream().listen((e) {
      setState(() {
        _getOrders = _loadOrders(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      removeScroll: true,
      title: 'Orders',
      child: Column(
        children: [
          _tabs(context),
          Expanded(
            child: StreamBuilder(
              stream: _stream.stream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  return _orderListFuture(context);
                } else if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _orderListFuture(BuildContext context) {
    return FutureBuilder(
      future: _getOrders,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return SingleChildScrollView(
              child: RefreshIndicator(
            onRefresh: () async {
              _getOrders = _loadOrders(context);
            },
            child: _orderList(context, snapshot.data),
          ));
        } else if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _orderList(BuildContext context, List<ApiOrder> order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [..._orders!.map((e) => _orderSingle(context, e))],
    );
  }

  Widget _orderSingle(BuildContext context, ApiOrder order) {
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).pushNamed(OrderSingleScreen.routeName,
            arguments: OrderSingleScreen.args(uuid: order.uuid ?? ''));
        _getOrders = _loadOrders(context);
      },
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: Colors.black12, width: 2))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RichText(
                    text: TextSpan(
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(
                              color: Colors.black,
                              fontSize: 10.sp,
                              height: 1.8,
                              fontWeight: FontWeight.bold,
                            ),
                        children: [
                      TextSpan(
                          text: 'Order ID\t\t'.toUpperCase(),
                          style: const TextStyle(color: Colors.black54)),
                      TextSpan(text: '${order.sid}\n'.toUpperCase()),
                      TextSpan(
                          text: 'Product Type\t\t'.toUpperCase(),
                          style: const TextStyle(color: Colors.black54)),
                      TextSpan(
                          text: '${order.type.toString().split('.').last}\n'
                              .toUpperCase()),
                      TextSpan(
                          text: 'Reference\t\t'.toUpperCase(),
                          style: const TextStyle(color: Colors.black54)),
                      TextSpan(text: '${order.reference}\n'.toUpperCase()),
                      TextSpan(
                          text: 'Catalogue\t\t'.toUpperCase(),
                          style: const TextStyle(color: Colors.black54)),
                      TextSpan(
                          text:
                              '${order.catalogue?.name ?? ''}\n'.toUpperCase()),
                      if (order.type == ApiInventoryTypes.rolls)
                        TextSpan(children: [
                          TextSpan(
                              text: 'Pattern No\t\t'.toUpperCase(),
                              style: const TextStyle(color: Colors.black54)),
                          TextSpan(text: '${order.patternNo}\n'.toUpperCase()),
                        ]),
                      TextSpan(
                          text: 'Quantity\t\t'.toUpperCase(),
                          style: const TextStyle(color: Colors.black54)),
                      TextSpan(text: '${order.quantity}\n'.toUpperCase()),
                      TextSpan(
                          text: 'Remarks\t\t'.toUpperCase(),
                          style: const TextStyle(color: Colors.black54)),
                      TextSpan(text: '${order.notes ?? ''}\n'.toUpperCase()),
                    ])),
              ),
              Text(order.status!.status!.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: Colors.black,
                        fontSize: 10.sp,
                        height: 1.8,
                        fontWeight: FontWeight.bold,
                      ))
            ],
          )),
    );
  }

  Widget _tabs(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: const BoxDecoration(
          color: Colors.black12,
        ),
        child: Row(
          children: [
            _singleTab(context, _OrderListTabs.all),
            _singleTab(context, _OrderListTabs.enquiries),
            _singleTab(context, _OrderListTabs.orders),
            _singleTab(context, _OrderListTabs.cancelled),
            _singleTab(context, _OrderListTabs.pending),
          ],
        ));
  }

  _singleTab(BuildContext context, _OrderListTabs tab) {
    var title = '';
    switch (tab) {
      case _OrderListTabs.all:
        title = 'All';
        break;
      case _OrderListTabs.enquiries:
        title = 'Enquiries';
        break;
      case _OrderListTabs.orders:
        title = 'Orders';
        break;
      case _OrderListTabs.cancelled:
        title = 'Cancelled';
        break;
      case _OrderListTabs.pending:
        title = 'Pending';
        break;
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = tab;
          _getOrders = _loadOrders(context);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Opacity(
            opacity: _activeTab == tab ? 1 : .5,
            child: Text(title, style: Theme.of(context).textTheme.bodyText1)),
      ),
    );
  }

  Future _loadOrders(BuildContext context) async {
    List<ApiOrderStatusTypes> types = [];
    switch (_activeTab) {
      case _OrderListTabs.all:
        types = [
          ApiOrderStatusTypes.not_available,
          ApiOrderStatusTypes.available,
          ApiOrderStatusTypes.cancelled,
          ApiOrderStatusTypes.completed,
          ApiOrderStatusTypes.dispatched,
          ApiOrderStatusTypes.enquired,
          ApiOrderStatusTypes.new_enquiry,
          ApiOrderStatusTypes.order_confirmed,
          ApiOrderStatusTypes.placed_order,
          ApiOrderStatusTypes.received_stock
        ];
        break;
      case _OrderListTabs.enquiries:
        types = [
          ApiOrderStatusTypes.not_available,
          ApiOrderStatusTypes.available,
          ApiOrderStatusTypes.enquired,
          ApiOrderStatusTypes.new_enquiry,
        ];
        break;
      case _OrderListTabs.orders:
        types = [
          ApiOrderStatusTypes.completed,
          ApiOrderStatusTypes.dispatched,
          ApiOrderStatusTypes.placed_order,
          ApiOrderStatusTypes.order_confirmed,
          ApiOrderStatusTypes.received_stock
        ];
        break;
      case _OrderListTabs.cancelled:
        types = [
          ApiOrderStatusTypes.cancelled,
        ];
        break;
      case _OrderListTabs.pending:
        types = [
          ApiOrderStatusTypes.pending,
        ];
        break;
    }
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    var auth = await refreshToken(context, authState);
    var orders = await order_repo.loadOrders(auth, type: types);
    setState(() {
      _orders = orders;
    });
    return orders;
  }
}
