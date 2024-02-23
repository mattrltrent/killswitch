import 'package:flutter/material.dart';

class KilledPage extends StatelessWidget {
  final String killedAppText;
  final VoidCallback? onTextClicked;

  const KilledPage(
      {super.key, required this.killedAppText, this.onTextClicked});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    onTap:
                        onTextClicked == null ? null : () => onTextClicked!(),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        killedAppText,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
