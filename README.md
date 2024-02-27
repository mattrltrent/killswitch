# Flutter package: `killswitch` 🔐

*Remotely turn your app on/off even after you no longer have access to its code.*

- Quick-start guide found [here](https://matthewtrent.me/articles/killswitch).
- Package found [here](https://pub.dev/packages/killswitch).
- GitHub repo found [here](https://github.com/mattrltrent/killswitch)

----

Documentation is found largely in the package itself via doc-comments. This is useful after you get started.


In the meantime, here's a small taste showing how simple the package is to use (wrap high-up in your widget tree in `main.dart`):

```dart
Killswitch(
	killWhitelistAndIgnoreSourceUrl:  "https://example.com/killswitch", // <-- your control URL
	child: ...
);
```

![analytics](https://hidden-coast-90561-45544df95b1b.herokuapp.com/api/v1/analytics/?kind=package-killswitch)