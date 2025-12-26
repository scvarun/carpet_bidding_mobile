import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:carpet_app/layouts/main_layout.dart';
import 'package:carpet_app/lib/payment_types.dart';
import 'package:carpet_app/lib/refresh_tokens.dart';
import 'package:carpet_app/models/app_error.dart';
import 'package:carpet_app/models/inventory.dart';
import 'package:carpet_app/models/message.dart';
import 'package:carpet_app/models/order.dart';
import 'package:carpet_app/models/user.dart';
import 'package:carpet_app/models/user_type.dart';
import 'package:carpet_app/routes/index.dart';
import 'package:carpet_app/services/messages.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:carpet_app/store/orders/order_repo.dart' as order_repo;
import 'package:protobuf/protobuf.dart';
import 'package:sizer/sizer.dart';

class _OrderSingleScreenArgs {
  String uuid;
  _OrderSingleScreenArgs({required this.uuid});
}

class OrderSingleScreen extends StatelessWidget {
  static const routeName = '/orders/single';

  const OrderSingleScreen({Key? key}) : super(key: key);

  static _OrderSingleScreenArgs args({required String uuid}) {
    return _OrderSingleScreenArgs(uuid: uuid);
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as _OrderSingleScreenArgs;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoggedInState) return _OrderSingleRender(args);
        return Container();
      },
    );
  }
}

class _OrderSingleRender extends StatefulWidget {
  final _OrderSingleScreenArgs args;

  const _OrderSingleRender(this.args, {Key? key}) : super(key: key);

  @override
  State<_OrderSingleRender> createState() => __OrderSingleRenderState();
}

class __OrderSingleRenderState extends State<_OrderSingleRender> {
  late Future _getOrder;
  late ApiOrder _order;
  var _messagesActive = false;
  final _messageBoxController = TextEditingController();
  final _backofficePopupController = TextEditingController();
  final _dealerPopupController = TextEditingController();
  final _deliveredController = TextEditingController();
  final _deliveredNoteController = TextEditingController();
  final _editOrderController = TextEditingController();
  late String _deliveredPaymentType = '';
  final _stream = StreamController.broadcast();

  @override
  void initState() {
    super.initState();
    _getOrder = _loadOrder(context);
    _deliveredPaymentType = 'Cash';
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    _stream.addStream(
        MessageService().listOrders(authState.auth).asBroadcastStream());
    _stream.stream.asBroadcastStream().listen((e) {
      setState(() {
        if (e == widget.args.uuid) {
          _getOrder = _loadOrder(context);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      removeScroll: true,
      title: 'Orders',
      headerAddon: Row(
        children: [
          TextButton.icon(
              icon: Icon(Icons.chevron_left,
                  color: Colors.white,
                  size:
                      (Theme.of(context).textTheme.bodyText1!.fontSize!) * 1.4),
              onPressed: () {
                Navigator.of(context).pop();
              },
              label: Text('Back',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(color: Colors.white)))
        ],
      ),
      child: StreamBuilder(
        stream: _stream.stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Container(
            child: _orderFuture(context),
          );
        },
      ),
    );
  }

  Widget _orderFuture(BuildContext context) {
    return FutureBuilder(
      future: _getOrder,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data != null) {
            return _orderSingleRender(context);
          } else {
            return const Center(child: Text('Invalid order'));
          }
        } else if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _orderSingleRender(BuildContext context) {
    return Column(
      children: [
        _orderId(context),
        Expanded(
          child: SingleChildScrollView(
              child: Column(children: [
            _orderInfo(context),
            _messageList(context),
          ])),
        ),
        if (_order.status!.slug != ApiOrderStatusTypes.completed &&
            _order.status!.slug != ApiOrderStatusTypes.cancelled)
          _messageForm(context),
      ],
    );
  }

  Widget _orderId(BuildContext context) {
    return Container(
        color: Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
                text: TextSpan(
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(
                          color: Colors.white,
                          fontSize: 10.sp,
                          height: 1.8,
                          fontWeight: FontWeight.bold,
                        ),
                    children: [
                  TextSpan(
                      text: 'Order ID\t\t'.toUpperCase(),
                      style: const TextStyle(color: Colors.white54)),
                  TextSpan(text: '${_order.sid}\n'.toUpperCase()),
                ])),
            RichText(
                text: TextSpan(
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(
                          color: Colors.white,
                          fontSize: 10.sp,
                          height: 1.8,
                          fontWeight: FontWeight.bold,
                        ),
                    children: [
                  TextSpan(
                      text: 'Status\t\t'.toUpperCase(),
                      style: const TextStyle(color: Colors.white54)),
                  TextSpan(text: '${_order.status!.status}\n'.toUpperCase()),
                ]))
          ],
        ));
  }

