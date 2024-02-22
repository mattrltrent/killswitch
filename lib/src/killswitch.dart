import 'package:flutter/material.dart';
import 'package:killswitch/src/constants.dart';
import 'package:killswitch/src/killed_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// todo: reverse the error? via another "good" kill code? use caching

class Killswitch extends StatefulWidget {
  final String killedAppText;
  final VoidCallback? killedAppTextClicked;
  final VoidCallback? onKill;
  final int killStatusCode;
  final int whitelistStatusCode;
  final String killAndWhitelistSourceUrl;
  final Widget child;
  final bool preventPushToKilledPage;
  final String uniqueKillswitchWhitelistPrefsKey;
  final bool suppressErrors;

  const Killswitch({
    super.key,
    this.onKill,
    this.killedAppTextClicked,
    this.killedAppText = "Something went wrong. Contact the developer for help.",
    this.suppressErrors = true,
    this.uniqueKillswitchWhitelistPrefsKey = whitelistPrefKey,
    this.killStatusCode = 403,
    this.whitelistStatusCode = 200,
    this.preventPushToKilledPage = false,
    required this.killAndWhitelistSourceUrl,
    required this.child,
  }) : assert(killStatusCode != whitelistStatusCode);

  @override
  State<Killswitch> createState() => _KillswitchState();
}

class _KillswitchState extends State<Killswitch> {
  void _kill() {
    if (widget.onKill != null) widget.onKill!();
    if (widget.preventPushToKilledPage) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KilledPage(
          killedAppText: widget.killedAppText,
          onTextClicked: widget.killedAppTextClicked,
        ),
      ),
    );
  }

  Future<void> _whitelist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(widget.uniqueKillswitchWhitelistPrefsKey, true);
  }

  Future<bool> _isWhitelisted() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(widget.uniqueKillswitchWhitelistPrefsKey) ?? false;
  }

  void _pollSource() {
    try {
      http.get(Uri.parse(widget.killAndWhitelistSourceUrl)).then((r) {
        if (r.statusCode == widget.killStatusCode) {
          _kill();
        } else if (r.statusCode == widget.whitelistStatusCode) {
          _whitelist();
        }
      }).catchError((e) {
        if (!widget.suppressErrors) throw e;
      });
    } catch (e) {
      if (!widget.suppressErrors) rethrow;
    }
  }

  Future<void> execute() async {
    if (await _isWhitelisted()) return;
    _pollSource();
  }

  @override
  void initState() {
    super.initState();
    execute();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
