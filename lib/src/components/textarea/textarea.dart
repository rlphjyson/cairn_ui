import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// A multi-line text field matching shadcn/ui's `Textarea`.
///
/// `min-h-16 w-full rounded-md border border-input bg-transparent px-3 py-2
/// text-sm shadow-xs` — a 64 logical pixel minimum height with 12px horizontal
/// and 8px vertical padding.
///
/// shadcn/ui uses CSS `field-sizing-content` so the box grows with its content.
/// Flutter has no equivalent property, but [TextField] with a null `maxLines`
/// produces the same behaviour, which is what [autoGrow] enables.
///
/// ```dart
/// CairnTextarea(
///   controller: controller,
///   placeholder: 'Tell us what happened...',
///   minLines: 3,
/// );
/// ```
class CairnTextarea extends StatefulWidget {
  /// Creates a multi-line text field.
  const CairnTextarea({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.hasError = false,
    this.autoGrow = true,
    this.minLines,
    this.maxLines,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.semanticLabel,
  });

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// An externally supplied focus node.
  final FocusNode? focusNode;

  /// Text shown when empty.
  final String? placeholder;

  /// Whether the field accepts input.
  final bool enabled;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Whether to take focus on first build.
  final bool autofocus;

  /// Marks the field invalid, switching the border and ring to destructive.
  final bool hasError;

  /// Whether the box grows with its content (`field-sizing-content`).
  final bool autoGrow;

  /// The minimum number of visible lines.
  final int? minLines;

  /// The maximum number of visible lines before scrolling. Ignored when
  /// [autoGrow] is true.
  final int? maxLines;

  /// The maximum number of characters.
  final int? maxLength;

  /// Input formatters applied as the user types.
  final List<TextInputFormatter>? inputFormatters;

  /// Called whenever the text changes.
  final ValueChanged<String>? onChanged;

  /// The accessible name.
  final String? semanticLabel;

  @override
  State<CairnTextarea> createState() => _CairnTextareaState();
}

class _CairnTextareaState extends State<CairnTextarea> {
  FocusNode? _internalNode;
  FocusNode get _node => widget.focusNode ?? (_internalNode ??= FocusNode());
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _node.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _node.removeListener(_onFocusChange);
    _internalNode?.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!mounted || _focused == _node.hasFocus) return;
    setState(() => _focused = _node.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color borderColor = widget.hasError
        ? theme.destructive
        : (_focused ? theme.ring : theme.input);

    final TextStyle textStyle = theme
        .textStyle(CairnTypography.sm)
        .copyWith(color: theme.foreground);

    return Semantics(
      label: widget.semanticLabel,
      child: Opacity(
        opacity: widget.enabled ? 1.0 : 0.5,
        child: AnimatedContainer(
          duration: CairnMotion.d150,
          curve: CairnMotion.standard,
          constraints: const BoxConstraints(minHeight: 64.0),
          padding: const EdgeInsets.symmetric(
            horizontal: CairnSpacing.s3,
            vertical: CairnSpacing.s2,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? theme.input.withValues(alpha: 0.3)
                : const Color(0x00000000),
            borderRadius: BorderRadius.circular(theme.radiusScale.md),
            border: Border.all(color: borderColor),
            boxShadow: <BoxShadow>[
              ...CairnShadows.xs,
              if (_focused)
                ...(widget.hasError ? theme.invalidRing : theme.focusRing),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _node,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            minLines: widget.minLines,
            maxLines: widget.autoGrow ? null : (widget.maxLines ?? 4),
            maxLength: widget.maxLength,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            keyboardType: TextInputType.multiline,
            style: textStyle,
            cursorColor: theme.foreground,
            cursorWidth: 1.0,
            decoration: InputDecoration.collapsed(
              hintText: widget.placeholder,
              hintStyle: textStyle.copyWith(color: theme.mutedForeground),
            ).copyWith(counterText: '', isDense: true),
          ),
        ),
      ),
    );
  }
}
