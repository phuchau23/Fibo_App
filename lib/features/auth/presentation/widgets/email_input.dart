import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EmailInput extends StatefulWidget {
  final TextEditingController? controller;

  const EmailInput({super.key, this.controller});

  @override
  State<EmailInput> createState() => _EmailInputState();
}

class _EmailInputState extends State<EmailInput> {
  @override
  Widget build(BuildContext context) {
    return ShadInput(
      controller: widget.controller,
      placeholder: const Text('Email address'),
      keyboardType: TextInputType.emailAddress,
      leading: const Padding(
        padding: EdgeInsets.all(4.0),
        child: Icon(LucideIcons.mail), // icon thư
      ),
      trailing: ShadButton.ghost(
        width: 36,
        height: 36,
        padding: EdgeInsets.zero,
        onPressed: () {},
      ),
    );
  }
}
