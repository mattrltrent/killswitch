import 'package:flutter/material.dart';
import 'package:killswitch/exports.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Killswitch(
        killAndWhitelistSourceUrl: "https://example.com333",
        killStatusCode: 999,
        whitelistStatusCode: 200,
        child: Scaffold(
          body: Center(child: Text('Some example app')),
        ),
      ),
    );
  }
}
