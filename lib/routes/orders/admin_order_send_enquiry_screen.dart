import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carpet_app/layouts/main_layout.dart';
import 'package:carpet_app/lib/refresh_tokens.dart';
import 'package:carpet_app/models/app_error.dart';
import 'package:carpet_app/models/importer.dart';
import 'package:carpet_app/models/inventory.dart';
import 'package:carpet_app/models/order.dart';
import 'package:carpet_app/routes/orders/order_add_screen.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:carpet_app/store/orders/order_repo.dart' as order_repo;
import 'package:carpet_app/store/importers/importers_repo.dart'
    as importer_repo;
import 'package:sizer/sizer.dart';
import 'package:whatsapp_share2/whatsapp_share2.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';
import 'package:url_launcher/url_launcher.dart';

class _AdminOrderSendEnquiryScreenArgs {
  String uuid;
  _AdminOrderSendEnquiryScreenArgs({required this.uuid});
}

class AdminOrderSendEnquiryScreen extends StatelessWidget {
  static const routeName = '/orders/sendEnquiry';

  const AdminOrderSendEnquiryScreen({Key? key}) : super(key: key);

  static _AdminOrderSendEnquiryScreenArgs args({required String uuid}) {
    return _AdminOrderSendEnquiryScreenArgs(uuid: uuid);
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as _AdminOrderSendEnquiryScreenArgs;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoggedInState) {
          return _AdminOrderSendEnquiryRender(args);
        }
        return Container();
      },
    );
  }
}

class _AdminOrderSendEnquiryRender extends StatefulWidget {
  final _AdminOrderSendEnquiryScreenArgs args;

  const _AdminOrderSendEnquiryRender(this.args, {Key? key}) : super(key: key);

  @override
  State<_AdminOrderSendEnquiryRender> createState() =>
      __AdminOrderSendEnquiryRenderState();
}

