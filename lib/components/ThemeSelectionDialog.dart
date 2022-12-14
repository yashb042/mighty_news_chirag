import 'package:flutter/material.dart';
import 'package:mighty_news/network/RestApis.dart';
import 'package:mighty_news/screens/DashboardScreen.dart';
import 'package:mighty_news/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

class ThemeSelectionDialog extends StatefulWidget {
  static String tag = '/ThemeSelectionDialog';

  @override
  ThemeSelectionDialogState createState() => ThemeSelectionDialogState();
}

class ThemeSelectionDialogState extends State<ThemeSelectionDialog> {
  List<String> themeModeList = ['Light', 'Dark', 'System default'];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    currentIndex = getIntAsync(THEME_MODE_INDE);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      padding: EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: themeModeList.length,
        itemBuilder: (BuildContext context, int index) {
          return RadioListTile(
            value: index,
            groupValue: currentIndex,
            title: Text(themeModeList[index], style: primaryTextStyle()),
            onChanged: (val) {
              setState(() {
                currentIndex = val;

                if (val == ThemeModeSystem) {
                  appStore.setDarkMode(MediaQuery.of(context).platformBrightness == Brightness.dark);
                } else if (val == ThemeModeLight) {
                  appStore.setDarkMode(false);
                } else if (val == ThemeModeDark) {
                  appStore.setDarkMode(true);
                }

                setValue(THEME_MODE_INDE, val);
              });

              if (appStore.isLoggedIn) {
                updateProfile(showToast: false).then((value) {}).catchError(log);
              }

              finish(context);
            },
          );
        },
      ),
    );
  }
}
