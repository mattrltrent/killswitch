import 'package:flutter/material.dart';
import 'package:killswitch/killswitch.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Killswitch(
        killWhitelistAndIgnoreSourceUrl: "https://example.com/killswitch",
        suppressErrors: true,
        killedAppText:
            "Hi! This is the developer speaking. I killed the app. Please contact me for help by tapping this message.",
        killedAppTextClicked: () => print("user tapped the killed app text"),
        killStatusCode: 403,
        whitelistStatusCode: 202,
        doNothingStatusCode: 200,
        onKill: () => print("app was killed"),
        onWhitelist: () => print("app was whitelisted"),
        failuresToConnectToSourceBeforeWhitelist: 3,
        child: const Scaffold(body: Center(child: Text('Some example app'))),
      ),
    );
  }
}