  Widget _orderInfo(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: const BoxDecoration(
            color: Colors.black12,
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
                            height: 2,
                            fontWeight: FontWeight.bold,
                          ),
                      children: [
                    TextSpan(
                        text: 'Product Type\t\t'.toUpperCase(),
                        style: const TextStyle(color: Colors.black54)),
                    TextSpan(
                        text: '${_order.type.toString().split('.').last}\n'
                            .toUpperCase()),
                    TextSpan(
                        text: 'Reference\t\t'.toUpperCase(),
                        style: const TextStyle(color: Colors.black54)),
                    TextSpan(text: '${_order.reference}\n'.toUpperCase()),
                    TextSpan(
                        text: 'Catalogue\t\t'.toUpperCase(),
                        style: const TextStyle(color: Colors.black54)),
                    TextSpan(
                        text:
                            '${_order.catalogue?.name ?? ''}\n'.toUpperCase()),
                    if (_order.type == ApiInventoryTypes.rolls)
                      TextSpan(children: [
                        TextSpan(
                            text: 'Pattern No\t\t'.toUpperCase(),
                            style: const TextStyle(color: Colors.black54)),
                        TextSpan(text: '${_order.patternNo}\n'.toUpperCase()),
                      ]),
                    TextSpan(
                        text: 'Quantity\t\t'.toUpperCase(),
                        style: const TextStyle(color: Colors.black54)),
                    TextSpan(text: '${_order.quantity}'.toUpperCase()),
                  ])),
            ),
            _orderActions(context),
          ],
        ));
  }

  Widget _orderActions(BuildContext context) {
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (authState.auth.user!.userType!.type == ApiUserTypes.admin &&
            (_order.status!.slug == ApiOrderStatusTypes.order_confirmed ||
              _order.status!.slug == ApiOrderStatusTypes.placed_order||
                _order.status!.slug == ApiOrderStatusTypes.cancelled ||
                _order.status!.slug == ApiOrderStatusTypes.new_enquiry))
          TextButton(
            onPressed: () async {
              await Navigator.of(context).pushNamed(
                  AdminOrderSendEnquiryScreen.routeName,
                  arguments:
                      AdminOrderSendEnquiryScreen.args(uuid: _order.uuid!));
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    margin: const EdgeInsets.only(right: 5),
                    child: Icon(Icons.whatsapp, size: 18.sp)),
                Text('Notify\nContacts',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 10.sp))
              ],
            ),
          ),
        if (authState.auth.user!.uuid == _order.user!.uuid &&
            _order.status!.slug == ApiOrderStatusTypes.not_available)
          TextButton(
            onPressed: () async {
              var proceed = await showDialog(
                  context: context,
                  builder: (context) {
                    return _proceedDialog(context);
                  });
              if (proceed == null) return;
              _pendingOrder(context);
            },
            child: Row(
              children: [
                Container(
                    margin: const EdgeInsets.only(right: 5),
                    child: Icon(Icons.close,
                        color: Theme.of(context).colorScheme.primary,
                        size: 18.sp)),
                Text('Pending',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: Theme.of(context).colorScheme.primary))
              ],
            ),
          ),
        if (authState.auth.user!.uuid == _order.user!.uuid &&
            _order.status!.slug == ApiOrderStatusTypes.pending)
          TextButton(
            onPressed: () async {
              var proceed = await showDialog(
                  context: context,
                  builder: (context) {
                    return _proceedDialog(context);
                  });
              if (proceed == null) return;
              _reorder(context);
            },
            child: Row(
              children: [
                Container(
                    margin: const EdgeInsets.only(right: 5),
                    child: Icon(Icons.refresh,
                        color: Theme.of(context).colorScheme.primary,
                        size: 18.sp)),
                Text('Reorder',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: Theme.of(context).colorScheme.primary))
              ],
            ),
          ),
        if (authState.auth.user!.userType!.type == ApiUserTypes.admin &&
            (_order.status!.slug == ApiOrderStatusTypes.new_enquiry ||
                _order.status!.slug == ApiOrderStatusTypes.enquired ||
                _order.status!.slug == ApiOrderStatusTypes.pending ||
                _order.status!.slug == ApiOrderStatusTypes.not_available))
          TextButton(
            onPressed: () async {
              var proceed = await showDialog(
                  context: context,
                  builder: (context) {
                    return _proceedDialog(context);
                  });
              if (proceed == null) return;
              _changeStatusAdmin(context, ApiOrderStatusTypes.available);
            },
            child: Row(
              children: [
                Container(
                    margin: const EdgeInsets.only(right: 5),
                    child: Icon(Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                        size: 18.sp)),
                Text('Available',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: Theme.of(context).colorScheme.primary))
              ],
            ),
          ),
        if (authState.auth.user!.userType!.type == ApiUserTypes.dealer &&
            (_order.status!.slug == ApiOrderStatusTypes.new_enquiry ||
                _order.status!.slug == ApiOrderStatusTypes.enquired ||
                _order.status!.slug == ApiOrderStatusTypes.pending ||
                _order.status!.slug == ApiOrderStatusTypes.available))
          TextButton(
            onPressed: () async {
              var proceed = await showDialog(
                  context: context,
                  builder: (context) {
                    return _editOrderDialog(context);
                  });
              if (proceed == null) return;
              _editOrder(context);
            },
            child: Row(
              children: [
                Container(
                    margin: const EdgeInsets.only(right: 5),
                    child: Icon(Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                        size: 18.sp)),
                Text('Edit\nOrder',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: Theme.of(context).colorScheme.primary))
              ],
            ),
          ),
        if (authState.auth.user!.userType!.type == ApiUserTypes.admin &&
            (_order.status!.slug == ApiOrderStatusTypes.new_enquiry ||
                _order.status!.slug == ApiOrderStatusTypes.enquired))
          TextButton(
            onPressed: () async {
              var proceed = await showDialog(
                  context: context,
                  builder: (context) {
                    return _proceedDialog(context);
                  });
              if (proceed == null) return;
              _changeStatusAdmin(context, ApiOrderStatusTypes.not_available);
            },
            child: Row(
              children: [
                Container(
                    margin: const EdgeInsets.only(right: 5),
                    child: Icon(Icons.remove,
                        color: Theme.of(context).colorScheme.error,
                        size: 18.sp)),
                Text('Not\nAvailable',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: Theme.of(context).colorScheme.error))
              ],
            ),
          ),
        if (authState.auth.user!.userType!.type == ApiUserTypes.dealer &&
            _order.status!.slug == ApiOrderStatusTypes.available)
          TextButton(
            onPressed: () async {
              var proceed = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Are you sure?'),
                      content: const Text('Do you want to place order?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: const Text('Proceed'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                      ],
                    );
                  });
              if (proceed == null) return;
              _placeOrder(context);
            },
            child: Row(
              children: [
                Container(
                    margin: const EdgeInsets.only(right: 5),
                    child: Icon(Icons.shopping_bag,
                        color: Theme.of(context).colorScheme.primary,
                        size: 18.sp)),
                Text('Place\nOrder',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: Theme.of(context).colorScheme.primary))
              ],
            ),
          ),
        if (authState.auth.user!.userType!.type == ApiUserTypes.admin &&
            _order.status!.slug == ApiOrderStatusTypes.placed_order)
          TextButton(
            onPressed: () async {
              var proceed = await showDialog(
                  context: context,
                  builder: (context) {
                    return _proceedDialog(context);
                  });
              if (proceed == null) return;
              _changeStatusAdmin(context, ApiOrderStatusTypes.order_confirmed);
            },
            child: Row(
              children: [
                Container(
                    margin: const EdgeInsets.only(right: 5),
                    child: Icon(Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                        size: 18.sp)),
                Text('Approve Order',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: Theme.of(context).colorScheme.primary))
              ],
            ),
          ),
        if (authState.auth.user!.userType!.type == ApiUserTypes.backoffice &&
            _order.status!.slug == ApiOrderStatusTypes.order_confirmed)
          TextButton(
            onPressed: () async {
              var proceed = await showDialog(
                  context: context,
                  builder: (context) {
                    return _proceedDialog(context);
                  });
              if (proceed == null) return;
              _changeStatusBackoffice(
                  context, ApiOrderStatusTypes.received_stock);
            },
            child: Row(
              children: [
                Container(
                    margin: const EdgeInsets.only(right: 5),
                    child: Icon(Icons.close,
                        color: Theme.of(context).colorScheme.primary,
                        size: 18.sp)),
                Text('Recieved Stock',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: Theme.of(context).colorScheme.primary))
              ],
            ),
          ),
        if ((authState.auth.user!.userType!.type == ApiUserTypes.admin &&
            _order.status!.slug == ApiOrderStatusTypes.received_stock))
          TextButton(
            onPressed: () async {
              var proceed = await showDialog(
                  context: context,
                  builder: (context) {
                    return _deliveryDialog(context);
                  });
              if (proceed == null) return;
              _changeStatusAdmin(
                context,
                ApiOrderStatusTypes.dispatched,
                delivered: _order.quantity,
                notes: _deliveredNoteController.text,
                deliveredPaymentType: _deliveredPaymentType,
              );

              // var proceed = await showDialog(
              //     context: context,
              //     builder: (context) {
              //       return _proceedDialog(context);
              //     });
              // if (proceed == null) return;
              // _changeStatusAdmin(
              //   context,
              //   ApiOrderStatusTypes.dispatched,
              // );
            },
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 5),
                  child: Icon(Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18.sp),
                ),
                Text('Dispatch',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: Theme.of(context).colorScheme.primary))
              ],
            ),
          ),
        if (authState.auth.user!.userType!.type == ApiUserTypes.admin &&
            (_order.deliveries ?? []).isEmpty &&
            _order.status!.slug == ApiOrderStatusTypes.dispatched)
          TextButton(
            onPressed: () async {
              var proceed = await showDialog(
                  context: context,
                  builder: (context) {
                    return _deliveryDialog(context);
                  });
              if (proceed == null) return;
              _changeStatusAdmin(
                context,
                ApiOrderStatusTypes.dispatched,
                delivered: _order.quantity,
                notes: _deliveredNoteController.text,
                deliveredPaymentType: _deliveredPaymentType,
              );
            },
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 5),
                  child: Icon(Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18.sp),
                ),
                Text('Set\nPayment',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: Theme.of(context).colorScheme.primary))
              ],
            ),
          ),
        if (authState.auth.user!.userType!.type == ApiUserTypes.backoffice &&
            _order.status!.slug == ApiOrderStatusTypes.dispatched)
          TextButton(
            onPressed: () async {
              // var proceed = await showDialog(
              //     context: context,
              //     builder: (context) {
              //       return _deliveryDialog(context);
              //     });
              // if (proceed == null) return;
              // if (int.tryParse(_deliveredController.text) == null) {
              //   ScaffoldMessenger.of(context).showSnackBar(
              //       const SnackBar(content: Text('Invalid units')));
              // }
              _changeStatusBackoffice(
                context,
                ApiOrderStatusTypes.completed,
              );
            },
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 5),
                  child: Icon(Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18.sp),
                ),
                Text('Mark\nCompleted',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: Theme.of(context).colorScheme.primary))
              ],
            ),
          ),
        if ((authState.auth.user!.userType!.type == ApiUserTypes.admin ||
                authState.auth.user!.userType!.type == ApiUserTypes.dealer) &&
            _order.status!.slug != ApiOrderStatusTypes.order_confirmed &&
            _order.status!.slug != ApiOrderStatusTypes.dispatched &&
            _order.status!.slug != ApiOrderStatusTypes.completed &&
            _order.status!.slug != ApiOrderStatusTypes.cancelled)
          TextButton(
            onPressed: () async {
              var proceed = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Are you sure?'),
                      content: const Text(
                          'Do you really want to cancel this order?'),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: const Text('Proceed')),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'))
                      ],
                    );
                  });
              if (proceed == null) return;
              _cancelOrder(context);
            },
            child: Row(
              children: [
                Container(
                    margin: const EdgeInsets.only(right: 5),
                    child: Icon(Icons.close, color: Colors.red, size: 18.sp)),
                Text('Cancel\nRequest',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 10.sp, color: Colors.red))
              ],
            ),
          ),
      ],
    );
  }

  Widget _proceedDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Are you sure?'),
      content:
          const Text('Do you really want to change the status of this order?'),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Proceed')),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel')),
      ],
    );
  }

  Widget _orderConfirmedDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Are you sure?'),
      content:
          const Text('Do you really want to change the status of this order?'),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Proceed')),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel')),
      ],
    );
  }

  Widget _editOrderDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Order'),
      content: TextField(
        keyboardType: TextInputType.number,
        controller: _editOrderController,
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Edit Quantity',
            labelText: 'Edit Quantity'),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Proceed')),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel')),
      ],
    );
  }

  Widget _deliveryDialog(BuildContext context) {
    return AlertDialog(
      content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return SingleChildScrollView(
          child: ListBody(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Text('Confirm Delivery',
                    style: Theme.of(context).textTheme.headline6),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  border: Border.all(width: 2, color: Colors.black12),
                ),
                child: DropdownButton<String>(
                    isExpanded: true,
                    value: _deliveredPaymentType,
                    underline: Container(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _deliveredPaymentType = value;
                        });
                      }
                    },
                    items: paymentTypes
                        .map((e) => DropdownMenuItem(child: Text(e), value: e))
                        .toList()),
              ),
              Container(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                child: TextField(
                  style: TextStyle(
                    fontSize: 12.sp,
                  ),
                  controller: _deliveredNoteController,
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                    labelText: "Notes",
                  ),
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Confirm')),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel')),
              ])
            ],
          ),
        );
      }),
    );
  }

  Widget _messageList(BuildContext context) {
    return _MessageList(
      messageRoomUUID: _order.messageRoom!.uuid!,
      user: _order.user!,
    );
  }

  Widget _messageForm(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: const BoxDecoration(
          color: Colors.black12,
        ),
        child: Row(children: [
          if (_messagesActive)
            TextButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(const CircleBorder())),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  Timer(const Duration(milliseconds: 100), () {
                    setState(() {
                      _messagesActive = false;
                    });
                  });
                },
                child: const Icon(Icons.close)),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: TextField(
                controller: _messageBoxController,
                decoration: const InputDecoration(
                    hintText: 'Type message here',
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    border: InputBorder.none),
                onTap: () {
                  setState(() {
                    _messagesActive = true;
                  });
                },
              ),
            ),
          ),
          TextButton(
              onPressed: () async {
                if (_messageBoxController.text.isNotEmpty) {
                  await _postMessage(context, _order.messageRoom!.uuid!,
                      _messageBoxController.text);
                  _messageBoxController.clear();
                }
              },
              child: const Text('Send'))
        ]));
  }

  Future<ApiOrder?> _loadOrder(BuildContext context) async {
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    var auth = await refreshToken(context, authState);
    var order = await order_repo.loadOrder(auth, widget.args.uuid);
    if (order != null) {
      setState(() {
        _order = order;
      });
    }
    return order;
  }

  Future<bool?> _cancelOrder(BuildContext context) async {
    try {
      var authState = context.read<AuthBloc>().state as AuthLoggedInState;
      var auth = await refreshToken(context, authState);
      if (auth.user!.userType!.isType(ApiUserTypes.admin)) {
        var proceed = await showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) {
              return AlertDialog(
                content: SingleChildScrollView(
                  child: ListBody(children: [
                    Text('Optional Messages',
                        style: Theme.of(context).textTheme.headline6),
                    Container(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: TextField(
                        controller: _dealerPopupController,
                        maxLines: 4,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                          labelText: "Message To Dealer",
                        ),
                      ),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              child: const Text('Submit'))
                        ])
                  ]),
                ),
              );
            });
        if (proceed == null) return null;
      }
      var order = await order_repo.cancelOrder(auth,
          order: _order, messageForDealer: _dealerPopupController.text);
      if (auth.user!.userType!.isType(ApiUserTypes.admin)) {
        await _postMessage(
            context, _order.messageRoom!.uuid!, _dealerPopupController.text);
      }
      setState(() {
        _getOrder = _loadOrder(context);
      });
      return order;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppError.fromError(e).toString())));
      return null;
    }
  }

  Future<bool?> _pendingOrder(BuildContext context) async {
    try {
      var authState = context.read<AuthBloc>().state as AuthLoggedInState;
      var auth = await refreshToken(context, authState);
      var order = await order_repo.pendingOrder(
        auth,
        order: _order,
      );
      setState(() {
        _getOrder = _loadOrder(context);
      });
      return order;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppError.fromError(e).toString())));
      return null;
    }
  }

  Future<bool?> _reorder(BuildContext context) async {
    try {
      var authState = context.read<AuthBloc>().state as AuthLoggedInState;
      var auth = await refreshToken(context, authState);
      var order = await order_repo.reorder(
        auth,
        order: _order,
      );
      setState(() {
        _getOrder = _loadOrder(context);
      });
      return order;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppError.fromError(e).toString())));
      return null;
    }
  }

  Future<bool?> _placeOrder(BuildContext context) async {
    try {
      var authState = context.read<AuthBloc>().state as AuthLoggedInState;
      var auth = await refreshToken(context, authState);
      var order = await order_repo.placeOrder(auth, order: _order);
      setState(() {
        _getOrder = _loadOrder(context);
      });
      return order;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppError.fromError(e).toString())));
      return null;
    }
  }

  Future<bool?> _editOrder(BuildContext context) async {
    try {
      var authState = context.read<AuthBloc>().state as AuthLoggedInState;
      var auth = await refreshToken(context, authState);
      var quantity = int.parse(_editOrderController.text);
      var order =
          await order_repo.editOrder(auth, order: _order, quantity: quantity);
      setState(() {
        _getOrder = _loadOrder(context);
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order updated successfully')));
      return order;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppError.fromError(e).toString())));
      return null;
    }
  }

  Future<bool?> _changeStatusAdmin(
    BuildContext context,
    ApiOrderStatusTypes status, {
    int? delivered,
    String? notes,
    String? deliveredPaymentType,
  }) async {
    try {
      var authState = context.read<AuthBloc>().state as AuthLoggedInState;
      var auth = await refreshToken(context, authState);
      var proceed = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Text('Optional Messages',
                          style: Theme.of(context).textTheme.headline6),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: TextField(
                        controller: _dealerPopupController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                          hintText: "Message To Dealer",
                          labelText: "Message To Dealer",
                        ),
                      ),
                    ),
                    if (_order.status!.slug ==
                            ApiOrderStatusTypes.placed_order ||
                        _order.status!.slug ==
                            ApiOrderStatusTypes.received_stock)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: TextField(
                          controller: _backofficePopupController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                            hintText: "Message To Backoffice",
                            labelText: "Message To Backoffice",
                          ),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel')),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: const Text('Submit')),
                      ],
                    )
                  ],
                ),
              ),
            );
          });
      if (proceed == null) return null;
      var order = await order_repo.changeStatusAdmin(auth,
          order: _order,
          status: status,
          messageForBackoffice: _backofficePopupController.text.isNotEmpty
              ? _backofficePopupController.text
              : null,
          messageForDealer: _dealerPopupController.text.isNotEmpty
              ? _dealerPopupController.text
              : null,
          delivered: delivered,
          notes: notes,
          deliveredPaymentType: deliveredPaymentType);
      setState(() {
        _getOrder = _loadOrder(context);
        _dealerPopupController.clear();
        _backofficePopupController.clear();
      });
      return order;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppError.fromError(e).toString())));
      return null;
    }
  }

  Future<bool?> _changeStatusBackoffice(
      BuildContext context, ApiOrderStatusTypes status) async {
    try {
      var authState = context.read<AuthBloc>().state as AuthLoggedInState;
      var auth = await refreshToken(context, authState);
      var order = await order_repo.changeStatusBackoffice(
        auth,
        order: _order,
        status: status,
      );
      setState(() {
        _getOrder = _loadOrder(context);
      });
      return order;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppError.fromError(e).toString())));
      return null;
    }
  }

  _postMessage(BuildContext context, String roomUUID, String message) async {
    try {
      var authState = context.read<AuthBloc>().state as AuthLoggedInState;
      var auth = await refreshToken(context, authState);
      var m = await order_repo.postMessage(auth,
          roomUUID: roomUUID, message: message);
      return m;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppError.fromError(e).toString())));
      return Future.error(AppError.fromError(e));
    }
  }
}

