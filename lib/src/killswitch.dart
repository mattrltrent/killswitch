import 'package:flutter/material.dart';
import 'package:killswitch/src/constants.dart';
import 'package:killswitch/src/killed_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Killswitch extends StatefulWidget {
  /// what will show when the app is killed
  final String killedAppText;

  /// what will happen when the killed app text is clicked
  final VoidCallback? killedAppTextClicked;

  /// called when the app is killed
  final VoidCallback? onKill;

  /// called when the app is whitelisted
  final VoidCallback? onWhitelist;

  /// the status code that will kill the app when returned from [killWhitelistAndIgnoreSourceUrl]
  final int killStatusCode;

  /// the status code that if returned, fully ignores the killswitch; useful for testing
  final int doNothingStatusCode;

  /// the status code that will permanently whitelist the app when returned from [killWhitelistAndIgnoreSourceUrl]
  final int whitelistStatusCode;

  /// the URL that will be polled to check if the app should be killed or whitelisted
  final String killWhitelistAndIgnoreSourceUrl;

  /// child of widget
  final Widget child;

  /// don't push to the killed page upon the app being killed
  final bool preventPushToKilledPage;

  /// prefs key to store info about if the app is whitelisted
  ///
  /// only change if you think its default value will have a conflict with yours
  final String uniqueKillswitchWhitelistPrefsKey;

  /// prefs key to store info about how many times the app has attempted to connect to [killWhitelistAndIgnoreSourceUrl] but failed.
  ///
  /// only change if you think its default value will have a conflict with yours
  final String uniqueKillswitchWhitelistFailureConnectPrefsKey;

  /// number of times the app will tolerate a failed connection to [killWhitelistAndIgnoreSourceUrl] before whitelisting app permenently
  final int failuresToConnectToSourceBeforeWhitelist;

  /// whether errors should be suppressed
  final bool suppressErrors;

  const Killswitch({
    super.key,
    this.onKill,
    this.onWhitelist,
    this.killedAppTextClicked,
    this.killedAppText =
        "Something went wrong. Contact the developer for help.",
    this.suppressErrors = true,
    this.uniqueKillswitchWhitelistPrefsKey = whitelistPrefKey,
    this.uniqueKillswitchWhitelistFailureConnectPrefsKey =
        whitelistFailedSourceConnectPrefKey,
    this.failuresToConnectToSourceBeforeWhitelist = 10,
    this.killStatusCode = 403,
    this.whitelistStatusCode = 202,
    this.doNothingStatusCode = 200,
    this.preventPushToKilledPage = false,
    required this.killWhitelistAndIgnoreSourceUrl,
    required this.child,
  }) : assert(killStatusCode != whitelistStatusCode &&
            killStatusCode != doNothingStatusCode &&
            whitelistStatusCode != doNothingStatusCode);

  @override
  State<Killswitch> createState() => _KillswitchState();
}

class _KillswitchState extends State<Killswitch> {
  /// kill the app
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

  /// check if the app has failed to connect to the source [widget.killAndWhitelistSourceUrl] more than [widget.failuresToConnectToSourceBeforeWhitelist] times
  Future<void> _checkSourceConnectFailures() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int failures =
        prefs.getInt(widget.uniqueKillswitchWhitelistFailureConnectPrefsKey) ??
            0;
    if (failures > widget.failuresToConnectToSourceBeforeWhitelist)
      _whitelist();
  }

  /// increment the number of times the app has failed to connect to the source [widget.killAndWhitelistSourceUrl]
  Future<void> _incrementSourceConnectFailures() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int failures =
        prefs.getInt(widget.uniqueKillswitchWhitelistFailureConnectPrefsKey) ??
            0;
    prefs.setInt(
        widget.uniqueKillswitchWhitelistFailureConnectPrefsKey, failures + 1);
    _checkSourceConnectFailures();
  }

  /// whitelist the app
  Future<void> _whitelist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (widget.onWhitelist != null) widget.onWhitelist!();
    prefs.setBool(widget.uniqueKillswitchWhitelistPrefsKey, true);
  }

  /// check if the app is whitelisted
  Future<bool> _isWhitelisted() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(widget.uniqueKillswitchWhitelistPrefsKey) ?? false;
  }

  /// poll the source [widget.killAndWhitelistSourceUrl] to check if the app should be killed or whitelisted
  void _pollSource() {
    http.get(Uri.parse(widget.killWhitelistAndIgnoreSourceUrl)).then((r) {
      if (r.statusCode == widget.killStatusCode) {
        _kill();
      } else if (r.statusCode == widget.whitelistStatusCode) {
        _whitelist();
      } else if (r.statusCode == widget.doNothingStatusCode) {
        // do nothing! we're just testing
      } else {
        _incrementSourceConnectFailures();
      }
    }).catchError((e) {
      if (e is! http.ClientException) _incrementSourceConnectFailures();
      if (!widget.suppressErrors) throw e;
    });
  }

  /// asynronously execute the kill/whitelist check and commands
  Future<void> _execute() async {
    if (await _isWhitelisted()) return;
    _pollSource();
  }

  /// initstate
  @override
  void initState() {
    super.initState();
    _execute();
  }

  /// build method
  @override
  Widget build(BuildContext context) => widget.child;
}
