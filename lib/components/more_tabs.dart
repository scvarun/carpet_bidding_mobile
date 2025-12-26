import 'package:flutter/material.dart';
import 'package:carpet_app/routes/index.dart';

enum MoreTabsOptions {
  reports,
  importers,
  users,
  archive,
  deliveries,
  profile,
}

class MoreTabs extends StatelessWidget {
  final MoreTabsOptions currentTab;

  const MoreTabs({Key? key, required this.currentTab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black12,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          child: Row(
            children: MoreTabsOptions.values.map((e) {
              var title = '';
              switch (e) {
                case MoreTabsOptions.reports:
                  title = 'Reports';
                  break;
                case MoreTabsOptions.importers:
                  title = 'Importers';
                  break;
                case MoreTabsOptions.users:
                  title = 'Users';
                  break;
                case MoreTabsOptions.archive:
                  title = 'Archive';
                  break;
                case MoreTabsOptions.deliveries:
                  title = 'Deliveries';
                  break;
                case MoreTabsOptions.profile:
                  title = 'Profile';
                  break;
              }
              return GestureDetector(
                onTap: () {
                  switch (e) {
                    case MoreTabsOptions.reports:
                      Navigator.of(context)
                          .pushNamed(AdminReportsScreen.routeName);
                      break;
                    case MoreTabsOptions.importers:
                      Navigator.of(context)
                          .pushNamed(AdminImporterListScreen.routeName);
                      break;
                    case MoreTabsOptions.users:
                      Navigator.of(context)
                          .pushNamed(AdminUserListScreen.routeName);
                      break;
                    case MoreTabsOptions.archive:
                      Navigator.of(context)
                          .pushNamed(AdminArchiveListScreen.routeName);
                      break;
                    case MoreTabsOptions.deliveries:
                      Navigator.of(context)
                          .pushNamed(AdminDeliveriesListScreen.routeName);
                      break;
                    case MoreTabsOptions.profile:
                      Navigator.of(context).pushNamed(ProfileScreen.routeName);
                      break;
                  }
                },
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        color: currentTab == e
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: currentTab == e
                              ? Colors.transparent
                              : Colors.black12,
                          width: 2,
                        )),
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.bodyText2!.copyWith(
                          color: currentTab == e
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary),
                    )),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