class _MessageList extends StatefulWidget {
  final String messageRoomUUID;
  final ApiUser user;

  const _MessageList(
      {Key? key, required this.messageRoomUUID, required this.user})
      : super(key: key);

  @override
  __MessageListState createState() => __MessageListState();
}

class __MessageListState extends State<_MessageList> {
  late Future _getMessages;
  late StreamSubscription<List<ApiMessage>>? _messageStream;
  late List<ApiMessage>? _messages;
  late List<ApiMessage> _streamMessages = [];

  @override
  void initState() {
    _getMessages = _loadMessages(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: FutureBuilder(
        future: _getMessages,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              return _render(context);
            } else {
              return const Center(child: Text('Invalid messages'));
            }
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _render(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [..._messages!, ..._streamMessages]
          .map((e) => _singleMessage(context, e))
          .toList(),
    );
  }

  Widget _singleMessage(BuildContext context, ApiMessage message) {
    var messageUserType = message.user!.userType;
    var messageForUserType = message;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: messageUserType!.isType(ApiUserTypes.admin)
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * .7,
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                    color: messageUserType.isType(ApiUserTypes.dealer)
                        ? Colors.black12
                        : messageUserType.isType(ApiUserTypes.backoffice)
                            ? Colors.black
                            : Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Column(
                    children: [
                      Text(message.message ?? '',
                          style: messageUserType.isType(ApiUserTypes.dealer)
                              ? null
                              : const TextStyle(color: Colors.white)),
                    ],
                  )),
              Text(
                  message.createdAt != null
                      ? DateFormat('d MMM, y, HH:mm a')
                          .format(message.createdAt!)
                      : '',
                  style: Theme.of(context).textTheme.bodyText2),
            ],
          ),
        ],
      ),
    );
  }

  _loadMessages(BuildContext context) async {
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    var auth = await refreshToken(context, authState);
    var messages =
        await order_repo.getMessages(auth, uuid: widget.messageRoomUUID);
    setState(() {
      _messages = messages;
    });
    _loadMessageStream();
    return messages;
  }

  _loadMessageStream() {
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    setState(() {
      _messageStream = MessageService()
          .listenMessages(authState.auth, widget.messageRoomUUID)
          .listen((e) {
        setState(() {
          _streamMessages = e;
        });
      });
    });
  }

  @override
  void dispose() {
    if (_messageStream != null) {
      _messageStream?.cancel();
    }
    super.dispose();
  }
}
