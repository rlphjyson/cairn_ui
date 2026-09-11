import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../internal/outer_shadow.dart';
import '../../theme/cairn_theme.dart';
import '../../tokens/motion.dart';
import '../../tokens/shadows.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';

/// A single-line text field matching shadcn/ui's `Input`.
///
/// Dimensions come straight from shadcn/ui's classes: `h-9` (36 logical
/// pixels), `px-3` (12), `rounded-md`, a 1px `border-input` outline and
/// `shadow-xs`. Focus swaps the border to `--ring` and adds the 3px
/// `ring-ring/50` outset. The dark theme adds a translucent `bg-input/30`
/// fill that light mode does not have.
///
/// ## Implementation note
///
/// This wraps Flutter's [TextField] with [InputDecoration.collapsed] rather
/// than rebuilding text editing on [EditableText]. Text input is deceptively
/// deep — selection handles, the context menu, autofill, IME composition,
/// spell check and platform-specific caret behaviour — and reimplementing it
/// would mean losing all of it. Cairn replaces only the *chrome*: the Material
/// border, fill and floating label are stripped, and the visual shell is drawn
/// by this widget instead.
///
/// ```dart
/// CairnInput(
///   controller: controller,
///   placeholder: 'name@example.com',
///   keyboardType: TextInputType.emailAddress,
/// );
/// ```
class CairnInput extends StatefulWidget {
  /// Creates a text input.
  const CairnInput({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.autofocus = false,
    this.hasError = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.leading,
    this.trailing,
    this.semanticLabel,
  });

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// An externally supplied focus node.
  final FocusNode? focusNode;

  /// Text shown when the field is empty (`placeholder:text-muted-foreground`).
  final String? placeholder;

  /// Whether the field accepts input.
  final bool enabled;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Whether to hide the text, for passwords.
  final bool obscureText;

  /// Whether to take focus on first build.
  final bool autofocus;

  /// Marks the field invalid (`aria-invalid`), switching the border and ring
  /// to the destructive token.
  final bool hasError;

  /// The keyboard type.
  final TextInputType? keyboardType;

  /// The keyboard action button.
  final TextInputAction? textInputAction;

  /// Input formatters applied as the user types.
  final List<TextInputFormatter>? inputFormatters;

  /// The maximum number of characters.
  final int? maxLength;

  /// Called whenever the text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits.
  final ValueChanged<String>? onSubmitted;

  /// A widget before the text, such as a search icon.
  final Widget? leading;

  /// A widget after the text.
  final Widget? trailing;

  /// The accessible name.
  final String? semanticLabel;

  @override
  State<CairnInput> createState() => _CairnInputState();
}

class _CairnInputState extends State<CairnInput> {
  FocusNode? _internalNode;
  FocusNode get _node => widget.focusNode ?? (_internalNode ??= FocusNode());
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _node.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(CairnInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChange);
      _node.addListener(_onFocusChange);
    }
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

    final BorderRadius radius = BorderRadius.circular(theme.radiusScale.md);

    return Semantics(
      label: widget.semanticLabel,
      child: Opacity(
        opacity: widget.enabled ? 1.0 : 0.5,
        // The field is `bg-transparent` in light mode, so its shadow and focus
        // ring must be clipped to the outside of the box  see CairnShadowed.
        child: CairnShadowed(
          borderRadius: radius,
          shadows: <BoxShadow>[
            ...CairnShadows.xs,
            if (_focused)
              ...(widget.hasError ? theme.invalidRing : theme.focusRing),
          ],
          child: AnimatedContainer(
            duration: CairnMotion.d150,
            curve: CairnMotion.standard,
            height: 36.0,
            padding: const EdgeInsets.symmetric(horizontal: CairnSpacing.s3),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.input.withValues(alpha: 0.3)
                  : const Color(0x00000000),
              borderRadius: radius,
              border: Border.all(color: borderColor),
            ),
            child: Row(
              spacing: CairnSpacing.s2,
              children: <Widget>[
                if (widget.leading != null)
                  IconTheme(
                    data: IconThemeData(color: theme.mutedForeground, size: 16),
                    child: widget.leading!,
                  ),
                Expanded(
                  // Material's TextField asserts on a missing Material ancestor
                  // (it needs one for its selection overlay and text-selection
                  // theming). A component library must not push that requirement
                  // onto consumers, so each Cairn text control supplies its own
                  // transparent Material — invisible, and free of any ink or
                  // elevation.
                  child: Material(
                    type: MaterialType.transparency,
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _node,
                      enabled: widget.enabled,
                      readOnly: widget.readOnly,
                      obscureText: widget.obscureText,
                      autofocus: widget.autofocus,
                      keyboardType: widget.keyboardType,
                      textInputAction: widget.textInputAction,
                      inputFormatters: widget.inputFormatters,
                      maxLength: widget.maxLength,
                      onChanged: widget.onChanged,
                      onSubmitted: widget.onSubmitted,
                      style: textStyle,
                      cursorColor: theme.foreground,
                      cursorWidth: 1.0,
                      // Strip every Material affordance; this widget draws the box.
                      decoration: InputDecoration.collapsed(
                        hintText: widget.placeholder,
                        hintStyle: textStyle.copyWith(
                          color: theme.mutedForeground,
                        ),
                      ).copyWith(counterText: '', isDense: true, filled: false),
                    ),
                  ),
                ),
                if (widget.trailing != null)
                  IconTheme(
                    data: IconThemeData(color: theme.mutedForeground, size: 16),
                    child: widget.trailing!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
