import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PasswordInput extends StatefulWidget {
  final TextEditingController? controller;
  const PasswordInput({super.key, this.controller});

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return ShadInput(
      controller: widget.controller,
      placeholder: const Text('••••••••'),
      obscureText: obscure,
      leading: const Padding(
        padding: EdgeInsets.all(4.0),
        child: Icon(LucideIcons.lock),
      ),
      trailing: ShadButton.ghost(
        width: 36,
        height: 36,
        padding: EdgeInsets.zero,
        child: Icon(obscure ? LucideIcons.eyeOff : LucideIcons.eye),
        onPressed: () => setState(() => obscure = !obscure),
      ),
    );
  }
}