class __AdminOrderSendEnquiryRenderState
    extends State<_AdminOrderSendEnquiryRender> {
  late Future _getOrder;
  late Future _getAvailableImporters;
  late ApiOrder _order;
  late List<ApiImporter> _availableImporters;
  late List<ApiOrderContact> _contacts;
  final _customNameController = TextEditingController();
  final _customPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getOrder = _loadOrder(context);
    _getAvailableImporters = _loadAvailableImporters(context);
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
      child: FutureBuilder(
        future: Future.wait(<Future>[_getOrder, _getAvailableImporters]),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              return SingleChildScrollView(child: _orderSingleRender(context));
            } else {
              return const Center(child: Text('Invalid order'));
            }
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _orderSingleRender(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            _headerInfo(context),
            Container(
                padding: const EdgeInsets.only(top: 30, left: 10, right: 10),
                child: Column(
                  children: [
                    Text('Notify Importer'.toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .headline6!
                            .copyWith(fontWeight: FontWeight.bold)),
                    Text('Check item availability from these importer(s)',
                        style: Theme.of(context).textTheme.bodyText2),
                    _importerField(context),
                    const Divider(),
                    Text('Notify Dealer'.toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .headline6!
                            .copyWith(fontWeight: FontWeight.bold)),
                    _notifyDealer(context),
                    const Divider(),
                    _orderInfo(context),
                  ],
                ))
          ],
        )
      ],
    );
  }

  Widget _headerInfo(BuildContext context) {
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

  Widget _importerField(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
        child: Column(
          children: [
            ..._contacts.asMap().keys.map((e) => Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(children: [
                  TextButton(
                      onPressed: () {
                        setState(() {
                          _contacts.removeAt(e);
                          _updateOrderContacts(context);
                        });
                      },
                      child: Icon(Icons.close,
                          color: Theme.of(context).colorScheme.error)),
                  Expanded(
                    child: Text(_contacts[e].name ?? '',
                        style: Theme.of(context).textTheme.bodyText1),
                  ),
                  TextButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(const CircleBorder()),
                      ),
                      onPressed: () async {
                        try {
                          var text = _text;
                          await _isInstalled();
                          // final link = WhatsAppUnilink(
                          //   text: text,
                          // );
                          await launchUrl(
                              Uri.parse('https://wa.me/?text=text'),
                              mode: LaunchMode.externalApplication);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(AppError.fromError(e).toString())));
                        }
                      },
                      child: const Icon(Icons.whatsapp))
                ]))),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: OutlinedButton(
                  onPressed: () async {
                    await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                              title: const Text('Add Importer'),
                              content: SizedBox(
                                  height: 200.sp,
                                  width: 100.sp,
                                  child: ListView.builder(
                                      itemCount: _availableImporters.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          onTap: () {
                                            setState(() {
                                              var i = _contacts.indexWhere(
                                                  (e) =>
                                                      e.phone ==
                                                      _availableImporters[index]
                                                          .phone);
                                              if (i == -1) {
                                                _contacts.add(ApiOrderContact(
                                                  name:
                                                      _availableImporters[index]
                                                          .name,
                                                  phone:
                                                      _availableImporters[index]
                                                          .phone,
                                                ));
                                              }
                                            });
                                            _updateOrderContacts(context);
                                            Navigator.of(context).pop();
                                          },
                                          title: Text(
                                              _availableImporters[index].name ??
                                                  ''),
                                        );
                                      })));
                        });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: const Icon(Icons.add)),
                      Text('Add Importer',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              )),
                    ],
                  )),
            ),
            OutlinedButton(
                onPressed: () async {
                  await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                            title: const Text('Add Custom'),
                            scrollable: true,
                            content: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  child: TextField(
                                    controller: _customNameController,
                                    keyboardType: TextInputType.name,
                                    decoration: const InputDecoration(
                                      label: Text('Name'),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  child: TextField(
                                    keyboardType: TextInputType.phone,
                                    controller: _customPhoneController,
                                    decoration: const InputDecoration(
                                      label: Text('Phone'),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(right: 10),
                                        child: OutlinedButton(
                                            onPressed: () {
                                              if (_customNameController
                                                      .text.isNotEmpty &&
                                                  _customPhoneController
                                                      .text.isNotEmpty) {
                                                setState(() {
                                                  _contacts.add(ApiOrderContact(
                                                      name:
                                                          _customNameController
                                                              .text,
                                                      phone:
                                                          _customNameController
                                                              .text));
                                                  _customNameController.clear();
                                                  _customPhoneController
                                                      .clear();
                                                });
                                                _updateOrderContacts(context);
                                                Navigator.of(context).pop();
                                              }
                                            },
                                            child: const Text('Add')),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.only(left: 10),
                                        child: OutlinedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Cancel')),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ));
                      });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: const Icon(Icons.add)),
                    Text('Add Custom',
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            )),
                  ],
                ))
          ],
        ));
  }

  Widget _notifyDealer(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          children: [
            Expanded(
                child: Text(
              _order.user!.name,
              textAlign: TextAlign.right,
            )),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  OutlinedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(const CircleBorder()),
                      ),
                      onPressed: () async {
                        try {
                          var text = _text;
                          await _isInstalled();
                          // final link = WhatsAppUnilink(
                          //   text: text,
                          // );
                          // await launchUrl(link.asUri());
                          await launchUrl(
                              Uri.parse('https://wa.me/?text=text'),
                              mode: LaunchMode.externalApplication);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(AppError.fromError(e).toString())));
                        }
                      },
                      child: const Icon(Icons.whatsapp)),
                ],
              ),
            )
          ],
        ));
  }

  Widget _orderInfo(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.bodyText2!.copyWith(
          color: Colors.black,
          fontSize: 10.sp,
          height: 2,
          fontWeight: FontWeight.bold,
        );
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: const BoxDecoration(
            border:
                Border(bottom: BorderSide(color: Colors.black12, width: 2))),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Text('Product Type'.toUpperCase(),
                      textAlign: TextAlign.right,
                      style: textStyle.copyWith(color: Colors.black54)),
                ),
              ),
              Expanded(
                child: Text(
                    _order.type.toString().split('.').last.toUpperCase(),
                    style: textStyle),
              ),
            ]),
            if (_order.type == ApiInventoryTypes.rolls)
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: Text('Reference'.toUpperCase(),
                        textAlign: TextAlign.right,
                        style: textStyle.copyWith(color: Colors.black54)),
                  ),
                ),
                Expanded(
                  child: Text(_order.reference!, style: textStyle),
                ),
              ]),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Text('Catalog'.toUpperCase(),
                      textAlign: TextAlign.right,
                      style: textStyle.copyWith(color: Colors.black54)),
                ),
              ),
              Expanded(
                child: Text(_order.catalogue?.name ?? '', style: textStyle),
              ),
            ]),
            if (_order.type == ApiInventoryTypes.rolls)
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: Text('Pattern No'.toUpperCase(),
                        textAlign: TextAlign.right,
                        style: textStyle.copyWith(color: Colors.black54)),
                  ),
                ),
                Expanded(
                  child: Text(_order.patternNo ?? '', style: textStyle),
                ),
              ]),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Text('Quantity'.toUpperCase(),
                      textAlign: TextAlign.right,
                      style: textStyle.copyWith(color: Colors.black54)),
                ),
              ),
              Expanded(
                child: Text(_order.quantity.toString(), style: textStyle),
              ),
            ]),
          ],
        ));
  }

  String get _text {
    if (_order.type == ApiInventoryTypes.rolls) {
      return '''
Status: ${_order.status!.slugString},
Product Type: ${_order.type.toString().split('.').last}
Reference: ${_order.reference ?? ''}
Catalogue: ${_order.catalogue?.name ?? ''}
Pattern No: ${_order.patternNo ?? ''}
Quantity: ${_order.quantity}
''';
    } else {
      return '''
Status: ${_order.status!.slugString},
Product Type: ${_order.type.toString().split('.').last}
Catalogue: ${_order.catalogue?.name ?? ''}
Quantity: ${_order.quantity}
''';
    }
  }

  Future<void> _updateOrderContacts(BuildContext context) async {
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    var auth = await refreshToken(context, authState);
    await order_repo.updateOrderContacts(auth, _order, _contacts);
  }

  Future<ApiOrder?> _loadOrder(BuildContext context) async {
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    var auth = await refreshToken(context, authState);
    var order = await order_repo.loadOrder(auth, widget.args.uuid);
    if (order != null) {
      setState(() {
        _order = order;
        _contacts = order.orderContacts ?? [];
      });
    }
    return order;
  }

  Future<void> _isInstalled() async {
    // final val = await WhatsappShare.isInstalled(package: Package.whatsapp);
    // if (val == null || val == false) throw Exception('Whatsapp not installed');
  }

  Future<List<ApiImporter>?> _loadAvailableImporters(
      BuildContext context) async {
    var authState = context.read<AuthBloc>().state as AuthLoggedInState;
    var auth = await refreshToken(context, authState);
    var importers = await importer_repo.loadImporters(auth);
    setState(() {
      if (importers != null) {
        _availableImporters = importers;
      }
    });
    return importers;
  }
}
