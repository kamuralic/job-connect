import 'package:flutter/material.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:job_connect/models/pop_up_menu_model.dart';
import 'package:job_connect/services/storage_services.dart';

class MyPopUpMenu extends StatelessWidget {
  const MyPopUpMenu({
    Key? key,
    required this.menuItems,
    required this.storageServiceProvider,
    required CustomPopupMenuController controller,
    required this.applicationId,
  })  : _controller = controller,
        super(key: key);

  final List<PopUpMenuModel> menuItems;
  final StorageService storageServiceProvider;
  final String applicationId;
  final CustomPopupMenuController _controller;

  @override
  Widget build(BuildContext context) {
    return CustomPopupMenu(
      child: Container(
        child: Icon(Icons.more_vert),
        padding: EdgeInsets.all(20),
      ),
      menuBuilder: () => ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          color: const Color(0xFF4C4C4C),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: menuItems
                  .map(
                    (item) => GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        if (item.title == 'Approve') {
                          storageServiceProvider.updateStatus(
                              applicationId: applicationId,
                              status: 'Approved',
                              context: context);

                          _controller.hideMenu();
                        } else {
                          storageServiceProvider.updateStatus(
                              applicationId: applicationId,
                              status: 'Declined',
                              context: context);

                          _controller.hideMenu();
                        }
                      },
                      child: Container(
                        height: 40,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              item.icon,
                              size: 15,
                              color: Colors.white,
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 10),
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  item.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
      pressType: PressType.singleClick,
      verticalMargin: -10,
      controller: _controller,
    );
  }
}
