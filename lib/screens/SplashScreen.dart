import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mighty_news/network/RestApis.dart';
import 'package:mighty_news/screens/WalkThroughScreen.dart';
import 'package:mighty_news/utils/Colors.dart';
import 'package:mighty_news/utils/Common.dart';
import 'package:mighty_news/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:package_info/package_info.dart';

import '../main.dart';
import 'DashboardScreen.dart';

class SplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen';

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    appStore.setLoggedIn(getBoolAsync(IS_LOGGED_IN));

    updateUserData();

    remoteConfig = await initializeRemoteConfig().catchError((e) {
      log(e.toString());
    });

    await Future.delayed(Duration(seconds: 1));

    int themeModeIndex = getIntAsync(THEME_MODE_INDE);
    if (themeModeIndex == ThemeModeSystem) {
      appStore.setDarkMode(MediaQuery.of(context).platformBrightness == Brightness.dark);
    }

    if (getBoolAsync(IS_FIRST_TIME, defaultValue: true)) {
      WalkThroughScreen().launch(context, isNewTask: true);
    } else if (appStore.isLoggedIn.validate()) {
      await viewProfile().then((data) async {
        await setValue(FIRST_NAME, data.first_name);
        await setValue(LAST_NAME, data.last_name);

        if (data.profile_image != null) {
          await setValue(PROFILE_IMAGE, data.profile_image.validate());
        }

        if (data.my_topics != null) {
          appStore.setMyTopics(data.my_topics);
          await setValue(MY_TOPICS, jsonEncode(data.my_topics));
        }

        updateUserData();

        if (!getBoolAsync(IS_REMEMBERED, defaultValue: true)) {
          appStore.setLoggedIn(false);
          DashboardScreen().launch(context, isNewTask: true);
        } else {
          DashboardScreen().launch(context, isNewTask: true);
        }
      }).catchError((e) async {
        log(e);
        await logout(context);
      });
    } else {
      DashboardScreen().launch(context, isNewTask: true);
    }
  }

  void updateUserData() {
    appStore.setUserProfile(getStringAsync(PROFILE_IMAGE));
    appStore.setFirstName(getStringAsync(FIRST_NAME));
    appStore.setLastName(getStringAsync(LAST_NAME));
    appStore.setUserEmail(getStringAsync(USER_EMAIL));

    String s = getStringAsync(MY_TOPICS);
    appStore.setMyTopics([]);

    if (s.isNotEmpty) {
      List topics = jsonDecode(s);
      topics.validate().forEach((value) {
        appStore.addToMyTopics(value);
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkMode ? scaffoldSecondaryDark : Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/app_logo.png', height: 120),
              Text(mAppName, style: boldTextStyle(size: 22)),
            ],
          ),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (_, snap) {
              if (snap.hasData) {
                return Text('V ${snap.data.version.validate()}', style: secondaryTextStyle()).paddingBottom(8);
              }
              return SizedBox();
            },
          ),
        ],
      ).center(),
    );
  }
}
