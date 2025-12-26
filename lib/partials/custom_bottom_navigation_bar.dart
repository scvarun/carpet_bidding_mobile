import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carpet_app/models/order.dart';
import 'package:sizer/sizer.dart';

import 'package:carpet_app/models/user_type.dart';
import 'package:carpet_app/store/app/app_bloc.dart';
import 'package:carpet_app/store/auth/auth_bloc.dart';
import 'package:carpet_app/routes/index.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoggedInState) {
          if (state.auth.user!.userType!.isType(ApiUserTypes.admin)) {
            return const _AdminBottomNavigationBar();
          } else if (state.auth.user!.userType!.isType(ApiUserTypes.dealer)) {
            return const _DealerBottomNavigationBar();
          } else if (state.auth.user!.userType!
              .isType(ApiUserTypes.backoffice)) {
            return const _BackofficeBottomNavigationBarder();
          }
        }
        return Container(height: 0);
      },
    );
  }
}

class _AdminBottomNavigationBar extends StatelessWidget {
  const _AdminBottomNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return BottomNavigationBar(
          onTap: (index) => _itemTapped(index, context,
              state.app.headerNavOpen!, state.app.profileNavOpen!),
          // currentIndex: index,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.background,
          selectedLabelStyle: TextStyle(
              height: 1.7,
              fontWeight: FontWeight.bold,
              letterSpacing: .5,
              fontSize: 8.sp),
          unselectedLabelStyle: TextStyle(
              height: 1.7,
              fontWeight: FontWeight.bold,
              letterSpacing: .5,
              fontSize: 8.sp),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          iconSize: 18.sp,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_bag),
              label: 'Orders'.toUpperCase(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.help),
              label: 'Enquiries'.toUpperCase(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.help),
              label: 'Received'.toUpperCase(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.help),
              label: 'Pending'.toUpperCase(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.list_alt),
              label: 'Inventory'.toUpperCase(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_cart),
              label: 'Custom'.toUpperCase(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.list),
              label: 'More'.toUpperCase(),
            ),
          ],
        );
      },
    );
  }

  void _itemTapped(int index, BuildContext context, bool headerNavOpen,
      bool profileNavOpen) {
    if (headerNavOpen) context.read<AppBloc>().add(AppHeaderNavClose());
    Navigator.of(context).popUntil((route) => route.isFirst);
    switch (index) {
      case 0:
        Navigator.of(context).popAndPushNamed(AdminOrderListScreen.routeName);
        break;
      case 1:
        Navigator.of(context).popAndPushNamed(AdminEnquiryListScreen.routeName);
        break;
      case 2:
        Navigator.of(context)
            .popAndPushNamed(AdminOrderReceivedStockListScreen.routeName);
        break;
      case 3:
        Navigator.of(context)
            .popAndPushNamed(AdminOrderPendingStockListScreen.routeName);
        break;
      case 4:
        Navigator.of(context)
            .popAndPushNamed(AdminInventoryListScreen.routeName);
        break;
      case 5:
        Navigator.of(context).popAndPushNamed(AdminCustomListScreen.routeName);
        break;
      case 6:
        Navigator.of(context).pushNamed(AdminImporterListScreen.routeName);
        break;
    }
  }
}

class _DealerBottomNavigationBar extends StatelessWidget {
  const _DealerBottomNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return BottomNavigationBar(
          onTap: (index) => _itemTapped(index, context,
              state.app.headerNavOpen!, state.app.profileNavOpen!),
          // currentIndex: index,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.background,
          selectedLabelStyle: TextStyle(
              height: 1.7,
              fontWeight: FontWeight.bold,
              letterSpacing: .5,
              fontSize: 9.sp),
          unselectedLabelStyle: TextStyle(
              height: 1.7,
              fontWeight: FontWeight.bold,
              letterSpacing: .5,
              fontSize: 9.sp),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          iconSize: 24.sp,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: 'Home'.toUpperCase(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_bag),
              label: 'Orders'.toUpperCase(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.trending_up),
              label: 'Reports'.toUpperCase(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.notifications),
              label: 'Alert'.toUpperCase(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: 'Profile'.toUpperCase(),
            ),
          ],
        );
      },
    );
  }

  void _itemTapped(int index, BuildContext context, bool headerNavOpen,
      bool profileNavOpen) {
    if (headerNavOpen) context.read<AppBloc>().add(AppHeaderNavClose());
    Navigator.of(context).popUntil((route) => route.isFirst);
    switch (index) {
      case 0:
        Navigator.of(context).popAndPushNamed(OrderCreateScreen.routeName);
        break;
      case 1:
        Navigator.of(context).popAndPushNamed(OrderListScreen.routeName);
        break;
      case 2:
        Navigator.of(context).popAndPushNamed(ReportsScreen.routeName);
        break;
      case 3:
        Navigator.of(context).popAndPushNamed(NotificationListScreen.routeName);
        break;
      case 4:
        Navigator.of(context).pushNamed(ProfileScreen.routeName);
        break;
    }
  }
}

class _BackofficeBottomNavigationBarder extends StatelessWidget {
  const _BackofficeBottomNavigationBarder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return BottomNavigationBar(
          onTap: (index) => _itemTapped(index, context,
              state.app.headerNavOpen!, state.app.profileNavOpen!),
          // currentIndex: index,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.background,
          selectedLabelStyle: TextStyle(
              height: 1.7,
              fontWeight: FontWeight.bold,
              letterSpacing: .5,
              fontSize: 9.sp),
          unselectedLabelStyle: TextStyle(
              height: 1.7,
              fontWeight: FontWeight.bold,
              letterSpacing: .5,
              fontSize: 9.sp),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          iconSize: 24.sp,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_bag),
              label: 'Orders'.toUpperCase(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.check_circle),
              label: 'Received'.toUpperCase(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.local_shipping),
              label: 'Dispatch'.toUpperCase(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: 'Profile'.toUpperCase(),
            ),
          ],
        );
      },
    );
  }

  void _itemTapped(int index, BuildContext context, bool headerNavOpen,
      bool profileNavOpen) {
    if (headerNavOpen) context.read<AppBloc>().add(AppHeaderNavClose());
    Navigator.of(context).popUntil((route) => route.isFirst);
    switch (index) {
      case 0:
        Navigator.of(context)
            .popAndPushNamed(BackofficeOrderListScreen.routeName);
        break;
      case 1:
        Navigator.of(context).popAndPushNamed(
            BackofficeOrderListScreen.routeName,
            arguments: BackofficeOrderListScreen.args(
                type: ApiOrderStatusTypes.order_confirmed));
        break;
      case 2:
        Navigator.of(context).popAndPushNamed(
            BackofficeOrderListScreen.routeName,
            arguments: BackofficeOrderListScreen.args(
                type: ApiOrderStatusTypes.dispatched));
        break;
      case 3:
        Navigator.of(context).pushNamed(ProfileScreen.routeName);
        break;
    }
  }
}
