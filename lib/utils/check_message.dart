import 'package:flutter/material.dart';

Future<bool> checkMessage(
  BuildContext context,
  String msgtitle,
  String msgcontent,
) async {
  return await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(msgtitle),
      content: Text(msgcontent),
      actions: [
        TextButton(
          child: const Text("Hayır"),
          onPressed: () => Navigator.pop(context, false),
        ),
        ElevatedButton(
          child: const Text("Evet"),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    ),
  );
}
