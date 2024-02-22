import 'package:flutter/material.dart';
import 'package:killswitch/exports.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Killswitch(
        killAndWhitelistSourceUrl: "https://example.com",
        suppressErrors: false,
        killedAppText:
            "Hi! This is the developer speaking. I killed the app. Please contact me for help by tapping this message.",
        killedAppTextClicked: () => print("User tapped the killed app text"),
        killStatusCode: 403,
        whitelistStatusCode: 202,
        onKill: () => print("App was killed"),
        onWhitelist: () => print("App was whitelisted"),
        uniqueKillswitchWhitelistFailureConnectPrefsKey:
            "THIS IS MY UNIQUE PREFS KEY BECAUSE I USE THE SAME KEY AS THEIRS ELSEWHERE IN MY APP",
        failuresToConnectToSourceBeforeWhitelist: 25,
        child: const Scaffold(
          body: Center(child: Text('Some example app')),
        ),
      ),
    );
  }
}
