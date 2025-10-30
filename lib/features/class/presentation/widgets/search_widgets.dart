import 'dart:async';
import 'package:flutter/material.dart';

class CouponSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback onClaim; // click kính lúp
  final VoidCallback? onMic; // click micro (optional)

  const CouponSearchBar({
    super.key,
    required this.controller,
    required this.hint,
    required this.onClaim,
    this.onMic,
  });

  @override
  State<CouponSearchBar> createState() => _CouponSearchBarState();
}

class _CouponSearchBarState extends State<CouponSearchBar> {
  final _focus = FocusNode();
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focus.hasFocus;
    final scheme = Theme.of(context).colorScheme;

    return Listener(
      onPointerDown: (_) => setState(() => _isPressed = true),
      onPointerUp: (_) => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.99 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isFocused
                  ? scheme.primary.withOpacity(0.25)
                  : Colors.black12,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isFocused
                    ? scheme.primary.withOpacity(0.18)
                    : Colors.black.withOpacity(0.06)),
                blurRadius: isFocused ? 16 : 12,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // icon kính lúp bên trái
              InkResponse(
                onTap: widget.onClaim,
                radius: 22,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.0),
                  child: Icon(Icons.search, size: 20, color: Colors.black38),
                ),
              ),
              const SizedBox(width: 6),

              // text field
              Expanded(
                child: TextField(
                  focusNode: _focus,
                  controller: widget.controller,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => widget.onClaim(),
                  onTapOutside: (_) =>
                      FocusScope.of(context).unfocus(), // tap ngoài -> ẩn
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),

              // divider + mic
              Container(
                width: 1,
                height: 22,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: Colors.black12,
              ),
              InkResponse(
                onTap: widget.onMic,
                radius: 22,
                child: Icon(
                  Icons.mic_none_rounded,
                  size: 20,
                  color: widget.onMic == null ? Colors.black26 : Colors.black38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
